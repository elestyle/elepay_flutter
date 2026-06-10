package com.example.elepay_flutter_example

import android.app.ActivityManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import jp.elestyle.androidapp.elepay.activity.ElepayCallbackActivity

class OverriddenCallbackActivity : ElepayCallbackActivity() {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var delayFinishForProof = false
    private var finishRequestedDuringProof = false

    override fun onCreate(savedInstanceState: Bundle?) {
        logLifecycle("onCreate", intent)
        logEnvironment()
        super.onCreate(savedInstanceState)
        installDiagnosticUi()
    }

    override fun onNewIntent(intent: Intent) {
        logLifecycle("onNewIntent", intent)
        super.onNewIntent(intent)
    }

    override fun onStart() {
        logLifecycle("onStart", intent)
        super.onStart()
    }

    override fun onResume() {
        logLifecycle("onResume", intent)
        super.onResume()
    }

    override fun onPause() {
        logLifecycle("onPause", intent)
        super.onPause()
    }

    override fun onStop() {
        logLifecycle("onStop", intent)
        super.onStop()
    }

    override fun onDestroy() {
        logLifecycle("onDestroy", intent)
        super.onDestroy()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        log("##### onWindowFocusChanged hasFocus=$hasFocus taskId=$taskId #####")
        super.onWindowFocusChanged(hasFocus)
    }

    override fun onTopResumedActivityChanged(isTopResumedActivity: Boolean) {
        log("##### onTopResumedActivityChanged isTop=$isTopResumedActivity taskId=$taskId #####")
        super.onTopResumedActivityChanged(isTopResumedActivity)
    }

    override fun finish() {
        if (delayFinishForProof) {
            finishRequestedDuringProof = true
            log("finish suppressed by one-shot harness; callback page stays visible if host restore fails")
            return
        }
        logLifecycle("finish", intent)
        super.finish()
    }

    /**
     * Replicates SDK 4.0.1 ElepayCallbackActivity.returnToHostApp logic, logging every step.
     * Does NOT delegate to super; then runs one-shot proof paths to validate 4.0.2 candidate fixes.
     */
    override fun returnToHostApp() {
        val startedAt = SystemClock.uptimeMillis()
        delayFinishForProof = PROVE_FIX_AFTER_LOGGING
        log("===== ENTER returnToHostApp taskId=$taskId isTaskRoot=$isTaskRoot intent=${intent.brief()} =====")

        // ---- Step 1: BEFORE snapshot ----
        snapshotTasks("BEFORE")

        // ---- Step 2: replicate moveHostLauncherTaskToFront() ----
        val am = getSystemService(ActivityManager::class.java)
        log("am=$am")

        val apps = runCatching { am?.appTasks }
            .onFailure { log("get appTasks threw", it) }
            .getOrNull()
        log("appTasks size=${apps?.size}")

        val launcherTask = apps?.firstOrNull { task ->
            val bi = runCatching { task.taskInfo.baseIntent }.getOrNull()
            val isMain = bi?.action == Intent.ACTION_MAIN
            val hasLauncher = bi?.hasCategory(Intent.CATEGORY_LAUNCHER) == true
            log("  filter task ${runCatching { task.taskInfo.taskId }.getOrNull()} " +
                "baseIntent=${bi.brief()} " +
                "-> isMain=$isMain hasLauncher=$hasLauncher")
            isMain && hasLauncher
        }
        log("launcherTask matched id=${launcherTask?.let { runCatching { it.taskInfo.taskId }.getOrNull() }}")

        if (launcherTask != null) {
            // ---- Step 3a: call moveToFront ----
            log(">>> calling launcherTask.moveToFront()")
            runCatching {
                launcherTask.moveToFront()
                log("<<< moveToFront returned (void)")
            }.onFailure { log("moveToFront threw", it) }

            // Do not block SDK finish() timing. This delayed snapshot is diagnostic only.
            scheduleSnapshot("AFTER moveToFront +150ms", startedAt)
        } else {
            // ---- Step 3b: replicate relaunchHostApp() fallback ----
            log("launcherTask null -> fallback relaunchHostApp")
            runCatching {
                val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                log("getLaunchIntentForPackage=${launchIntent.brief()}")
                launchIntent?.addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                )
                launchIntent?.let {
                    startActivity(it)
                    log("relaunchHostApp startActivity issued")
                }
            }.onFailure { log("relaunchHostApp threw", it) }
            scheduleSnapshot("AFTER relaunchHostApp +150ms", startedAt)
        }

