# elepay_flutter au PAY コールバック診断 - 2026.06.10

> Branch: `diag/DEV-9290-aupay-pixel3a`

## 1. 事象

- au PAY での支払い完了後、au PAY 内の「完了」ボタンをタップ → 画面が au PAY に留まったまま、ホストアプリが前面に復帰しない
  - 同じ操作で PayPay は正常に動作する → App scheme の設定は確実に正しい
  - お客様環境では必ず再現（お客様アプリ + elepay flutter example app）；弊社環境では実機 + エミュレータ + Android 11 / 12 + au PAY 10.7.2 のいずれでも再現せず
  - お客様の端末：Pixel 3a + Android 12 + au PAY 10.7.2
- logcat 上では deep link が `ElepayCallbackActivity` をトリガーしていることが確認できるが、ホストが起動されない

## 2. 操作手順（Pixel 3a 実機で実施）

### 2.1 example の起動

> プロジェクトの `__SCHEME__` の置換を完了（例：`ep5c81xxxxxx`）
> device id は `flutter devices` で取得（この id は以降 `<Pixel 3a device id>` として使用）
> example 起動成功後、`Setting` 画面で `elepay KEYS` の設定を完了（例：`pk_live_...`）
> scheme と keys は必ず同一の elepay dashboard app 設定に揃えること

```sh
git clone -b diag/DEV-9290-aupay-pixel3a https://github.com/elestyle/elepay_flutter.git
cd elepay_flutter/example
flutter clean && flutter pub get && (cd android && ./gradlew clean) && flutter run --debug -d <Pixel 3a device id>
```

### 2.2 ログのクリア

別ターミナルを開き、`elepay_flutter/example` 配下で：

```sh
chmod +x collect_elepay_diag.sh && ./collect_elepay_diag.sh start <Pixel 3a device id>
```

> `adb logcat -c -b all` と等価

### 2.3 au PAY 決済のトリガー

1. example app で au PAY 決済を 1 回起動
2. au PAY 内で支払いを完了 → au PAY App 内の「完了」ボタンをタップ
3. タップ後 8 秒間待機

> 待機終了後、画面に表示されている内容に応じて該当する項目を 1 つ実行；以下のいずれにも該当しない場合も、そのまま 2.4 の zip 収集へ進む。

- **A. 画面が example app に復帰している**：通知バーに `elepay diagnostic return` が表示されていても、その通知は**タップしない**（タップすると今回の proof が汚染される）。そのまま 2.4 へ
- **B. 画面が `elepay diagnostic callback` 診断ページに留まっている**：`RETURN HOST PROBE` を 1 回タップし、5 秒待機してから 2.4 へ
- **C. 画面が au PAY に留まり、通知バーに `elepay diagnostic return` が表示されている**：該当通知を 1 回タップし、5 秒待機してから 2.4 へ
- **D. 画面が au PAY に留まり、通知バーに `elepay diagnostic return` が**表示されていない**：何も操作せず、そのまま 2.4 へ

### 2.4 実行ログの収集

```sh
./collect_elepay_diag.sh stop <Pixel 3a device id>
```

`elepay_diag_YYYYMMDD_HHMMSS.zip` が出力される。

## 3. 提出物チェックリスト

- `elepay_diag_*.zip`
- Pixel 3a のビルド情報スクリーンショット：**設定 → デバイス情報**（ビルド番号を含むページ全体）
- Pixel 3a 操作プロセスの動画：操作フロー全体をできる限り網羅すること

---

# elepay_flutter au PAY Callback Diagnostics — 2026.06.10

> Branch: `diag/DEV-9290-aupay-pixel3a`

## 1. Symptom

- After payment completes in au PAY, tapping the "Done" button inside au PAY → the screen stays on au PAY and the host app does not return to the foreground
  - The same flow works correctly with PayPay → the App scheme is definitely configured correctly
  - Reproduces 100% on the customer side (customer app + elepay flutter example app); on our side it cannot be reproduced on real device + emulator + Android 11 / 12 + au PAY 10.7.2
  - Customer device: Pixel 3a + Android 12 + au PAY 10.7.2
- logcat shows the deep link has triggered `ElepayCallbackActivity`, yet the host is not brought to the foreground

## 2. Procedure (perform on the Pixel 3a physical device)

### 2.1 Launch the example

> Finish replacing `__SCHEME__` in the project (e.g. `ep5c81xxxxxx`)
> Obtain the device id with `flutter devices` (this id is referred to below as `<Pixel 3a device id>`)
> After the example launches successfully, configure `elepay KEYS` under `Setting` (e.g. `pk_live_...`)
> The scheme and keys MUST come from the same elepay dashboard app configuration

```sh
git clone -b diag/DEV-9290-aupay-pixel3a https://github.com/elestyle/elepay_flutter.git
cd elepay_flutter/example
flutter clean && flutter pub get && (cd android && ./gradlew clean) && flutter run --debug -d <Pixel 3a device id>
```

