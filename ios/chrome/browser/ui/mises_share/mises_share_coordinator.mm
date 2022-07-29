
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/ui/mises_share/mises_share_coordinator.h"


#import <MobileCoreServices/MobileCoreServices.h>

#import "base/mac/foundation_util.h"
#include "base/metrics/user_metrics.h"
#include "base/metrics/user_metrics_action.h"
#include "base/strings/sys_string_conversions.h"
#include "ios/chrome/browser/main/browser.h"
#import "ios/chrome/browser/ui/activity_services/activity_params.h"
#import "ios/chrome/browser/ui/activity_services/activity_scenario.h"
#import "ios/chrome/browser/ui/activity_services/activity_service_coordinator.h"
#import "ios/chrome/browser/ui/activity_services/requirements/activity_service_positioner.h"
#import "ios/chrome/browser/ui/activity_services/requirements/activity_service_presentation.h"
#import "ios/chrome/browser/ui/commands/command_dispatcher.h"
#import "ios/chrome/browser/ui/commands/mises_share_commands.h"
#import "ios/chrome/browser/ui/mises_share/mises_share_view_controller.h"
#import "ios/chrome/common/ui/confirmation_alert/confirmation_alert_action_handler.h"
#import "ios/chrome/common/ui/elements/popover_label_view_controller.h"

#import "ios/web/public/web_state.h"
#include "ios/chrome/browser/ui/activity_services/data/chrome_activity_item_thumbnail_generator.h"
#import "ios/chrome/browser/web_state_list/web_state_list.h"
#include "ios/chrome/browser/browser_state/chrome_browser_state.h"

#include "ios/chrome/grit/ios_strings.h"
#import "net/base/mac/url_conversions.h"
#include "ui/base/l10n/l10n_util_mac.h"


#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

namespace {

const CGFloat kScreenShotWidth = 256;
const CGFloat kScreenShotHeight = 256;

}  // namespace
using ItemBlock = void (^)(id idResponse, NSError* error);

@interface MisesShareCoordinator () <ActivityServicePositioner,
                                      ActivityServicePresentation,
                                      ConfirmationAlertActionHandler> {
  // URL of a page to generate a QR code for.
  GURL _URL;
}

@property(nonatomic, strong) id<MisesShareCommands> handler;
@property(nonatomic, strong) MisesShareViewController* viewController;

@property(nonatomic, assign) Browser* browser;



@property(nonatomic, strong)
    ActivityServiceCoordinator* activityServiceCoordinator;

@property(nonatomic, copy) NSString* title;

@property(nonatomic, strong)
    PopoverLabelViewController* learnMoreViewController;

@end

@implementation MisesShareCoordinator
@synthesize browser = _browser;

- (instancetype)initWithBaseViewController:(UIViewController*)viewController
                                   browser:(Browser*)browser
                                     title:(NSString*)title
                                       URL:(const GURL&)URL
                                   handler:(id<MisesShareCommands>)handler {
  if (self = [super initWithBaseViewController:viewController browser:browser]) {
    _title = title;
    _URL = URL;
    _handler = handler;
    self.browser = browser;
  }
  return self;
}

#pragma mark - Chrome Coordinator

- (void)start {
  self.viewController = [[MisesShareViewController alloc]
      initWithTitle:self.title
            pageURL:net::NSURLWithGURL(_URL)];

  [self.viewController setModalPresentationStyle:UIModalPresentationFormSheet];
  [self.viewController setActionHandler:self];

  [self.baseViewController presentViewController:self.viewController
                                        animated:YES
                                      completion:nil];
  [self loadThumbImage];
  [super start];
}

- (void)stop {
  [self.baseViewController dismissViewControllerAnimated:YES completion:nil];
  self.viewController = nil;
  self.learnMoreViewController = nil;

  [self.activityServiceCoordinator stop];
  self.activityServiceCoordinator = nil;

  [super stop];
}

#pragma mark - ConfirmationAlertActionHandler

- (void)confirmationAlertDismissAction {
  [self.handler hideMisesShare];
}

- (void)confirmationAlertPrimaryAction {
  base::RecordAction(base::UserMetricsAction("MobileShareToMisesDiscover"));

//  NSString* imageTitle = l10n_util::GetNSStringF(
//      IDS_IOS_QR_CODE_ACTIVITY_TITLE, base::SysNSStringToUTF16(self.title));

  [self.handler hideMisesShare];
}

- (void)confirmationAlertLearnMoreAction {
  NSString* message =
      l10n_util::GetNSString(IDS_IOS_QR_CODE_LEARN_MORE_MESSAGE);
  self.learnMoreViewController =
      [[PopoverLabelViewController alloc] initWithMessage:message];

  self.learnMoreViewController.popoverPresentationController.barButtonItem =
      self.viewController.helpButton;
  self.learnMoreViewController.popoverPresentationController
      .permittedArrowDirections = UIPopoverArrowDirectionUp;

  [self.viewController presentViewController:self.learnMoreViewController
                                    animated:YES
                                  completion:nil];
}

#pragma mark - ActivityServicePositioner

- (UIView*)sourceView {
  return self.viewController.primaryActionButton;
}

- (CGRect)sourceRect {
  return self.viewController.primaryActionButton.bounds;
}

#pragma mark - ActivityServicePresentation

- (void)activityServiceDidEndPresenting {
  [self.activityServiceCoordinator stop];
  self.activityServiceCoordinator = nil;
}


- (void)loadThumbImage {
    web::WebState* web_state = _browser->GetWebStateList()->GetActiveWebState();
    if (!web_state || web_state->GetBrowserState()->IsOffTheRecord()) {
        return;
    }
    ChromeActivityItemThumbnailGenerator* thumbnail_generator = [[ChromeActivityItemThumbnailGenerator alloc]
                    initWithWebState:web_state];
    CGSize size = CGSizeMake(kScreenShotWidth, kScreenShotHeight);
    UIImage* thumbnail = [thumbnail_generator thumbnailWithSize:size];
    [self.viewController updateThumbImage:thumbnail];

}

@end
