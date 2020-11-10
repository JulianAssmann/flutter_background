#import "FlutterBackgroundPlugin.h"
#if __has_include(<flutter_background/flutter_background-Swift.h>)
#import <flutter_background/flutter_background-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_background-Swift.h"
#endif

@implementation FlutterBackgroundPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterBackgroundPlugin registerWithRegistrar:registrar];
}
@end
