package io.elepay.sdk.elepay_flutter

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import jp.elestyle.androidapp.elepay.Elepay
import jp.elestyle.androidapp.elepay.ElepayConfiguration
import jp.elestyle.androidapp.elepay.ElepayError
import jp.elestyle.androidapp.elepay.ElepayResult
import jp.elestyle.androidapp.elepay.GooglePayEnvironment
import jp.elestyle.androidapp.elepay.activity.linepay.LinePayActivity
import jp.elestyle.androidapp.elepay.activity.paypay.PayPayActivity
import jp.elestyle.androidapp.elepay.utils.locale.LanguageKey

internal class ElepayFlutterMethodImpl : MethodChannel.MethodCallHandler,
    PluginRegistry.NewIntentListener {

    var currentActivity: Activity? = null

    override fun onNewIntent(intent: Intent?): Boolean {
        val uri = intent?.data ?: return false
        val sender = currentActivity ?: return false

        val newIntent = when (uri.host) {
            "linepay" -> Intent(sender, LinePayActivity::class.java)
            "paypay" -> Intent(sender, PayPayActivity::class.java)

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

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initElepay" -> {
                initElepay(call)
                result.success(null)
            }

            "changeLanguage" -> {
                changeLanguage(call)
                result.success(null)
            }

            "handlePayment" -> handlePayment(call, result)

            else -> result.notImplemented()
        }
    }

    @SuppressLint("DefaultLocale")
    private fun initElepay(call: MethodCall) {
        val publicKey = call.argument<String>("publicKey") ?: ""
        val apiUrl = call.argument<String>("apiUrl") ?: ""
        val googleEnv = call.argument<String>("googlePayEnvironment")?.let {
            if (it.toLowerCase().contains("test")) GooglePayEnvironment.TEST
            else GooglePayEnvironment.PRODUCTION
        }
        val languageKey = retrieveLanguageKey(call.argument<String>("languageKey") ?: "")
        Elepay.setup(ElepayConfiguration(publicKey, apiUrl, googleEnv, languageKey))
    }

    private fun changeLanguage(call: MethodCall) {
        val languageKey = retrieveLanguageKey(call.argument<String>("languageKey") ?: "")
        Elepay.changeLanguageKey(languageKey)
    }

    @SuppressLint("DefaultLocale")
    private fun retrieveLanguageKey(languageKeyStr: String): LanguageKey =
        when (languageKeyStr.toLowerCase()) {
            "english" -> LanguageKey.English
            "simplifiedchinise" -> LanguageKey.SimplifiedChinise
            "traditionalchinese" -> LanguageKey.TraditionalChinese
            "japanese" -> LanguageKey.Japanese
            else -> LanguageKey.System
        }

    private fun handlePayment(call: MethodCall, resultHandler: Result) {
        if (currentActivity == null) {
            throw IllegalStateException("Invoked without any available Activitys. Make sure call this method while an Activity instance is valid.")
        }
        // empty payload will trigger error.
        val payload = call.argument<String>("payload") ?: ""
        Elepay.processPayment(
            chargeDataString = payload,
            fromActivity = currentActivity!!
        ) { result ->
            when (result) {
                is ElepayResult.Succeeded ->
                    postResult(
                        ElepayResultWrapper("succeeded", result.paymentId).asMap,
                        resultHandler
                    )

                is ElepayResult.Canceled ->
                    postResult(
                        ElepayResultWrapper("cancelled", result.paymentId).asMap,
                        resultHandler
                    )

                is ElepayResult.Failed -> {
                    val elepayErr = when (val error = result.error) {
                        is ElepayError.UnsupportedPaymentMethod ->
                            ElepayErrData("", "Unsupported payment method", error.paymentMethod)

                        is ElepayError.AlreadyMakingPayment ->
                            ElepayErrData("", "Already making payment", error.paymentId)

                        is ElepayError.InvalidPayload ->
                            ElepayErrData(error.errorCode, "Invalid payload", error.message)

                        is ElepayError.UninitializedPaymentMethod ->
                            ElepayErrData(
                                error.errorCode,
                                "Uninitialized payment method",
                                "${error.paymentMethod} ${error.message}"
                            )

                        is ElepayError.SystemError ->
                            ElepayErrData(error.errorCode, "System Error", error.message)

                        is ElepayError.PaymentFailure ->
                            ElepayErrData(error.errorCode, "Payment failure", error.message)

                        is ElepayError.PermissionRequired ->
                            ElepayErrData(
                                "",
                                "Permissions required",
                                error.permissions.joinToString(", ")
                            )
                    }
                    val resMap = ElepayResultWrapper("failed", result.paymentId).asMap
                    resMap["error"] = elepayErr.asMap
                    // Althought this is an error processing, still invoke the `success` callback
                    // since we need to pass the whole data to the caller.
                    // `resultHandler.error` actually triggeers a `PlatformExecption` which is not
                    // properly as the elepay SDK processing's callback result.
                    postResult(resMap, resultHandler)
                }
            }
        }
    }

    private fun postResult(res: HashMap<String, Any>, resultHandler: Result) {
        currentActivity?.runOnUiThread {
            resultHandler.success(res)
        }
    }
}