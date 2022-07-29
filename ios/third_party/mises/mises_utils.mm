#import "mises_utils.h"
#import "mises_lcd_service.h"
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
 //return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
//#endif
}
@end


NSString* mMisesId = @"";
NSString* mMisesToken = @"";
NSString* mMisesNickname = @"";
NSString* mMisesAvatar = @"";
NSString* const kMisesInfoKey = @"NSDefaultsMisesInfo";

__weak id<MisesDelegate> mDelegate;

@implementation Mises

+ (void) Init{
    DLOG(WARNING) << "Init Metamask";
    dispatch_async(dispatch_get_main_queue(), ^{
      [ReactAppDelegate wrapper]; 
      [[MisesLCDService wrapper] run];
        
        id json = [[NSUserDefaults standardUserDefaults] objectForKey:kMisesInfoKey];
        if ([json isKindOfClass:[NSDictionary class]]) {
            [Mises loadFrom:json];
        }
        
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


+ (BOOL) isLogin {
  return mMisesToken != nil && [mMisesToken length] > 0;
}
+ (NSString*) misesId {
  return [mMisesId copy];

}
+ (NSString*) misesToken{
  return [mMisesToken copy];

}
+ (NSString*) misesNickname{
  return [mMisesNickname copy];

}
+ (NSString*) misesAvatar{
  return [mMisesAvatar copy];
}

+ (void) setDelegate:(id<MisesDelegate>)delegate {
  mDelegate = delegate;
}


+ (void) loadFrom:(NSDictionary *) json{
    if (!json) {
        return;
    }
    id misesId = json[@"misesId"];
    if ([misesId isKindOfClass:[NSString class]]) {
      mMisesId = [misesId copy];
    }
    id token = json[@"token"];
    if ([token isKindOfClass:[NSString class]]) {
      mMisesToken = [token copy];
    }
    id nickname = json[@"nickname"];
    if ([nickname isKindOfClass:[NSString class]]) {
      mMisesNickname = [nickname copy];
    }
    id avatar = json[@"avatar"];
    if ([avatar isKindOfClass:[NSString class]]) {
      mMisesAvatar = [avatar copy];
    } else {
      mMisesAvatar = @"";
    }
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

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(setMisesUserInfo:(NSString *)jsonString)
{
    DLOG(WARNING) << "setMisesUserInfo " << jsonString;
    dispatch_async(dispatch_get_main_queue(), ^{
      NSData *stringData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
      id json = [NSJSONSerialization JSONObjectWithData:stringData options:0 error:nil];

      if ([json isKindOfClass:[NSDictionary class]]) {
          [Mises loadFrom:json];
          if (mDelegate) {
            [mDelegate accountChanged];
          }
          [[NSUserDefaults standardUserDefaults] setObject:json forKey:kMisesInfoKey];
      }
    });

    return nil;
}


@end
