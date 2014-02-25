//
//  CLTokenView.h
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLToken.h"

@interface CLTokenView : UIView

@property (assign, nonatomic) BOOL selected;

- (id)initWithToken:(CLToken *)token;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end
