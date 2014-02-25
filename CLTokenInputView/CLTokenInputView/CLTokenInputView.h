//
//  CLTokenInputView.h
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLToken.h"

@class CLTokenInputView;
@protocol CLTokenInputViewDelegate <NSObject>

- (void)tokenInputView:(CLTokenInputView *)view didChangeText:(NSString *)text;
- (void)tokenInputView:(CLTokenInputView *)view didRemoveToken:(CLToken *)token;

@end


@interface CLTokenInputView : UIView

@property (weak, nonatomic) IBOutlet NSObject <CLTokenInputViewDelegate> *delegate;
@property (copy, nonatomic) NSString *fieldName;
@property (assign, nonatomic) UIKeyboardType keyboardType;
@property (assign, nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (assign, nonatomic) UITextAutocorrectionType autocorrectionType;

- (void)addToken:(CLToken *)token;

@end