        scheduleOneShotProofs(startedAt)
        log("===== EXIT returnToHostApp =====")
    }

    private fun scheduleSnapshot(label: String, startedAt: Long) {
        mainHandler.postDelayed({
            log("delayed snapshot fired +${SystemClock.uptimeMillis() - startedAt}ms after returnToHostApp enter")
            snapshotTasks(label)
        }, 150L)
    }

    private fun scheduleOneShotProofs(startedAt: Long) {
        if (!PROVE_FIX_AFTER_LOGGING) return

        mainHandler.postDelayed({
            startHostWithPackageLaunchIntent("PROOF_A package launchIntent", startedAt)
        }, 250L)

        mainHandler.postDelayed({
            startHostWithResolvedLauncher("PROOF_B explicit launcher component", startedAt)
        }, 900L)

        mainHandler.postDelayed({
            log(">>> PROOF_C waiting manual button tap if diagnostic page is still visible +${SystemClock.uptimeMillis() - startedAt}ms")
            snapshotTasks("PROOF_C waiting manual tap")
        }, 1600L)

        mainHandler.postDelayed({
            postReturnNotification(startedAt)
        }, 2200L)

        mainHandler.postDelayed({
            log(">>> FINAL harness checkpoint +${SystemClock.uptimeMillis() - startedAt}ms finishRequested=$finishRequestedDuringProof")
            snapshotTasks("FINAL harness checkpoint")
        }, 6000L)
    }

    private fun startHostWithPackageLaunchIntent(label: String, startedAt: Long) {
        log(">>> $label +${SystemClock.uptimeMillis() - startedAt}ms")
        runCatching {
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            log("$label getLaunchIntentForPackage=${launchIntent.brief()}")
            launchIntent?.addReturnFlags()
            if (launchIntent == null) {
                log("$label skipped: launchIntent is null")
            } else {
                startActivity(launchIntent)
                log("$label startActivity issued")
            }
        }.onFailure { log("$label startActivity threw", it) }
        scheduleSnapshot("AFTER $label +300ms", startedAt)
    }

    private fun startHostWithResolvedLauncher(label: String, startedAt: Long) {
        log(">>> $label +${SystemClock.uptimeMillis() - startedAt}ms")
        runCatching {
            val launchIntent = resolveExplicitLauncherIntent()
            log("$label resolved=${launchIntent.brief()}")
            if (launchIntent == null) {
                log("$label skipped: explicit launcher is null")
            } else {
                startActivity(launchIntent)
                log("$label startActivity issued")
            }
        }.onFailure { log("$label startActivity threw", it) }
        scheduleSnapshot("AFTER $label +300ms", startedAt)
    }

    private fun installDiagnosticUi() {
        val button = Button(this).apply {
            text = "RETURN HOST PROBE"
            setOnClickListener {
                log(">>> PROOF_C manual button clicked")
                startHostWithResolvedLauncher("PROOF_C manual explicit launcher", SystemClock.uptimeMillis())
            }
        }
        val text = TextView(this).apply {
            text = "elepay diagnostic callback\nIf this screen remains, tap the button once."
            gravity = Gravity.CENTER
            setTextColor(Color.BLACK)
            textSize = 18f
        }
        setContentView(
            LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                setBackgroundColor(Color.WHITE)
                setPadding(32, 32, 32, 32)
                addView(text)
                addView(button)
            }
        )
    }

    private fun postReturnNotification(startedAt: Long) {
        log(">>> PROOF_D post return notification +${SystemClock.uptimeMillis() - startedAt}ms")
        runCatching {
            val launchIntent = resolveExplicitLauncherIntent()
            log("PROOF_D notification intent=${launchIntent.brief()}")
            if (launchIntent == null) return@runCatching

            val pendingIntent = PendingIntent.getActivity(
                this,
                NOTIFICATION_ID,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val nm = getSystemService(NotificationManager::class.java) ?: run {
                log("PROOF_D skipped: NotificationManager is null")
                return@runCatching
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                nm.createNotificationChannel(
                    NotificationChannel(
                        NOTIFICATION_CHANNEL_ID,
                        "elepay diagnostic",
                        NotificationManager.IMPORTANCE_HIGH
                    )
                )
            }
            val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(this)
            }
                .setSmallIcon(applicationInfo.icon)
                .setContentTitle("elepay diagnostic return")
                .setContentText("Tap to return to the example app")
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .build()
            nm.notify(NOTIFICATION_ID, notification)
            log("PROOF_D notification posted")
        }.onFailure {
            log("PROOF_D notification threw", it)
        }
    }

    @Suppress("DEPRECATION")
    private fun resolveExplicitLauncherIntent(): Intent? {
        val query = Intent(Intent.ACTION_MAIN)
            .addCategory(Intent.CATEGORY_LAUNCHER)
            .setPackage(packageName)
        val matches = packageManager.queryIntentActivities(query, 0)
        log("resolve launcher matches=${matches.map { it.activityInfo.packageName + "/" + it.activityInfo.name }}")
        val ai = matches.firstOrNull()?.activityInfo ?: return null
        return Intent(Intent.ACTION_MAIN)
            .addCategory(Intent.CATEGORY_LAUNCHER)
            .setComponent(ComponentName(ai.packageName, ai.name))
            .addReturnFlags()
    }

    private fun Intent.addReturnFlags(): Intent = apply {
        addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
        )
    }

    private fun snapshotTasks(label: String) {
        log("--- TASK SNAPSHOT [$label] ---")
        runCatching {
            getSystemService(ActivityManager::class.java)?.appTasks
                ?.forEachIndexed { idx, t ->
                    runCatching {
                        val info = t.taskInfo
                        val bi = info.baseIntent
                        log("  task[$idx] id=${info.taskId} " +
                            "baseIntent=${bi.brief()} num=${info.numActivities} " +
                            "top=${info.topActivity}")
                    }.onFailure {
                        log("snapshot task[$idx] threw", it)
                    }
                }
        }.onFailure {
            log("snapshotTasks[$label] threw", it)
        }
        log("--- /SNAPSHOT [$label] ---")
    }

    @Suppress("DEPRECATION")
    private fun logEnvironment() {
        log("device manufacturer=${Build.MANUFACTURER} model=${Build.MODEL} sdk=${Build.VERSION.SDK_INT}")
        log("build fingerprint=${Build.FINGERPRINT}")
        log("package=$packageName callbackComponent=$componentName")
        runCatching {
            val callbackInfo = packageManager.getActivityInfo(componentName, 0)
            log("callbackActivity launchMode=${callbackInfo.launchMode} taskAffinity=${callbackInfo.taskAffinity} theme=${callbackInfo.theme}")
        }.onFailure { log("getActivityInfo(callback) threw", it) }
        runCatching {
            log("package launchIntent=${packageManager.getLaunchIntentForPackage(packageName).brief()}")
        }.onFailure { log("getLaunchIntentForPackage threw", it) }
    }

    private fun logLifecycle(name: String, intent: Intent?) {
        log("##### $name taskId=$taskId isTaskRoot=$isTaskRoot intent=${intent.brief()} #####")
    }

    private fun Intent?.brief(): String {
        if (this == null) return "null"
        return "cmp=$component action=$action cats=$categories data=$data flags=0x${Integer.toHexString(flags)}"
    }

    companion object {
        private const val TAG = "OverriddenCBAct"
        private const val PROVE_FIX_AFTER_LOGGING = true
        private const val NOTIFICATION_ID = 9290
        private const val NOTIFICATION_CHANNEL_ID = "elepay_diag_return"
        private fun log(msg: String, tr: Throwable? = null) {
            val line = "t=${SystemClock.uptimeMillis()} $msg"
            if (tr == null) Log.d(TAG, line) else Log.d(TAG, line, tr)
        }
    }
}
