#!/usr/bin/env bash
# elepay au PAY one-shot diagnostic collector.
# Run inside elepay_flutter/example.
# Usage:
#   ./collect_elepay_diag.sh start <device_id>   # clear logcat right before reproducing the bug
#   ./collect_elepay_diag.sh stop  <device_id>   # dump runtime + static build snapshot, then zip
#
# <device_id> is the same serial shown by `flutter devices` / `adb devices` (e.g. baf9fef4 / 127.0.0.1:16416)
set -euo pipefail

usage() {
  echo "Usage:" >&2
  echo "  $0 start <device_id>" >&2
  echo "  $0 stop  <device_id>" >&2
  exit 2
}

detect_app_pkg() {
  local pkg=""
  if [[ -f android/app/build.gradle ]]; then
    pkg=$(awk -F'"' '/applicationId/ {print $2; exit}' android/app/build.gradle)
  fi
  if [[ -z "$pkg" && -f android/app/build.gradle.kts ]]; then
    pkg=$(awk -F'"' '/applicationId/ {print $2; exit}' android/app/build.gradle.kts)
  fi
  echo "$pkg"
}

CMD="${1:-}"
DEVICE_ID="${2:-}"
[[ -z "$CMD" || -z "$DEVICE_ID" ]] && usage

ADB=(adb -s "$DEVICE_ID")

