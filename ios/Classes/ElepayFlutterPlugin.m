#import "ElepayFlutterPlugin.h"
#if __has_include(<elepay_flutter/elepay_flutter-Swift.h>)
#import <elepay_flutter/elepay_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "elepay_flutter-Swift.h"
#endif

@implementation ElepayFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftElepayFlutterPlugin registerWithRegistrar:registrar];
}
@end
