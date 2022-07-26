#ifndef IOS_CHROME_APP_MISES_UTILS_H_
#define IOS_CHROME_APP_MISES_UTILS_H_
#import <UIKit/UIKit.h>
@class RCTBridge;
@class WKWebView;

@interface Mises: NSObject
+ (void) Init;
+ (void) PopupMetamask:(UIViewController*) vc;

+ (RCTBridge *) bridge;

+ (void) OnNavigationStarted:(NSString*) url;

+ (void) onWebViewActivated:(WKWebView *) wv;


+ (BOOL) isLogin;
+ (NSString*) misesId;
+ (NSString*) misesToken;
+ (NSString*) misesNickname;
+ (NSString*) misesAvatar;

@end
#endif  // IOS_CHROME_APP_MISES_UTILS_H_
