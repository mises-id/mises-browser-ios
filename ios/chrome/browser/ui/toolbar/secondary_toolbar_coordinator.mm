// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/ui/toolbar/secondary_toolbar_coordinator.h"

#import "ios/chrome/browser/main/browser.h"
#import "ios/chrome/browser/ui/commands/application_commands.h"
#import "ios/chrome/browser/ui/commands/browser_commands.h"
#import "ios/chrome/browser/ui/commands/command_dispatcher.h"
#import "ios/chrome/browser/ui/toolbar/adaptive_toolbar_coordinator+subclassing.h"
#import "ios/chrome/browser/ui/toolbar/secondary_toolbar_view_controller.h"

#import "ios/third_party/mises/mises_utils.h"

#include "base/strings/sys_string_conversions.h"


#include "components/image_fetcher/core/image_fetcher_impl.h"
#include "components/image_fetcher/ios/ios_image_decoder_impl.h"
#include "ios/chrome/browser/browser_state/chrome_browser_state.h"

#include "components/image_fetcher/core/cached_image_fetcher.h"

#include "components/image_fetcher/core/cache/image_cache.h"
#include "components/image_fetcher/core/cache/image_data_store_disk.h"
#include "components/image_fetcher/core/cache/image_metadata_store_leveldb.h"

#include "base/time/default_clock.h"

#include "services/network/public/cpp/shared_url_loader_factory.h"
#import "net/base/mac/url_conversions.h"

#include "ui/gfx/image/image.h"
#include "url/gurl.h"


#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

namespace {

const char kImageFetcherUmaClient[] = "NotifyAutoSignin";

// NetworkTrafficAnnotationTag for fetching avatar.
const net::NetworkTrafficAnnotationTag kTrafficAnnotation =
    net::DefineNetworkTrafficAnnotation("credential_avatar",
                                        R"(
        semantics {
          sender: "Chrome Password Manager"
          description:
            "Every credential saved in Chromium via the Credential Management "
            "API can have an avatar URL. The URL is essentially provided by "
            "the site calling the API. The avatar is used in the account "
            "chooser UI and auto signin toast which appear when a site calls "
            "navigator.credentials.get(). The avatar is retrieved before "
            "showing the UI."
          trigger:
            "User visits a site that calls navigator.credentials.get(). "
            "Assuming there are matching credentials in the Chromium password "
            "store, the avatars are retrieved."
          data: "Only avatar URL, no user data."
          destination: WEBSITE
        }
        policy {
          cookies_allowed: NO
          setting:
            "One can disable saving new credentials in the settings (see "
            "'Passwords and forms'). There is no setting to disable the API."
          chrome_policy {
            PasswordManagerEnabled {
              PasswordManagerEnabled: false
            }
          }
        })");

}  // namespace

@interface SecondaryToolbarCoordinator ()<MisesDelegate>
@property(nonatomic, strong) SecondaryToolbarViewController* viewController;
@end

@implementation SecondaryToolbarCoordinator
{
    std::unique_ptr<image_fetcher::ImageFetcher> _imageFetcher;
    std::unique_ptr<image_fetcher::ImageFetcher> _simpleFetcher;
}
@dynamic viewController;

#pragma mark - AdaptiveToolbarCoordinator

- (void)start {
  self.viewController = [[SecondaryToolbarViewController alloc] init];
  self.viewController.buttonFactory = [self buttonFactoryWithType:SECONDARY];
  // TODO(crbug.com/1045047): Use HandlerForProtocol after commands protocol
  // clean up.
  self.viewController.dispatcher =
      static_cast<id<ApplicationCommands, BrowserCommands>>(
          self.browser->GetCommandDispatcher());
  ChromeBrowserState* browser_state = self.browser->GetBrowserState();
    
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * cacheDirectory  = [documentsDirectory stringByAppendingString:@"/mises_cache/"];
    
    
    
    base::FilePath cache_path(base::SysNSStringToUTF8(cacheDirectory));
      scoped_refptr<base::SequencedTaskRunner> task_runner = browser_state->GetIOTaskRunner();
      base::DefaultClock* clock = base::DefaultClock::GetInstance();

      auto metadata_store =
          std::make_unique<image_fetcher::ImageMetadataStoreLevelDB>(
              browser_state->GetProtoDatabaseProvider(), cache_path, task_runner,
              clock);
      auto data_store = std::make_unique<image_fetcher::ImageDataStoreDisk>(
          cache_path, task_runner);

      scoped_refptr<image_fetcher::ImageCache> image_cache =
          base::MakeRefCounted<image_fetcher::ImageCache>(
              std::move(data_store),std::move(metadata_store),browser_state->GetPrefs(), clock, task_runner);;

    
    _simpleFetcher = std::make_unique<image_fetcher::ImageFetcherImpl>(image_fetcher::CreateIOSImageDecoder(),browser_state->GetSharedURLLoaderFactory());
    _imageFetcher = std::make_unique<image_fetcher::CachedImageFetcher>(_simpleFetcher.get(), image_cache, false);


  
  [super start];
}
- (void)stop {
  [super stop];
  [Mises setDelegate:nil];
}
- (void) activate {
    
    [Mises setDelegate:self];
    [self accountChanged];
    
}
- (void)accountChanged {
//  __weak SecondaryToolbarCoordinator* weakSelf = self;
//  void (^completion)(FaviconAttributes*) = ^(FaviconAttributes* attributes) {
//    SecondaryToolbarCoordinator* strongSelf = weakSelf;
//    if (!strongSelf || !attributes) {
//      return;
//    }
//    UIImage* image = attributes.faviconImage;
//    [strongSelf.viewController updateMisesAvatar:image];
//  };
    
    NSString* strurl = [Mises misesAvatar];
    if ([strurl length] == 0) {
        [self.viewController updateMisesAvatar:nil];
        return;
    }

  NSURL *nsurl = [NSURL URLWithString:[Mises misesAvatar]];
  if (nsurl) {
    GURL gurl = net::GURLWithNSURL(nsurl);
      __weak SecondaryToolbarCoordinator* weakSelf = self;
      auto callback =
            base::BindOnce(^(const gfx::Image& gfximage,
                             const image_fetcher::RequestMetadata& metadata) {
                SecondaryToolbarCoordinator* strongSelf = weakSelf;
                if (!strongSelf || gfximage.IsEmpty()) {
                      return;
                    }
                UIImage* image = [gfximage.ToUIImage() copy];
                  [strongSelf.viewController updateMisesAvatar:image];
            });

      image_fetcher::ImageFetcherParams params(kTrafficAnnotation,
                                                   kImageFetcherUmaClient);
      _imageFetcher->FetchImage(gurl, std::move(callback),
                                    params);
  
  }

}

@end
