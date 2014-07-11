//
//  CLTokenView.h
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLToken.h"

@class CLTokenView;
@protocol CLTokenViewDelegate <NSObject>

@required
- (void)tokenViewDidRequestDelete:(CLTokenView *)tokenView replaceWithText:(NSString *)replacementText;
- (void)tokenViewDidRequestSelection:(CLTokenView *)tokenView;

@end


@interface CLTokenView : UIView <UIKeyInput>

@property (weak, nonatomic) NSObject <CLTokenViewDelegate> *delegate;
@property (assign, nonatomic) BOOL selected;

- (id)initWithToken:(CLToken *)token;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

// For iOS 6 compatibility, provide the setter tintColor
- (void)setTintColor:(UIColor *)tintColor;

@end
