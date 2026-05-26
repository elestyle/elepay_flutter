# elepay_flutter Example

Sample app for the elepay Flutter SDK, demonstrating how to integrate elepay payments across the three transaction modes: Charge, Checkout, and Source.

## Project Structure

```
example/
├── lib/
│   ├── main.dart              # App entry point; initializes ElepayFlutter SDK
│   ├── ProductsView.dart      # Product list page
│   ├── ProductCell.dart       # Product card widget
│   ├── PaymentView.dart       # Payment page (starts payment after a product is selected)
│   ├── SettingView.dart       # Settings page entry point
│   ├── SubViews.dart          # Sub-views: Keys / transaction params / card info / Infos
│   ├── InfosView.dart         # Customer info management (Customer & Source)
│   ├── Api/
│   │   ├── Network.dart       # HTTP request wrapper
│   │   ├── PayHandler.dart    # Payment handler singleton; centralizes the network layer
│   │   ├── ChargeHandler.dart # Charge transaction handler
│   │   ├── CheckoutHandler.dart # Checkout transaction handler
│   │   └── SourceHandler.dart # Source / Customer CRUD operations
│   ├── Models/
│   │   ├── Configs.dart       # API configuration (host, endpoints, Keys)
│   │   ├── Products.dart      # Product data model
│   │   ├── Finance.dart       # Currency model
│   │   ├── Payments.dart      # Payment method enum
│   │   ├── TradingType.dart   # Transaction type (Charge / Source / Checkout)
│   │   ├── Card.dart          # Card info model
│   │   └── Information.dart   # Customer info model
│   └── Help/
│       ├── KVMap.dart         # SharedPreferences wrapper
│       └── Help.dart          # Utility helpers
├── test/                      # Unit tests
├── integration_test/          # Integration tests
├── android/                   # Android platform configuration
└── ios/                       # iOS platform configuration
```

## Prerequisites

- Flutter SDK >= 3.24.0 (iOS requires Swift Package Manager enabled)
- A **Public Key** (`pk_live_xxx`) and **Secret Key** (`sk_live_xxx`) from the [elepay Dashboard](https://dashboard.elepay.io)
- iOS development requires SPM: `flutter config --enable-swift-package-manager` (ElepaySDK 5.x is distributed only via SPM; CocoaPods is no longer supported)
- Android development requires JDK 17+

## Getting Started

### 1. Install dependencies

```bash
cd example
flutter pub get
```

> iOS native dependencies (ElepaySDK 5.x, etc.) are resolved automatically by Xcode through Swift Package Manager — no `pod install` required.
> On the first build, Xcode pulls SPM dependencies from GitHub, so make sure the network is reachable.

### 2. Run the app

```bash
# List available devices
flutter devices

# Run on a specific device (use the device ID from `flutter devices`)
flutter run -d <device_id>
```

Example `flutter devices` output:

```
iPhone 16 Pro (mobile)  • 9A1B2C3D-...  • ios        • com.apple.CoreSimulator.SimRuntime.iOS-18-0 (simulator)
Pixel 8 (mobile)        • emulator-5554  • android    • Android 14 (API 34)
macOS (desktop)         • macos          • darwin-arm64
Chrome (web)            • chrome         • web-javascript
```

Pick the matching device ID, for example:

```bash
flutter run -d 9A1B2C3D-...
flutter run -d emulator-5554
```

### 4. Configure API Keys

After launching the app, open the **Settings** page and fill in the values obtained from the elepay Dashboard:
- **Public Key** — used to initialize the SDK
- **Secret Key** — used to authenticate API requests

Tap **Reboot to apply** to restart the app so the new configuration takes effect.

### 5. Make a payment

1. Pick a product on the **Products** page
2. Tap the cart icon in the top-right to open the payment page
3. On the payment page you can choose:
   - **Currency** — currency (only JPY is supported for now)
   - **Trading Type** — transaction type (Charge / Source / Checkout)
   - **Payment Method** — payment method
4. Tap **-> Go to Pay** to start the payment

## Common Development Commands

```bash
# Install dependencies
flutter pub get

# Static analysis
flutter analyze

# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Clean build cache
flutter clean && flutter pub get
```

## Debugging with an HTTP Proxy

In Debug mode, you can route HTTP traffic through a proxy via `--dart-define` for packet capture:

```bash
flutter run --dart-define=PROXY=10.0.1.26:6152
```

All HTTP requests will be forwarded to the specified proxy address, making it easy to inspect traffic with tools like Charles or Proxyman.

## Transaction Types

| Type | Description |
|------|-------------|
| **Charge** | Starts a payment directly: calls the `/charges` API to create a payment object, then invokes `ElepayFlutter.handleCharge()` to launch the payment flow |
| **Source** | Registers a Customer and Source first, then pays through a saved payment source; customer info must be configured under Settings > Infos |
| **Checkout** | Uses Checkout mode: calls the `/codes` API to create a checkout, then opens the payment page via `ElepayFlutter.checkout()` |
