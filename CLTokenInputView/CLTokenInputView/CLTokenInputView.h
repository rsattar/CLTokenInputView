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

@required
- (void)tokenInputView:(CLTokenInputView *)view didChangeText:(NSString *)text;
- (void)tokenInputView:(CLTokenInputView *)view didAddToken:(CLToken *)token;
- (void)tokenInputView:(CLTokenInputView *)view didRemoveToken:(CLToken *)token;
@optional
/** 
 * Called when the user attempts to press the Return key with text partially typed.
 * @return A CLToken for a match (typically the first item in the matching results),
 * or nil if the text shouldn't be accepted.
 */
- (CLToken *)tokenInputView:(CLTokenInputView *)view tokenForText:(NSString *)text;

@end


@interface CLTokenInputView : UIView

@property (weak, nonatomic) IBOutlet NSObject <CLTokenInputViewDelegate> *delegate;
@property (copy, nonatomic) NSString *fieldName;
@property (assign, nonatomic) UIKeyboardType keyboardType;
@property (assign, nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (assign, nonatomic) UITextAutocorrectionType autocorrectionType;

@property (readonly, nonatomic) CGFloat textFieldDisplayOffset;

- (void)addToken:(CLToken *)token;

@end
