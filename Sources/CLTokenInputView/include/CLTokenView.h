//
//  CLTokenView.h
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLToken.h"

extern CGFloat const CLTokenViewEditAnimationDuration;

NS_ASSUME_NONNULL_BEGIN

@class CLTokenView;
@protocol CLTokenViewDelegate <NSObject>

@required
- (void)tokenViewDidRequestDelete:(CLTokenView *)tokenView replaceWithText:(nullable NSString *)replacementText;
- (void)tokenViewDidRequestSelection:(CLTokenView *)tokenView;

@end


@interface CLTokenView : UIView <UIKeyInput>

@property (assign, nonatomic) BOOL selected;
@property (assign, nonatomic) BOOL hideUnselectedComma;

@property (strong, nonatomic, readonly) UILabel *label;
@property (strong, nonatomic, readonly) UIImageView *imageView;

// Presented when object becomes first responder.  If set to nil, reverts to following responder chain.  If
// set while first responder, will not take effect until reloadInputViews is called.
@property (nullable, readwrite, strong) UIView *inputView;
@property (nullable, readwrite, strong) UIView *inputAccessoryView;

@property (weak, nonatomic, nullable) NSObject <CLTokenViewDelegate> *delegate;

- (id)initWithToken:(CLToken *)token font:(nullable UIFont *)font;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated updateFirstResponder:(BOOL)updateFirstResponder;

@end

NS_ASSUME_NONNULL_END
