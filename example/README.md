# elepay_flutter Example

elepay Flutter SDK 的示例应用，演示如何集成 elepay 支付功能，包括 Charge、Checkout 和 Source 三种交易模式。

## 项目结构

```
example/
├── lib/
│   ├── main.dart              # 应用入口，初始化 ElepayFlutter SDK
│   ├── ProductsView.dart      # 商品列表页面
│   ├── ProductCell.dart       # 商品卡片组件
│   ├── PaymentView.dart       # 支付页面（选择商品后发起支付）
│   ├── SettingView.dart       # 设置页面入口
│   ├── SubViews.dart          # Keys / 交易参数 / 卡片信息 / Infos 等子视图
│   ├── InfosView.dart         # 客户信息管理（Customer & Source）
│   ├── Api/
│   │   ├── Network.dart       # HTTP 网络请求封装
│   │   ├── PayHandler.dart    # 支付处理单例，统一管理网络层
│   │   ├── ChargeHandler.dart # Charge 交易处理
│   │   ├── CheckoutHandler.dart # Checkout 交易处理
│   │   └── SourceHandler.dart # Source / Customer CRUD 操作
│   ├── Models/
│   │   ├── Configs.dart       # API 配置（host、endpoints、Keys）
│   │   ├── Products.dart      # 商品数据模型
│   │   ├── Finance.dart       # 币种模型
│   │   ├── Payments.dart      # 支付方式枚举
│   │   ├── TradingType.dart   # 交易类型（Charge / Source / Checkout）
│   │   ├── Card.dart          # 卡片信息模型
│   │   └── Information.dart   # 客户信息模型
│   └── Help/
│       ├── KVMap.dart         # SharedPreferences 封装
│       └── Help.dart          # 工具类
├── test/                      # 单元测试
├── integration_test/          # 集成测试
├── android/                   # Android 平台配置
└── ios/                       # iOS 平台配置
```

## 前置条件

- Flutter SDK >= 3.24.0（iOS 端要求启用 Swift Package Manager）
- 在 [elepay Dashboard](https://dashboard.elepay.io) 获取 **Public Key** (`pk_live_xxx`) 和 **Secret Key** (`sk_live_xxx`)
- iOS 开发需启用 SPM：`flutter config --enable-swift-package-manager`（ElepaySDK 5.x 仅通过 SPM 分发，不再使用 CocoaPods）
- Android 开发需要 JDK 17+

## 快速开始

### 1. 安装依赖

```bash
cd example
flutter pub get
```

> iOS 原生依赖（ElepaySDK 5.x 等）通过 Swift Package Manager 由 Xcode 自动解析，无需 `pod install`。
> 首次构建时 Xcode 会从 GitHub 拉取 SPM 依赖，请保持网络畅通。

### 2. 运行应用

```bash
# 查看可用设备列表
flutter devices

# 运行到指定设备（使用 flutter devices 输出的设备 ID）
flutter run -d <device_id>
```

`flutter devices` 输出示例：

```
iPhone 16 Pro (mobile)  • 9A1B2C3D-...  • ios        • com.apple.CoreSimulator.SimRuntime.iOS-18-0 (simulator)
Pixel 8 (mobile)        • emulator-5554  • android    • Android 14 (API 34)
macOS (desktop)         • macos          • darwin-arm64
Chrome (web)            • chrome         • web-javascript
```

选择对应的设备 ID 运行即可，例如：

```bash
flutter run -d 9A1B2C3D-...
flutter run -d emulator-5554
```

### 4. 配置 API Keys

应用启动后，进入 **Settings** 页面，填写从 elepay Dashboard 获取的：
- **Public Key** — 用于 SDK 初始化
- **Secret Key** — 用于 API 请求鉴权

填写后点击 **Reboot to apply** 重启应用使配置生效。

### 5. 发起支付

1. 在 **Products** 页面选择商品
2. 点击右上角购物车图标进入支付页面
3. 在支付页面可选择：
   - **Currency** — 币种（目前仅支持 JPY）
   - **Trading Type** — 交易类型（Charge / Source / Checkout）
   - **Payment Method** — 支付方式
4. 点击 **-> Go to Pay** 发起支付

## 常用开发命令

```bash
# 安装依赖
flutter pub get

# 代码静态分析
flutter analyze

# 运行单元测试
flutter test

# 运行集成测试
flutter test integration_test

# 构建 APK
flutter build apk

# 构建 iOS
flutter build ios

# 清理构建缓存
flutter clean && flutter pub get
```

## 使用网络代理调试

在 Debug 模式下，可通过 `--dart-define` 指定 HTTP 代理来抓包：

```bash
flutter run --dart-define=PROXY=10.0.1.26:6152
```

这会将所有 HTTP 请求转发到指定代理地址，方便使用 Charles / Proxyman 等工具进行网络调试。

## 交易类型说明

| 类型 | 说明 |
|------|------|
| **Charge** | 直接发起支付，调用 `/charges` API 创建支付对象后通过 `ElepayFlutter.handleCharge()` 唤起支付 |
| **Source** | 先注册 Customer 和 Source，再通过已保存的支付来源发起支付，需在 Settings > Infos 中配置客户信息 |
| **Checkout** | 使用 Checkout 模式，调用 `/codes` API 创建结算后通过 `ElepayFlutter.checkout()` 唤起支付页面 |
