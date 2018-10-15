//
//  CLTokenPillView.h
//  CLTokenInputView
//
//  Created by Doug Ross on 10/8/18.
//  Copyright © 2018 Cluster Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLTokenView.h"

@interface CLTokenPillView : CLTokenView
@property (strong, nonatomic) CLToken *token;
@property (strong, nonatomic) UIFont *font;

@end