### 2.2 Clear logs

In another terminal, under `elepay_flutter/example`:

```sh
chmod +x collect_elepay_diag.sh && ./collect_elepay_diag.sh start <Pixel 3a device id>
```

> Equivalent to `adb logcat -c -b all`

### 2.3 Trigger an au PAY payment

1. Initiate one au PAY payment from the example app
2. Complete the payment inside au PAY → tap the "Done" button in the au PAY app
3. Wait 8 seconds after tapping

> After the wait, pick the case that matches what you see on screen; if none of the cases below applies, also proceed directly to 2.4 to collect the zip.

- **A. The screen has returned to the example app**: even if `elepay diagnostic return` appears in the notification bar, **do not** tap that notification (tapping it would pollute this proof). Proceed directly to 2.4
- **B. The screen stays on the `elepay diagnostic callback` diagnostic page**: tap `RETURN HOST PROBE` once, wait 5 more seconds, then proceed to 2.4
- **C. The screen stays on au PAY and `elepay diagnostic return` appears in the notification bar**: tap that notification once, wait 5 more seconds, then proceed to 2.4
- **D. The screen stays on au PAY and `elepay diagnostic return` does NOT appear in the notification bar**: do nothing, proceed directly to 2.4

### 2.4 Collect run logs

```sh
./collect_elepay_diag.sh stop <Pixel 3a device id>
```

Outputs `elepay_diag_YYYYMMDD_HHMMSS.zip`.

## 3. Deliverables checklist

- `elepay_diag_*.zip`
- Pixel 3a build screenshot: **Settings → About phone** (the full page, including the build number)
- Video of the Pixel 3a operation: please cover the full operation flow as completely as possible

---

# elepay_flutter au PAY 回调诊断 - 2026.06.10

> Branch: `diag/DEV-9290-aupay-pixel3a`

## 1. 问题现象

- au PAY 付款完成后，在 au PAY 内点击「完成」按钮 → 屏幕停留在 au PAY，宿主 App 未回到前台
  - 同操作下 PayPay 表现正常 -> App scheme 一定配置正确了
  - 客户侧必现（客户 App + elepay flutter example app）；本司侧真机 + 模拟器 + Android 11 / 12 + au PAY 10.7.2 均无法复现
  - 客户机器：Pixel 3a + Android 12 + au PAY 10.7.2
- logcat 显示 deep link 已触发 `ElepayCallbackActivity`，但宿主未被唤起

## 2. 操作步骤（在 Pixel 3a 真机上执行）

### 2.1 跑起 example

> 完成工程 `__SCHEME__` 的替换(e.g. `ep5c81xxxxxx`)
> device id 用 `flutter devices` 获取(该 id 在后续会用到`<Pixel 3a device id>`)
> example 运行成功后，在 `Setting` 中完成 `elepay KEYS` 配置(e.g. `pk_live_...`)
> scheme 和 keys 必须保持同一个 elepay dashboard app 配置

```sh
git clone -b diag/DEV-9290-aupay-pixel3a https://github.com/elestyle/elepay_flutter.git
cd elepay_flutter/example
flutter clean && flutter pub get && (cd android && ./gradlew clean) && flutter run --debug -d <Pixel 3a device id>
```

### 2.2 清 log

另起终端，在 `elepay_flutter/example` 下：

```sh
chmod +x collect_elepay_diag.sh && ./collect_elepay_diag.sh start <Pixel 3a device id>
```

> 等同 `adb logcat -c -b all`

### 2.3 触发 au PAY 付款

1. 在 example app 中发起一次 au PAY 付款
2. 在 au PAY 内完成支付 → 点击 au PAY App 中的「完成」按钮
3. 点击后等待 8 秒

> 等待结束后按你看到的画面选对应一条执行；若不符合以下情形，也直接进入 2.4 收集 zip。

- **A. 屏幕已回到 example app**：即使通知栏出现 `elepay diagnostic return` 也**不要**点击该通知（点击会污染本次 proof），直接进入 2.4
- **B. 屏幕停在 `elepay diagnostic callback` 诊断页**：点击 1 次 `RETURN HOST PROBE`，再等待 5 秒后进入 2.4
- **C. 屏幕仍停在 au PAY 且通知栏出现 `elepay diagnostic return`**：点击该通知 1 次，再等待 5 秒后进入 2.4
- **D. 屏幕仍停在 au PAY 且通知栏**没有**出现 `elepay diagnostic return`**：不做任何操作，直接进入 2.4

### 2.4 收集运行 log

```sh
./collect_elepay_diag.sh stop <Pixel 3a device id>
```

输出 `elepay_diag_YYYYMMDD_HHMMSS.zip`。

## 3. 回执清单

- `elepay_diag_*.zip`
- Pixel 3a build 截图：**设置 → 关于手机**（完整页面，含 build 号）
- Pixel 3a 操作过程的视频：请尽可能的全面覆盖操作流程

