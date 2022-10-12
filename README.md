# elepay_flutter

[elepay](https://elepay.io/) native SDK(Android/iOS) wrapper for Flutter.

## Requirement

This plugin requires Flutter 3.0.0 or above.

> From version 3.0.0, the minSdk 23 is required for Android target building, and iOS 12/swift 5.7 is the minimum version required for iOS target building.

## Setup

Add the following dependencies in your `pubspec.yaml` file:

```yaml
dependencies:
  elepay_flutter: ^${latestVersion}
```

## Usage

* Import `package:elepay_flutter/elepay_flutter.dart`.
* Initialize the elepay SDK via `ElepayFlutter.initElepay`.
* Pass the data(a JSON object string) to one of the `ElepayFlutter` handling method and process the `ElepayResult` data.

Example:

```dart
import 'package:elepay_flutter/elepay_flutter.dart';

...

// Initialize the elepay SDK. Only the first parameter `publicKey` is required.
// The following example also change the default localization used by elepay SDK UI to `japanese`.
var config = ElepayConfiguration(
  currentConfig['pk'],
  languageKey: ElepayLanguageKey.japanese);
ElepayFlutter.initElepay(config);

// Addtionally, you can change the default localization used by elepay SDK UI by calling the
// following method.
// By default, elepay SDK uses the system language settings if possible, and fallbacks to English.
// Note that changing language must be called after elepaySDK is initialized and before the
// invoking of `ElepayFlutter.handlePayment`.
ElepayFlutter.changeLanguage(ElepayLanguageKey.japanese);

// And the color theme of the elepay SDK UI could be specified as following code.
// By default, elepay SDK uses the app's or system's theme color.
// Note that on iOS platform, theme changing is only supported on iOS 13 and above.
ElepayFlutter.changeTheme(ElepayTheme.dark)

...

// Create the charge data(a JSON object) by invoking elepay API
// Then transform the data to String instance and pass it to the elepay SDK to process the payment.
//
// elepay SDK also supports source and checkout processing, related methods are `handleSource` and
// `checkout`.
var res = await ElepayFlutter.handlePayment(chargePayload);
// Handle the result data.
if (res is ElepayResultSucceeded) {
  print('succeed. ' + res.paymentId);
} else if (res is ElepayResultFailed) {
  print('failed: ' + res.paymentId + ', code=' + res.code + ', reason=' + res.reason + ', message=' + res.message);
} else if (res is ElepayResultCancelled) {
  print('cancelled. ' + res.paymentId);
}
```

## Native callbacks

Some payment methods require to process the payment in their native app. For those payment methods, you need to config your app to be able to handle the callback.
> Check the [elepay document](https://developer.elepay.io/docs/summary) to see which methods require the extra configuration.

### Android

Add the following code to the Activity which you used to load `ElepayFlutter` in file `AndroidManifest.xml`.
> Normally it's `MainActivity`

```xml
<intent-filter>
    <data android:scheme="Your-elepay-app-scheme" />
    <action android:name="android.intent.action.VIEW" />

    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
</intent-filter>
```

### iOS

URL schemes should be configured. Please refer to the [elepay iOS SDK document](https://developer.elepay.io/docs/ios-sdk#1-url-scheme-%E3%81%AE%E8%BF%BD%E5%8A%A0) for details.

## Miscellaneous

1. On flutter 2.5.0 with Android platform, when uses `checkout` and the payment processing requires to jump out to the other app or Activity, after returned back to your app, your app may show a black background screen. You could try to add the following code to your app's MainActivity to workaround this issue.
```kotlin
override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
    return BackgroundMode.transparent
}
```
You may refer to this [link](https://github.com/flutter/flutter/issues/59552) to see more details.
