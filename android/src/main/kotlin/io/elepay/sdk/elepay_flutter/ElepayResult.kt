package io.elepay.sdk.elepay_flutter

internal data class ElepayErrData(val code: String, val reason: String, val message: String) {
    val asMap: HashMap<String, String>
        get() = hashMapOf<String, String>(
            "code" to code,
            "reason" to reason,
            "message" to message
        )
}

internal data class ElepayResultWrapper(val state: String, val paymentId: String?) {
    val asMap: HashMap<String, Any>
        get()  = hashMapOf(
            "state" to state,
            "paymentId" to (paymentId ?: "null")
        )
}