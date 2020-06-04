# elepay_flutter

[elepay](https://elepay.io/) native SDK(Android/iOS) wrapper for Flutter.

## Requirement

This plugin requires Flutter 1.12.0 with Dart SDK 2.6.0 and above.

## Setup

Add the following dependencies in your `pubspec.yaml` file:

```yaml
dependencies:
  elepay_flutter: ^${latestVersion}
```

## Usage

* Import `package:elepay_flutter/elepay_flutter.dart`.
* Initialize the elepay SDK via `ElepayFlutter.initELepay`.
* Pass the charge data(a JSON object string) to `ElepayFlutter.handlePayment` and process the `ElepayResult` data.

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

...

// Create the charge data(a JSON object) by invoking elepay API
// Then transform the data to String instance and pass it to the elepay SDK to processing payment.
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
> Check the [elepay document](https://developer.elepay.io/docs/%E6%A6%82%E8%A6%81) to see which methods require the extra configuration.

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
