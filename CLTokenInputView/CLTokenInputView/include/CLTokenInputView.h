//
//  CLTokenInputView.h
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLToken.h"

#if __has_feature(objc_generics)
#define CL_GENERIC_ARRAY(type) NSArray<type>
#define CL_GENERIC_MUTABLE_ARRAY(type) NSMutableArray<type>
#define CL_GENERIC_SET(type) NSSet<type>
#define CL_GENERIC_MUTABLE_SET(type) NSMutableSet<type>
#else
#define CL_GENERIC_ARRAY(type) NSArray
#define CL_GENERIC_MUTABLE_ARRAY(type) NSMutableArray
#define CL_GENERIC_SET(type) NSSet
#define CL_GENERIC_MUTABLE_SET(type) NSMutableSet
#endif

NS_ASSUME_NONNULL_BEGIN

@class CLTokenInputView;
@protocol CLTokenInputViewDelegate <NSObject>

@optional

/**
 *  Called when the text field begins editing
 */
- (void)tokenInputViewDidEndEditing:(CLTokenInputView *)view;

/**
 *  Called when the text field ends editing
 */
- (void)tokenInputViewDidBeginEditing:(CLTokenInputView *)view;

/**
 * Called when the text field should return
 */
- (BOOL)tokenInputViewShouldReturn:(CLTokenInputView *)view;

/**
 * Called when the text field text has changed. You should update your autocompleting UI based on the text supplied.
 */
- (void)tokenInputView:(CLTokenInputView *)view didChangeText:(nullable NSString *)text;
/**
 * Called when a token has been added. You should use this opportunity to update your local list of selected items.
 */
- (void)tokenInputView:(CLTokenInputView *)view didAddToken:(CLToken *)token;
/**
 * Called when a token has been removed. You should use this opportunity to update your local list of selected items.
 */
- (void)tokenInputView:(CLTokenInputView *)view didRemoveToken:(CLToken *)token;
/** 
 * Called when the user attempts to press the Return key with text partially typed.
 * @return A CLToken for a match (typically the first item in the matching results),
 * or nil if the text shouldn't be accepted.
 */
- (nullable CLToken *)tokenInputView:(CLTokenInputView *)view tokenForText:(NSString *)text;
/**
 * Called when the view has updated its own height. If you are
 * not using Autolayout, you should use this method to update the
 * frames to make sure the token view still fits.
 */
- (void)tokenInputView:(CLTokenInputView *)view didChangeHeightTo:(CGFloat)height;

@end

@interface CLTokenInputView : UIView

@property (weak, nonatomic, nullable) IBOutlet NSObject <CLTokenInputViewDelegate> *delegate;
/** An optional view that shows up presumably on the first line */
@property (strong, nonatomic, nullable) UIView *fieldView;
/** Option text which can be displayed before the first line (e.g. "To:") */
@property (copy, nonatomic, nullable) IBInspectable NSString *fieldName;
/** Color of optional */
@property (strong, nonatomic, nullable) IBInspectable UIColor *fieldColor;
@property (copy, nonatomic, nullable) IBInspectable NSString *placeholderText;
@property (strong, nonatomic, nullable) UIView *accessoryView;
@property (assign, nonatomic) IBInspectable UIKeyboardType keyboardType;
@property (assign, nonatomic) IBInspectable UITextAutocapitalizationType autocapitalizationType;
@property (assign, nonatomic) IBInspectable UITextAutocorrectionType autocorrectionType;
@property (assign, nonatomic) IBInspectable UIKeyboardAppearance keyboardAppearance;
/** 
 * Optional additional characters to trigger the tokenization process (and call the delegate
 * with `tokenInputView:tokenForText:`
 * @discussion By default this array is empty, as only the Return key will trigger tokenization
 * however, if you would like to trigger tokenization with additional characters (such as a comma,
 * or as a space), you can supply the list here.
 */
@property (copy, nonatomic) CL_GENERIC_SET(NSString *) *tokenizationCharacters;
@property (assign, nonatomic) IBInspectable BOOL drawBottomBorder;

@property (readonly, nonatomic) CL_GENERIC_ARRAY(CLToken *) *allTokens;
@property (readonly, nonatomic, getter = isEditing) BOOL editing;
@property (readonly, nonatomic) CGFloat textFieldDisplayOffset;
@property (copy, nonatomic, nullable) NSString *text;

- (void)addToken:(CLToken *)token;
- (void)removeToken:(CLToken *)token;
- (nullable CLToken *)tokenizeTextfieldText;

// Editing
- (void)beginEditing;
- (void)endEditing;

@end

NS_ASSUME_NONNULL_END
