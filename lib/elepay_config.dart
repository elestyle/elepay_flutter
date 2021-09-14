part of elepay_flutter;

/// Enumerations defined for localization supported by elepay SDK.
enum ElepayLanguageKey {
  english,
  simplifiedChinise,
  traditionalChinese,
  japanese
}

extension ElepayLanguageKeyExt on ElepayLanguageKey {
  String get stringPresentation {
    switch (this) {
      case ElepayLanguageKey.english:
        return "english";
      case ElepayLanguageKey.simplifiedChinise:
        return "simplifiedChinise";
      case ElepayLanguageKey.traditionalChinese:
        return "traditionalChinese";
      case ElepayLanguageKey.japanese:
        return "japanese";
    }
  }
}

/// Enumerations defined for theme supported by elepay SDK.
/// Note: currenlty only Android module supports theme changing.
enum ElepayTheme { light, dark, system }

extension ElepayThemeExt on ElepayTheme {
  String get stringPresentation {
    switch (this) {
      case ElepayTheme.light:
        return "light";
      case ElepayTheme.dark:
        return "dark";
      case ElepayTheme.system:
        return "system";
    }
  }
}

enum GooglePayEnvironment { test, production }

/// The configuration data used to initialize elepay SDK.
class ElepayConfiguration {
  /// The key that can be retrieved from your dashboard page.
  String publicKey;

  /// The url used as the base url when accessing remote resources/APIs.
  ///
  /// You can pass in your own server's url to make the whole resourecs completedly under your control.
  /// Normally, if you're using elepay's service, you should leave this parameter empty.
  String remoteHostBaseUrl;

  /// The environment of Google Pay.
  ///
  /// To use Google Pay, the app(apk) needs to be sent to Google for review.
  /// And it may take serveral steps to finish the review. During the review process, app(apk)
  /// needs to switch the environment individually.
  ///
  /// If the app do use Google Pay, leave this field `null`.
  GooglePayEnvironment? googlePayEnvironment;

  /// The language used by the elepay sdk.
  ///
  /// If not set, elepay SDK will use the system language.
  ElepayLanguageKey? languageKey;

  /// Construct the configuation data.
  ///
  /// Only the `publicKey` field is required. Others are all optional.
  ElepayConfiguration(this.publicKey,
      {this.remoteHostBaseUrl = "",
      this.googlePayEnvironment,
      this.languageKey});

  Map<String, String> get asMap {
    return {
      "publicKey": publicKey,
      "apiUrl": remoteHostBaseUrl,
      "googlePayEnvironment": googlePayEnvironment == GooglePayEnvironment.test
          ? "test"
          : "production",
      "languageKey": languageKey?.stringPresentation ?? "null"
    };
  }
}
