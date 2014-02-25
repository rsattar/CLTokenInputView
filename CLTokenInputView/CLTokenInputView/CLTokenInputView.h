//
//  CLTokenInputView.h
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLTokenInputView;
@protocol CLTokenInputViewDelegate <NSObject>

- (void)tokenInputView:(CLTokenInputView *)view didChangeText:(NSString *)text;

@end


@interface CLTokenInputView : UIView

@property (weak, nonatomic) IBOutlet NSObject <CLTokenInputViewDelegate> *delegate;

@end