case "$CMD" in
  start)
    "${ADB[@]}" logcat -c -b all
    echo "logcat cleared on $DEVICE_ID"
    ;;
  stop)
    OUT_DIR="elepay_diag_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$OUT_DIR"/{runtime,flutter,gradle,build}
    PKG=$(detect_app_pkg)
    echo "device: $DEVICE_ID"
    echo "detected example applicationId: ${PKG:-<not found>}"

    # ---- 1. runtime: logs + system state ----
    # logcat is the diagnostic core and must not fail silently; the dumpsys calls below are best-effort.
    "${ADB[@]}" logcat -d -v threadtime -b all    > "$OUT_DIR/runtime/logcat.txt"               2>&1
    "${ADB[@]}" shell dumpsys activity activities > "$OUT_DIR/runtime/activity_activities.txt"  2>&1 || true
    "${ADB[@]}" shell dumpsys activity recents    > "$OUT_DIR/runtime/activity_recents.txt"     2>&1 || true
    "${ADB[@]}" shell dumpsys activity top        > "$OUT_DIR/runtime/activity_top.txt"         2>&1 || true
    "${ADB[@]}" shell dumpsys window              > "$OUT_DIR/runtime/window.txt"               2>&1 || true
    "${ADB[@]}" shell getprop                     > "$OUT_DIR/runtime/getprop.txt"              2>&1 || true
    "${ADB[@]}" shell wm size                     > "$OUT_DIR/runtime/wm_size.txt"              2>&1 || true
    "${ADB[@]}" shell wm density                  > "$OUT_DIR/runtime/wm_density.txt"           2>&1 || true
    "${ADB[@]}" shell cmd activity get-config     > "$OUT_DIR/runtime/activity_get_config.txt"  2>&1 || true

    if [[ -n "$PKG" ]]; then
      "${ADB[@]}" shell dumpsys package "$PKG"    > "$OUT_DIR/runtime/package_example.txt"      2>&1 || true
      "${ADB[@]}" shell pm path "$PKG"            > "$OUT_DIR/runtime/example_apk_path.txt"     2>&1 || true
    fi

    # au PAY package: discover candidates then dump each
    # The actual au PAY package id looks like jp.auone.aupay; the keyword set must cover aupay / auone / kddi
    "${ADB[@]}" shell pm list packages -f | grep -iE "aupay|auone|kddi" \
      > "$OUT_DIR/runtime/aupay_candidates.txt" 2>&1 || true
    while IFS= read -r line; do
      cand="${line##*=}"
      [[ -z "$cand" ]] && continue
      "${ADB[@]}" shell dumpsys package "$cand" \
        > "$OUT_DIR/runtime/package_${cand}.txt" 2>&1 || true
    done < "$OUT_DIR/runtime/aupay_candidates.txt"

    # ---- 2. flutter env + deps ----
    flutter --version > "$OUT_DIR/flutter/version.txt"  2>&1 || true
    flutter doctor -v > "$OUT_DIR/flutter/doctor.txt"   2>&1 || true
    flutter pub deps  > "$OUT_DIR/flutter/pub_deps.txt" 2>&1 || true
    cp pubspec.yaml   "$OUT_DIR/flutter/pubspec.yaml"   2>/dev/null || true
    cp pubspec.lock   "$OUT_DIR/flutter/pubspec.lock"   2>/dev/null || true

    # ---- 3. gradle build files + dependency tree ----
    for f in \
      android/build.gradle android/build.gradle.kts \
      android/settings.gradle android/settings.gradle.kts \
      android/app/build.gradle android/app/build.gradle.kts \
      android/gradle.properties \
      android/gradle/wrapper/gradle-wrapper.properties
    do
      [[ -f "$f" ]] && cp "$f" "$OUT_DIR/gradle/$(echo "$f" | tr '/' '_')"
    done
    if [[ -x android/gradlew ]]; then
      (cd android && ./gradlew :app:dependencies --configuration debugRuntimeClasspath) \
        > "$OUT_DIR/gradle/app_dependencies_debug_runtime.txt" 2>&1 || true
    fi

    # ---- 4. merged manifest + APK manifest ----
    # In a Flutter project, AGP intermediates land under <example>/build/app/intermediates/...
    # instead of <example>/android/app/build/..., so both roots must be searched.
    # Note: when a find root does not exist, find returns non-zero; combined with
    # set -euo pipefail the assignment aborts the script (reproducible on macOS bash 3.2,
    # and newer bash can still trip pipefail), so a `|| true` guard is required here.
    # Do NOT drop it -- otherwise the zip step gets swallowed and the customer never receives a zip.
    SEARCH_ROOTS=()
    [[ -d build ]]            && SEARCH_ROOTS+=(build)
    [[ -d android/app/build ]] && SEARCH_ROOTS+=(android/app/build)
    if (( ${#SEARCH_ROOTS[@]} > 0 )); then
      MERGED=$(find "${SEARCH_ROOTS[@]}" -path '*intermediates/merged_manifests*' -name 'AndroidManifest.xml' 2>/dev/null | head -n1 || true)
      [[ -n "$MERGED" ]] && cp "$MERGED" "$OUT_DIR/build/merged_AndroidManifest.xml" || true

      # Flutter debug APK is produced at <example>/build/app/outputs/flutter-apk/app-debug.apk by default
      APK=$(find "${SEARCH_ROOTS[@]}" -name 'app-debug.apk' 2>/dev/null | head -n1 || true)
    else
      MERGED=""
      APK=""
    fi
    if [[ -n "$APK" ]]; then
      # aapt is not guaranteed to be on the customer's PATH; fall back in order: aapt -> aapt2 -> binary AXML
      if command -v aapt >/dev/null 2>&1; then
        aapt dump xmltree "$APK" AndroidManifest.xml > "$OUT_DIR/build/apk_AndroidManifest.txt" 2>&1 || true
        aapt dump badging "$APK"                    > "$OUT_DIR/build/apk_badging.txt"          2>&1 || true
      elif command -v aapt2 >/dev/null 2>&1; then
        aapt2 dump xmltree --file AndroidManifest.xml "$APK" > "$OUT_DIR/build/apk_AndroidManifest.txt" 2>&1 || true
        aapt2 dump badging "$APK"                            > "$OUT_DIR/build/apk_badging.txt"         2>&1 || true
      fi
      # Binary AXML fallback; post-process on the dev side with apkanalyzer / androguard
      unzip -p "$APK" AndroidManifest.xml > "$OUT_DIR/build/apk_AndroidManifest.bin" 2>/dev/null || true
    fi

    zip -rq "$OUT_DIR.zip" "$OUT_DIR"
    echo "$OUT_DIR.zip"
    ;;
  *)
    usage
    ;;
esac
