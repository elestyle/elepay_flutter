import Flutter
import UIKit
import ElePay

fileprivate struct ElepayResultWrapper {
    let state: String
    let paymentId: String?

    var asDictionary: Dictionary<String, Any> {
        return [
            "state": state,
            "paymentId": paymentId ?? "null"
        ]
    }
}

fileprivate struct ElepayErrorData {
    let code: String
    let reason: String
    let message: String

    var asDictionary: Dictionary<String, String> {
        return [
            "code": code,
            "reason": reason,
            "message": message
        ]
    }
}

public class SwiftElepayFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "elepay_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftElepayFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as? [String: Any] ?? [:]

        switch call.method {
        case "initElepay":
            initElepay(configs: params)
            result(nil)

        case "changeLanguage":
            changeLanguage(params)
            result(nil)
            break

        case "handlePayment":
            let payload = params["payload"] as? String ?? ""
            handlePayment(payload: payload, resultHandler: result)
            break

        default:
            break
        }
    }

    public func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ElePay.handleOpenURL(url, options: options)
    }

    private func initElepay(configs: [String: Any]) {
        guard !configs.isEmpty else { return }

        let publicKey = configs["publicKey"] as? String ?? ""
        let apiUrl = configs["apiUrl"] as? String ?? ""
        ElePay.initApp(key: publicKey, apiURLString: apiUrl)

        performChangingLanguage(langConfig: configs)
    }

    private func changeLanguage(_ langConfig: [String: Any]) {
        performChangingLanguage(langConfig: langConfig)
    }

    private func handleOpenUrlString(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return ElePay.handleOpenURL(url)
    }

    private func handlePayment(payload: String, resultHandler: @escaping FlutterResult) {
        let sender = UIApplication.shared.keyWindow?.rootViewController ?? UIViewController()
        _ = ElePay.handlePayment(chargeJSON: payload, viewController: sender) { result in
            switch result {
            case .succeeded(let paymentId):
                let res = ElepayResultWrapper(state: "succeeded", paymentId: paymentId)
                resultHandler(res.asDictionary)
            case .cancelled(let paymentId):
                let res = ElepayResultWrapper(state: "cancelled", paymentId: paymentId)
                resultHandler(res.asDictionary)
            case .failed(let paymentId, let error):
                let err: ElepayErrorData
                switch error {
                case .alreadyMakingPayment(_):
                    err = ElepayErrorData(code: "", reason: "Already making payment", message: "")
                case .invalidPayload(let errorCode, let message):
                    err = ElepayErrorData(code: errorCode, reason: "Invalid payload", message: message)
                case .paymentFailure(let errorCode, let message):
                    err = ElepayErrorData(code: errorCode, reason: "Payment failure", message: message)
                case .paymentMethodNotInitialized(let errorCode, let message):
                    err = ElepayErrorData(code: errorCode, reason: "Payment method not initialized", message: message)
                case .serverError(let errorCode, let message):
                    err = ElepayErrorData(code: errorCode, reason: "Server error", message: message)
                case .systemError(let errorCode, let message):
                    err = ElepayErrorData(code: errorCode, reason: "System error", message: message)
                case .unsupportedPaymentMethod(let errorCode, let paymentMethod):
                    err = ElepayErrorData(code: errorCode, reason: "Unsupported payment method", message: paymentMethod)
                @unknown default:
                    err = ElepayErrorData(code: "-1", reason: "Undefined reason", message: "Unknonw error")
                    break
                }

                var res = ElepayResultWrapper(state: "failed", paymentId: paymentId).asDictionary
                res["error"] = err.asDictionary
                resultHandler(res)
            @unknown default:
                break
            }
        }
    }

    private func performChangingLanguage(langConfig: [String: Any]) {
        let langCodeStr = langConfig["languageKey"] as? String ?? ""
        if let langCode = retrieveLanguageCode(from: langCodeStr) {
            ElePayLocalization.shared.switchLanguage(code: langCode)
        }
    }

    private func retrieveLanguageCode(from langStr: String) -> ElePayLanguageCode? {
        let ret: ElePayLanguageCode?
        switch (langStr.lowercased()) {
            case "english": ret = .en
            case "simplifiedchinise": ret = .cn
            case "traditionalchinese": ret = .tw
            case "japanese": ret = .ja
            default: ret = nil
        }
        return ret
    }
}
