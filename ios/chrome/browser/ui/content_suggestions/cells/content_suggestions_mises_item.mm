// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/ui/content_suggestions/cells/content_suggestions_mises_item.h"

#import <MaterialComponents/MaterialTypography.h>

#include "base/check_op.h"
#import "ios/chrome/browser/ui/util/uikit_ui_util.h"
#include "ios/chrome/common/string_util.h"
#import "ios/chrome/common/ui/colors/semantic_color_names.h"
#import "ios/chrome/common/ui/util/constraints_ui_util.h"


#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

namespace {

const CGFloat kLabelMargin = 14;
//const CGFloat kLabelLineSpacing = 4;
const CGFloat kLabelIconMargin = 8;
const CGFloat kboxTitleFontSize = 20;
const CGFloat kIconHeight = 55;
const CGFloat kIconWidth = 89;
const CGFloat kIconTopMargin = 10;
NSString * const kboxWebsiteText = @"Web3 Sites";
}  // namespace

#pragma mark - ContentSuggestionsMisesItem

@implementation ContentSuggestionsMisesItem

@synthesize suggestionIdentifier = _suggestionIdentifier;
@synthesize metricsRecorded = _metricsRecorded;

- (instancetype)initWithType:(NSInteger)type {
  self = [super initWithType:type];
  if (self) {
    self.cellClass = [ContentSuggestionsMisesCell class];
  }
  return self;
}

- (void)configureCell:(ContentSuggestionsMisesCell*)cell {
  [super configureCell:cell];
  cell.accessibilityIdentifier = [[self class] accessibilityIdentifier];
}

- (CGFloat)cellHeightForWidth:(CGFloat)width {
  return [self.cellClass heightForWidth:width];
}

+ (NSString*)accessibilityIdentifier {
  return @"ContentSuggestionsMisesIdentifier";
}

@end

#pragma mark - ContentSuggestionsMisesCell

@interface ContentSuggestionsMisesCell ()

@property(nonatomic, strong) UILabel* boxWebsiteLabel;
@property(nonatomic, strong) UIView* containerView;

// Most visited items from the MostVisitedSites service currently displayed.

@end

@implementation ContentSuggestionsMisesCell

@synthesize boxWebsiteLabel = _boxWebsiteLabel;
@synthesize containerView = _containerView;

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
      
    _boxWebsiteLabel = [[UILabel alloc] init];
    _containerView = [[UIView alloc] init];

    _boxWebsiteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
      
    [[self class] configureBoxWebsiteLabel:self.boxWebsiteLabel withText:kboxWebsiteText];

    [self.contentView addSubview:_containerView];
    [_containerView addSubview:_boxWebsiteLabel];

    ApplyVisualConstraintsWithMetrics(
        @[
          @"V:|[boxWebsiteTitle]|",
          @"V:|[container]|",
          @"H:|[boxWebsiteTitle]|",
          @"H:|[container]|"
        ],
        @{
          @"boxWebsiteTitle" : _boxWebsiteLabel,
          @"container" : _containerView
        },
        @{
          @"margin" : @(kLabelMargin),
          @"iconMargin" : @(kIconTopMargin),
          
          @"iconHeight" : @(kIconHeight),
          @"iconWidth" : @(kIconWidth),
          @"spacing" : @(kLabelIconMargin)
        });
    [NSLayoutConstraint activateConstraints:@[
      [_containerView.centerXAnchor
          constraintEqualToAnchor:self.contentView.centerXAnchor]
    ]];
  }
  return self;
}

+ (CGFloat)heightForWidth:(CGFloat)width {
    UILabel* label1 = [[UILabel alloc] init];
    [self configureBoxWebsiteLabel:label1 withText:kboxWebsiteText];
    CGSize sizeForLabel = CGSizeMake(width, 500);

  return 2 * kLabelMargin + [label1 sizeThatFits:sizeForLabel].height;
}


#pragma mark UIView

// Implements -layoutSubviews as per instructions in documentation for
// +[MDCCollectionViewCell cr_preferredHeightForWidth:forItem:].
- (void)layoutSubviews {
  [super layoutSubviews];

  // Adjust the text label preferredMaxLayoutWidth when the parent's width
  // changes, for instance on screen rotation.
  CGFloat parentWidth = CGRectGetWidth(self.contentView.bounds);

  self.boxWebsiteLabel.preferredMaxLayoutWidth = parentWidth;

  // Re-layout with the new preferred width to allow the label to adjust its
  // height.
  [super layoutSubviews];
}

#pragma mark Private

// Configures the |promoLabel| with the |text|.
+ (void)configureBoxWebsiteLabel:(UILabel*)label withText:(NSString*)text {
  label.font =
      [[MDCTypography fontLoader] regularFontOfSize:kboxTitleFontSize];
  label.textColor = [UIColor colorNamed:kTextPrimaryColor];
  label.numberOfLines = 0;
  label.textAlignment = NSTextAlignmentLeft;
  [label setText:[NSString stringWithString:text]];

}

@end
