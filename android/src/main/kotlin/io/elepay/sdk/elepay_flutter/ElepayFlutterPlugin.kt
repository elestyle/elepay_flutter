package io.elepay.sdk.elepay_flutter

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import jp.elestyle.androidapp.elepay.activity.linepay.LinePayActivity
import jp.elestyle.androidapp.elepay.activity.merpay.MerpayActivity
import jp.elestyle.androidapp.elepay.activity.paypay.PayPayActivity

/** ElepayFlutterPlugin */
class ElepayFlutterPlugin : FlutterPlugin, ActivityAware, PluginRegistry.NewIntentListener {
    private var channel: MethodChannel? = null
    private var methodImpl: ElepayFlutterMethodImpl? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        setupChannel(flutterPluginBinding.binaryMessenger, null)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        cleanUpChannel()
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @Suppress("unused")
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = ElepayFlutterPlugin()
            plugin.setupChannel(registrar.messenger(), registrar.activity())
            registrar.addNewIntentListener(plugin)
        }
    }

    override fun onDetachedFromActivity() {
        methodImpl?.currentActivity = null
        channel?.setMethodCallHandler(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        methodImpl?.currentActivity = binding.activity
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        methodImpl?.currentActivity = binding.activity
        channel?.setMethodCallHandler(methodImpl)
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        methodImpl?.currentActivity = null
    }

    override fun onNewIntent(intent: Intent?): Boolean {
        val uri = intent?.data ?: return false
        val sender = methodImpl?.currentActivity ?: return false

        val newIntent = when (uri.host) {
            "linepay" -> Intent(sender, LinePayActivity::class.java)
            "paypay" -> Intent(sender, PayPayActivity::class.java)
            "merpay" -> Intent(sender, MerpayActivity::class.java)

            else -> null
        }

        return if (newIntent == null) {
            false
        } else {
            newIntent.data = uri
            sender.startActivity(newIntent)
            true
        }
    }

    private fun setupChannel(messenger: BinaryMessenger, activity: Activity?) {
        channel = MethodChannel(messenger, "elepay_flutter")
        methodImpl = ElepayFlutterMethodImpl().apply {
            this.currentActivity = activity
        }
        channel!!.setMethodCallHandler(methodImpl)
    }

    private fun cleanUpChannel() {
        channel = null
        methodImpl = null
    }
}
