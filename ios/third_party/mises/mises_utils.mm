#import "mises_utils.h"
#include "base/logging.h"
#include "base/strings/sys_string_conversions.h"

#import "ios/web/js_messaging/web_view_js_utils.h"

#import <Foundation/NSPathUtilities.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

//#error "test"

#import <React/RCTBridgeDelegate.h>
#import <UIKit/UIKit.h>
#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTPushNotificationManager.h>

#import <React/RCTBridgeModule.h>
@interface RCTMisesModule : NSObject <RCTBridgeModule>
@end

@interface MetamaskUIViewController : UIViewController

@end

@interface ReactAppDelegate : UIResponder <RCTBridgeDelegate>

@property (nonatomic, strong) MetamaskUIViewController *rootViewController;

@property (nonatomic, strong) RCTBridge *bridge;

@property (nonatomic, strong) WKWebView *webView;

@end



@implementation MetamaskUIViewController

- (BOOL)isModal {
     if([self presentingViewController])
         return YES;

    return NO;
 }
@end

@implementation ReactAppDelegate
+ (instancetype)wrapper
{  
    static ReactAppDelegate *sharedInstance = nil;
    @synchronized (self) {
        if (!sharedInstance) {
            sharedInstance = [[ReactAppDelegate alloc] init];
        }
    return sharedInstance;
    }
}
- (instancetype)init
{
    DLOG(WARNING) << "Mises init";
    self = [super init];
    if (self) {
        self.bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:NULL];
        RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:self.bridge
                                                   moduleName:@"MetaMask"
                                            initialProperties:@{@"foxCode": @"debug"}];
       //rootView.backgroundColor = [UIColor colorNamed:@"ThemeColors"];
       self.rootViewController = [MetamaskUIViewController new];
       self.rootViewController.view = rootView;
      DLOG(WARNING) << "Mises init step 4";
    }
    return self;
}
- (void)show:(UIViewController*)basevc {
  if ([self.rootViewController isModal]) {
      return;
  };
  [basevc presentViewController:self.rootViewController  animated:YES completion:^{
  }];
}


- (void)dismiss {
  if (![self.rootViewController isModal]) {
      return;
  };
    [self.rootViewController dismissViewControllerAnimated:YES  completion: nil];
}
- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
//#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
//#else
//  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
//#endif
}
@end

@implementation Mises

+ (void) Init{
    DLOG(WARNING) << "Init Metamask";
    dispatch_async(dispatch_get_main_queue(), ^{
      [ReactAppDelegate wrapper]; 
    });
     //
}
+ (void) PopupMetamask:(UIViewController*)basevc {
    DLOG(WARNING) << "Popup Metamask";

     [[ReactAppDelegate wrapper] show:basevc]; 
}

+ (RCTBridge *) bridge {
  return [[ReactAppDelegate wrapper] bridge]; 
}

+ (void) OnNavigationStarted:(NSString*) url {

  [[Mises bridge] enqueueJSCall:@"NativeBridge.loadStarted" args:@[url]];

}

+ (void) onWebViewActivated:(WKWebView *) wv {
  [ReactAppDelegate wrapper].webView = wv;
}
@end





@implementation RCTMisesModule

// To export a module named RCTMisesModule
RCT_EXPORT_MODULE()

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(dismiss)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ReactAppDelegate wrapper] dismiss];
        
    });
    return nil;
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(popup)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        UIViewController *basevc = keyWindow.rootViewController;
        if ([basevc respondsToSelector:@selector(childViewControllerForStatusBarStyle)]) {
            UIViewController* bvc = [basevc childViewControllerForStatusBarStyle];
            if (bvc) {
                [[ReactAppDelegate wrapper] show:bvc];
            }
           
        }
        
    });
    return nil;
}
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(postMessageFromRN:(NSString *)msg:(NSString *)origin)
{
    DLOG(WARNING) << "postMessageFromRN " << msg;
    dispatch_async(dispatch_get_main_queue(), ^{
      WKWebView* wv = [ReactAppDelegate wrapper].webView;
      if (wv) {
        NSString* method = [NSString stringWithFormat:@"(function(){try{window.postMessage( %@ , '%@');} catch (e) {}})()", msg, origin];
        web::ExecuteJavaScript(wv, method, ^(id value, NSError* error) {
          if (error) {
            DLOG(WARNING) << "Script execution failed with error: "
                          << base::SysNSStringToUTF16(
                                error.userInfo[NSLocalizedDescriptionKey]);
          }
        });
      }
    });

    return nil;
}

@end
