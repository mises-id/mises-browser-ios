#import "mises_utils.h"
#include "base/logging.h"
#include "base/command_line.h"

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

#import "ios/chrome/browser/ui/commands/browser_commands.h"
#import "mises_lcd_service.h"
#import "mises_share_service.h"
#import "mises_account_service.h"

@interface RCTMisesModule : NSObject <RCTBridgeModule>
@end

@interface MetamaskUIViewController : UIViewController

@end

@interface ReactAppDelegate : UIResponder <RCTBridgeDelegate>

@property (nonatomic, strong) MetamaskUIViewController *rootViewController;

@property (nonatomic, strong) RCTBridge *bridge;

@property (nonatomic, strong) WKWebView *webView;

@property(nonatomic, weak) id<BrowserCommands> browserHandler;

@end


@implementation MetamaskUIViewController

- (BOOL)isModal {
     if([self presentingViewController])
         return YES;

    return NO;
 }
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  dispatch_async(dispatch_get_main_queue(), ^{

    [[Mises bridge] enqueueJSCall:@"NativeBridge.windowStatusChanged" args:@[@"show"]];
  });
}
- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  dispatch_async(dispatch_get_main_queue(), ^{

    [[Mises bridge] enqueueJSCall:@"NativeBridge.windowStatusChanged" args:@[@"hide"]];
  });
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
    if ([basevc
         respondsToSelector:@selector(openSinglePage:)]) {
        self.browserHandler = static_cast<UIViewController<BrowserCommands>*>(basevc);
    }
  [basevc presentViewController:self.rootViewController  animated:YES completion:^{
  }];
}


- (void)dismiss {
  if (![self.rootViewController isModal]) {
      return;
  };
    self.browserHandler = nil;
    [self.rootViewController dismissViewControllerAnimated:YES  completion: nil];
}
- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  base::CommandLine* command_line = base::CommandLine::ForCurrentProcess();
  const std::string mises_dev_ip =
      command_line->GetSwitchValueASCII("mises-dev-ip");
  if (mises_dev_ip.size()) {
    [[RCTBundleURLProvider sharedSettings] setJsLocation:base::SysUTF8ToNSString(mises_dev_ip.c_str())];
    return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
  }
    
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
}
@end



@implementation Mises

+ (void) Init{
    DLOG(WARNING) << "Init Metamask";
    dispatch_async(dispatch_get_main_queue(), ^{
      [ReactAppDelegate wrapper]; 
      [[MisesLCDService wrapper] run];
      [MisesShareService wrapper];
      [MisesAccountService wrapper];
        
        
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


+ (MisesAccountService*) account {
  return [MisesAccountService wrapper];
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
                [Mises PopupMetamask:bvc];
            }
           
        }
        
    });
    return nil;
}
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(postMessageFromRN:(NSString *)msg:(NSString *)origin)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
      DLOG(WARNING) << "postMessageFromRN " << msg;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        
      DLOG(WARNING) << "setMisesUserInfo " << jsonString;
      NSData *stringData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
      id json = [NSJSONSerialization JSONObjectWithData:stringData options:0 error:nil];

      if ([json isKindOfClass:[NSDictionary class]]) {
          [[Mises account] loadFrom:json save:YES];
      }
    });

    return nil;
}



RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(openUrl:(NSString *)url)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        DLOG(WARNING) << "openUrl " << url;
        id handelr = [[ReactAppDelegate wrapper] browserHandler];
        if (handelr) {
            [handelr openSinglePage:url];
        }
        [[ReactAppDelegate wrapper] dismiss];
        
      
    });

    return nil;
}

@end
