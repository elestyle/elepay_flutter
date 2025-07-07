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
import jp.elestyle.androidapp.elepay.activity.ElepayCallbackActivity

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

    override fun onNewIntent(intent: Intent): Boolean {
        val uri = intent.data ?: return false
        val sender = methodImpl?.currentActivity ?: return false

        val newIntent = Intent(sender, ElepayCallbackActivity::class.java).apply {
            data = uri
        }
        sender.startActivity(newIntent)
        return true
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
