import Flutter
import UIKit
import ElepaySDK

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

        case "changeTheme":
            changeTheme(params)
            result(nil)

        case "handleCharge":
            let payload = params["payload"] as? String ?? ""
            DispatchQueue.main.async { [weak self] in
                self?.processCharge(payload: payload, resultHandler: result)
            }

        case "handleSource":
            let payload = params["payload"] as? String ?? ""
            DispatchQueue.main.async { [weak self] in
                self?.processSource(payload: payload, resultHandler: result)
            }

        case "checkout":
            let payload = params["payload"] as? String ?? ""
            DispatchQueue.main.async { [weak self] in
                self?.processCheckout(payload: payload, resultHandler: result)
            }

        default:
            break
        }
    }

    public func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        Elepay.handleOpenURL(url, options: options)
    }

    private func initElepay(configs: [String: Any]) {
        guard !configs.isEmpty else { return }

        let publicKey = configs["publicKey"] as? String ?? ""
        let apiUrl = configs["apiUrl"] as? String ?? ""
        Elepay.initApp(key: publicKey, apiURLString: apiUrl)

        performChangingLanguage(langConfig: configs)
    }

    private func changeLanguage(_ langConfig: [String: Any]) {
        performChangingLanguage(langConfig: langConfig)
    }

    private func performChangingLanguage(langConfig: [String: Any]) {
        let langCodeStr = langConfig["languageKey"] as? String ?? ""
        if let langCode = retrieveLanguageCode(from: langCodeStr) {
            ElepayLocalization.shared.switchLanguage(code: langCode)
        }
    }

    private func retrieveLanguageCode(from langStr: String) -> ElepayLanguageCode? {
        let ret: ElepayLanguageCode?
        switch (langStr.lowercased()) {
        case "english": ret = .english
        case "simplifiedchinise": ret = .simplifiedChinese
        case "traditionalchinese": ret = .traditionalChinese
        case "japanese": ret = .japanese
        default: ret = nil
        }
        return ret
    }

    private func changeTheme(_ themeConfig: [String: Any]) {
        performChangingTheme(themeConfig: themeConfig)
    }

    private func performChangingTheme(themeConfig: [String: Any]) {
        let themeName = themeConfig["theme"] as? String ?? ""
        if #available(iOS 13, *) {
            Elepay.userInterfaceStyle = retrieveUserInterface(from: themeName)
        } else {
            print("theme is only supported on iOS 13 and above.")
        }
    }

    @available(iOS 12.0, *)
    private func retrieveUserInterface(from themeName: String) -> UIUserInterfaceStyle {
        switch (themeName.lowercased()) {
        case "light": return .light
        case "dark": return .dark
        default: return .unspecified
        }
    }

    private func processCharge(payload: String, resultHandler: @escaping FlutterResult) {
        let sender = UIApplication.shared.keyWindow?.rootViewController ?? UIViewController()
        _ = Elepay.handlePayment(chargeJSON: payload, viewController: sender) { [weak self] result in
            self?.processElepayResult(result, resultHandler: resultHandler)
        }
    }

    private func processSource(payload: String, resultHandler: @escaping FlutterResult) {
        let sender = UIApplication.shared.keyWindow?.rootViewController ?? UIViewController()
        _ = Elepay.handleSource(sourceJSON: payload, viewController: sender) { [weak self] result in
            self?.processElepayResult(result, resultHandler: resultHandler)
        }
    }

    private func processCheckout(payload: String, resultHandler: @escaping FlutterResult) {
        let sender = UIApplication.shared.keyWindow?.rootViewController ?? UIViewController()
        Elepay.checkout(checkoutJSONString: payload, from: sender) { [weak self] result in
            self?.processElepayResult(result, resultHandler: resultHandler)
        }
    }

    private func processElepayResult(
        _ result: ElepayResult,
        resultHandler: @escaping FlutterResult
    ) {
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
