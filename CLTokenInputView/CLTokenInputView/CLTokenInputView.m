//
//  CLTokenInputView.m
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLTokenInputView.h"

#import "CLBackspaceDetectingTextField.h"
#import "CLTokenView.h"

static CGFloat const HSPACE = 4.0;
static CGFloat const TEXT_FIELD_WIDTH_PADDING = 50.0;
static CGFloat const PADDING_LEFT = 5.0;
static CGFloat const PADDING_RIGHT = 8.0;
static CGFloat const STANDARD_HEIGHT = 30.0;
static CGFloat const FIELD_MARGIN_X = 4.0; // Note: Same as CLTokenView.PADDING_X

@interface CLTokenInputView () <CLBackspaceDetectingTextFieldDelegate, CLTokenViewDelegate, UIScrollViewDelegate>
{
    BOOL _didDeleteText;
}

@property (strong, nonatomic) CL_GENERIC_MUTABLE_ARRAY(CLToken *) *tokens;
@property (strong, nonatomic) CL_GENERIC_MUTABLE_ARRAY(CLTokenView *) *tokenViews;
@property (strong, nonatomic) UILabel *fieldLabel;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *clearButton;
@property (strong, nonatomic) CLBackspaceDetectingTextField *textField;

@property (assign, nonatomic) CGFloat additionalTextFieldYOffset;

@end

@implementation CLTokenInputView

- (void)commonInit
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.0f;
    self.clipsToBounds = YES;
    
    self.textField = [[CLBackspaceDetectingTextField alloc] initWithFrame:self.bounds];
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.returnKeyType = UIReturnKeySearch;
    self.textField.font = [UIFont systemFontOfSize:15.0f];
    self.textField.textColor = [UIColor colorWithRed:0.5569 green:0.5569 blue:0.5765 alpha:1.0];
    self.textField.delegate = self;
    self.additionalTextFieldYOffset = 0.0;
    if (![self.textField respondsToSelector:@selector(defaultTextAttributes)]) {
        self.additionalTextFieldYOffset = 1.5;
    }
    [self.textField addTarget:self
                       action:@selector(onTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];

    self.tokens = [NSMutableArray arrayWithCapacity:20];
    self.tokenViews = [NSMutableArray arrayWithCapacity:20];

    self.fieldColor = [UIColor lightGrayColor]; 
    
    self.fieldLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    // NOTE: Explicitly not setting a font for the field label
    self.fieldLabel.textColor = self.fieldColor;
    [self addSubview:self.fieldLabel];
    self.fieldLabel.hidden = YES;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + PADDING_LEFT, 0, self.bounds.size.width - PADDING_LEFT - PADDING_RIGHT, self.bounds.size.height)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.textField];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearButton.hidden = YES;
    [clearButton setImage:[self clearButtonImage] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    clearButton.frame = CGRectMake(0, 0, 14, 14);
    [self.scrollView addSubview:clearButton];
    self.clearButton = clearButton;
    self.accessoryView = self.clearButton;

    [self repositionViews];
}

- (UIImage *)clearButtonImage {
    NSURL *bundleURL = [[NSBundle bundleForClass:[CLTokenInputView class]] URLForResource:@"CLTokenInputView" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    NSString *imagePath = [bundle pathForResource:@"clear-icon" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

- (void)clearButtonTapped {
    [self clearContents];
    if ([self.delegate respondsToSelector:@selector(tokenInputViewDidClear:)]) {
        [self.delegate tokenInputViewDidClear:self];
    }
}

- (void)clearContents {
    [self removeAllTokens:NO];
    self.textField.text = @"";
    
    [self updatePlaceholderTextVisibility];
    [self updateClearButtonVisbility];
    [self makeTextFieldVisible];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, STANDARD_HEIGHT);
}


#pragma mark - Tint color


- (void)tintColorDidChange
{
    for (UIView *tokenView in self.tokenViews) {
        tokenView.tintColor = self.tintColor;
    }
}


#pragma mark - Adding / Removing Tokens

- (void)addToken:(CLToken *)token
{
    if ([self.tokens containsObject:token]) {
        return;
    }

    [self.tokens addObject:token];
    CLTokenView *tokenView = nil;
    if ([self.delegate respondsToSelector:@selector(tokenInputView:tokenViewForToken:)]) {
        tokenView = [self.delegate tokenInputView:self tokenViewForToken:token];
    }
    tokenView = tokenView ?: [[CLTokenView alloc] initWithToken:token font:self.textField.font];
    tokenView.delegate = self;
    CGSize intrinsicSize = tokenView.intrinsicContentSize;
    tokenView.frame = CGRectMake(0, 0, intrinsicSize.width, intrinsicSize.height);
    [self.tokenViews addObject:tokenView];
    [self.scrollView addSubview:tokenView];
    if ([self.delegate respondsToSelector:@selector(tokenInputView:didAddToken:)]) {
        [self.delegate tokenInputView:self didAddToken:token];
    }
    
    [self updatePlaceholderTextVisibility];
    [self updateClearButtonVisbility];
    [self repositionViews];
    [self makeTextFieldVisible];
}

- (void)removeToken:(CLToken *)token animated:(BOOL)animated
{
    NSInteger index = [self.tokens indexOfObject:token];
    if (index == NSNotFound) {
        return;
    }
    [self removeTokenAtIndex:index animated:animated];
}

- (void)removeTokenAtIndex:(NSInteger)index animated:(BOOL)animated
{
    if (index == NSNotFound) {
        return;
    }
    CLTokenView *tokenView = self.tokenViews[index];
    [self.tokenViews removeObjectAtIndex:index];
    [self.tokens removeObjectAtIndex:index];
    [self updatePlaceholderTextVisibility];
    [self updateClearButtonVisbility];
    
    if (animated) {
        [UIView animateWithDuration:CLTokenViewEditAnimationDuration animations:^{
            tokenView.frame = ({
                CGRect frame = tokenView.frame;
                frame.size.width = 0.0f;
                frame;
            });
            [self repositionViews];
        } completion:^(BOOL finished) {
            [tokenView removeFromSuperview];
        }];
    } else {
        [tokenView removeFromSuperview];
        [self repositionViews];
    }
}

- (void)removeAllTokens:(BOOL)animated {
    [self.tokenViews enumerateObjectsUsingBlock:^(CLTokenView * _Nonnull tokenView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (animated) {
            [UIView animateWithDuration:CLTokenViewEditAnimationDuration animations:^{
                tokenView.frame = ({
                    CGRect frame = tokenView.frame;
                    frame.size.width = 0.0f;
                    frame;
                });
            } completion:^(BOOL finished) {
                [tokenView removeFromSuperview];
            }];
        } else {
            [tokenView removeFromSuperview];
        }
    }];

    [self.tokenViews removeAllObjects];
    [self.tokens removeAllObjects];
    
    if (animated) {
        [UIView animateWithDuration:CLTokenViewEditAnimationDuration animations:^{
            [self repositionViews];
        }];
    } else {
        [self repositionViews];
    }
}

- (void)replaceToken:(CLToken *)token withToken:(CLToken *)newToken {
    NSInteger index = [self.tokens indexOfObjectIdenticalTo:token];
    
    CLTokenView *tokenView = nil;
    if ([self.delegate respondsToSelector:@selector(tokenInputView:tokenViewForToken:)]) {
        tokenView = [self.delegate tokenInputView:self tokenViewForToken:newToken];
    }
    tokenView = tokenView ?: [[CLTokenView alloc] initWithToken:newToken font:self.textField.font];
    tokenView.delegate = self;
    CGSize intrinsicSize = tokenView.intrinsicContentSize;
    tokenView.frame = CGRectMake(0, 0, intrinsicSize.width, intrinsicSize.height);
    [self.scrollView addSubview:tokenView];
    
    CLTokenView *existingTokenView = self.tokenViews[index];
    [existingTokenView removeFromSuperview];
    
    [self.tokens replaceObjectAtIndex:index withObject:newToken];
    [self.tokenViews replaceObjectAtIndex:index withObject:tokenView];

    if ([self.delegate respondsToSelector:@selector(tokenInputView:didAddToken:)]) {
        [self.delegate tokenInputView:self didAddToken:newToken];
    }
    
    [self repositionViews];
}

- (NSArray *)allTokens
{
    return [self.tokens copy];
}

- (CLToken *)tokenizeText:(NSString *)text
{
    CLToken *token = nil;
    if (text.length > 0 &&
        [self.delegate respondsToSelector:@selector(tokenInputView:tokenForText:)]) {
        token = [self.delegate tokenInputView:self tokenForText:text];
        if (token != nil) {
            [self addToken:token];
            [self scrollTokenViewToVisible:[self tokenViewForToken:token] animated:YES];
        }
    }
    return token;
}

- (CLToken *)tokenizeTextfieldText
{
    return [self tokenizeText:self.textField.text];
}

- (CLTokenView *)tokenViewForToken:(CLToken *)token {
    return self.tokenViews[[self.tokens indexOfObject:token]];
}

#pragma mark - Updating/Repositioning Views

- (void)repositionViews
{
    CGRect bounds = self.bounds;
    CGFloat rightBoundary = CGRectGetWidth(bounds) - PADDING_RIGHT;
    CGFloat firstLineRightBoundary = rightBoundary;

    CGFloat curX = PADDING_LEFT;
    CGFloat curY = 0;

    // Position field view (if set)
    if (self.fieldView) {
        CGRect fieldViewRect = self.fieldView.frame;
        fieldViewRect.origin.x = curX + FIELD_MARGIN_X;
        fieldViewRect.origin.y = curY + ((STANDARD_HEIGHT - CGRectGetHeight(fieldViewRect))/2.0);
        self.fieldView.frame = fieldViewRect;

        curX = CGRectGetMaxX(fieldViewRect) + FIELD_MARGIN_X;
    }

    // Position field label (if field name is set)
    if (!self.fieldLabel.hidden) {
        CGSize labelSize = self.fieldLabel.intrinsicContentSize;
        CGRect fieldLabelRect = CGRectZero;
        fieldLabelRect.size = labelSize;
        fieldLabelRect.origin.x = curX + FIELD_MARGIN_X;
        fieldLabelRect.origin.y = curY + ((STANDARD_HEIGHT-CGRectGetHeight(fieldLabelRect))/2.0);
        self.fieldLabel.frame = fieldLabelRect;

        curX = CGRectGetMaxX(fieldLabelRect) + FIELD_MARGIN_X;
    }

    // Position accessory view (if set)
    if (self.accessoryView) {
        CGRect accessoryRect = self.accessoryView.frame;
        accessoryRect.origin.x = CGRectGetWidth(bounds) - PADDING_RIGHT - CGRectGetWidth(accessoryRect);
        accessoryRect.origin.y = curY + ((STANDARD_HEIGHT-CGRectGetHeight(accessoryRect))/2.0);
        self.accessoryView.frame = accessoryRect;
    }
    
    // Position scroll view
    CGRect scrollViewRect = self.scrollView.frame;
    scrollViewRect.origin.x = curX;
    scrollViewRect.origin.y = curY;
    scrollViewRect.size.width = firstLineRightBoundary - curX;
    scrollViewRect.size.height = STANDARD_HEIGHT;
    self.scrollView.frame = scrollViewRect;
    
     // Reset to 0 as now in scroll view
    curX = 0;
    curY = 0;
    
    // Position token views
    CGRect tokenRect = CGRectNull;
    for (UIView *tokenView in self.tokenViews) {
        tokenRect = tokenView.frame;

        tokenRect.origin.x = curX;
        // Center our tokenView vertially within STANDARD_HEIGHT
        tokenRect.origin.y = curY + ceilf((STANDARD_HEIGHT-CGRectGetHeight(tokenRect))/2.0);
        tokenView.frame = tokenRect;

        curX = CGRectGetMaxX(tokenRect) + HSPACE;
    }

    // Always indent textfield by a little bit
    curX += 4;
    
    CGFloat availableWidthForTextField = 2000 - curX;

    CGRect textFieldRect = self.textField.frame;
    textFieldRect.origin.x = curX;
    textFieldRect.origin.y = curY + self.additionalTextFieldYOffset;
    textFieldRect.size.width = availableWidthForTextField;
    textFieldRect.size.height = STANDARD_HEIGHT;
    self.textField.frame = textFieldRect;
    
    [self resizeViews];

    [self setNeedsDisplay];
}

- (void)resizeViews {
    CGFloat rightBoundary = CGRectGetWidth(self.scrollView.frame);
    CGFloat textWidth = self.textField.attributedText.size.width + TEXT_FIELD_WIDTH_PADDING;
    
    CGRect textFieldRect = self.textField.frame;
    textFieldRect.size.width = MAX(textWidth, rightBoundary - CGRectGetMinX(textFieldRect));
    self.textField.frame = textFieldRect;
    
    CGRect accessoryRect = self.accessoryView.frame;
    accessoryRect.origin.x = MAX(CGRectGetMaxX(textFieldRect), CGRectGetWidth(self.scrollView.frame)) - CGRectGetWidth(accessoryRect);
    self.accessoryView.frame = accessoryRect;

    CGSize contentSize = self.scrollView.contentSize;
    contentSize.width = CGRectGetMaxX(accessoryRect);
    self.scrollView.contentSize = contentSize;
}

- (void)makeTextFieldVisible {
    CGFloat rightBoundary = CGRectGetWidth(self.scrollView.frame);
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    contentOffset.x = CGRectGetMaxX(self.textField.frame) - rightBoundary;
    [self.scrollView setContentOffset:contentOffset animated:NO];
}

- (void)updatePlaceholderTextVisibility
{
    if (self.tokens.count > 0) {
        self.textField.placeholder = nil;
    } else {
        self.textField.placeholder = self.placeholderText;
    }
}

- (void)updateClearButtonVisbility {
    self.clearButton.hidden = !(self.tokens.count > 0 || self.textField.text.length > 0);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.scrollView.dragging && !self.scrollView.decelerating) {
        [self repositionViews];
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.accessoryView) {
        return;
    }
    
    if (scrollView.contentOffset.x > ceilf(scrollView.contentSize.width) - scrollView.frame.size.width) {
        if (self.accessoryView.superview != self) {
            CGRect frame = self.accessoryView.frame;
            frame.origin.x = CGRectGetWidth(self.bounds) - PADDING_RIGHT - CGRectGetWidth(frame);
            self.accessoryView.frame = frame;
            [self.accessoryView removeFromSuperview];
            [self addSubview:self.accessoryView];
        }
    } else {
        if (self.accessoryView.superview != self.scrollView) {
            CGRect frame = [self.accessoryView.superview convertRect:self.accessoryView.frame toView:self.scrollView];
            self.accessoryView.frame = frame;
            [self.accessoryView removeFromSuperview];
            [self.scrollView addSubview:self.accessoryView];
        }
    }
}

#pragma mark - CLBackspaceDetectingTextFieldDelegate

- (void)textFieldDidDeleteBackwards:(UITextField *)textField
{
    // Delay deleting the next token slightly, so that on iOS 8
    // the deleteBackward on CLTokenView is not called immediately,
    // causing a double-delete
    dispatch_async(dispatch_get_main_queue(), ^{
        // Delete right-most token if at the start of the text field and we haven't just removed the first char
        if ([textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start] == 0 && !_didDeleteText) {
            CLTokenView *tokenView = self.tokenViews.lastObject;
            if (tokenView) {
                CLToken *removedToken = self.tokens.lastObject;
                [self removeTokenAtIndex:self.tokenViews.count - 1 animated:NO];
                if ([self.delegate respondsToSelector:@selector(tokenInputView:didRemoveToken:)]) {
                    [self.delegate tokenInputView:self didRemoveToken:removedToken];
                }
            }
        }
        _didDeleteText = NO;
    });
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(tokenInputViewDidBeginEditing:)]) {
        [self.delegate tokenInputViewDidBeginEditing:self];
    }
    [self unselectAllTokenViewsAnimated:YES];
    [self makeTextFieldVisible];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    BOOL transitioningToTokenView = NO;
    for (CLTokenView *view in self.tokenViews) {
        transitioningToTokenView |= view.selected;
    }
    
    if (!transitioningToTokenView && [self.delegate respondsToSelector:@selector(tokenInputViewDidEndEditing:)]) {
        [self.delegate tokenInputViewDidEndEditing:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self tokenizeTextfieldText];
    BOOL shouldDoDefaultBehavior = NO;
    if ([self.delegate respondsToSelector:@selector(tokenInputViewShouldReturn:)]) {
        shouldDoDefaultBehavior = [self.delegate tokenInputViewShouldReturn:self];
    }
    return shouldDoDefaultBehavior;
}

- (BOOL)                    textField:(UITextField *)textField
        shouldChangeCharactersInRange:(NSRange)range
                    replacementString:(NSString *)string
{
    if (string.length > 0 && [self.tokenizationCharacters member:string] && [self tokenizeText:[textField.text stringByReplacingCharactersInRange:range withString:string]]) {
        // Never allow the change if it matches at token
        return NO;
    }
    if (range.length && !string.length) {
        _didDeleteText = YES;
    }
    return YES;
}


#pragma mark - Text Field Changes

- (void)onTextFieldDidChange:(id)sender
{
    [self updateClearButtonVisbility];
    [self resizeViews];
    [self makeTextFieldVisible];
    
    if ([self.delegate respondsToSelector:@selector(tokenInputView:didChangeText:)]) {
        [self.delegate tokenInputView:self didChangeText:self.textField.text];
    }
}


#pragma mark - Text Field Customization

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    _keyboardType = keyboardType;
    self.textField.keyboardType = _keyboardType;
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
{
    _autocapitalizationType = autocapitalizationType;
    self.textField.autocapitalizationType = _autocapitalizationType;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType
{
    _autocorrectionType = autocorrectionType;
    self.textField.autocorrectionType = _autocorrectionType;
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance
{
    _keyboardAppearance = keyboardAppearance;
    self.textField.keyboardAppearance = _keyboardAppearance;
}


#pragma mark - Measurements (text field offset, etc.)

- (CGFloat)textFieldDisplayOffset
{
    // Essentially the textfield's y
    return CGRectGetMinY(self.textField.frame);
}

#pragma mark - Textfield text


- (NSString *)text
{
    return self.textField.text;
}


#pragma mark - CLTokenViewDelegate

- (void)tokenViewDidRequestDelete:(CLTokenView *)tokenView replaceWithText:(NSString *)replacementText
{
    // First, refocus the text field
    [self.textField becomeFirstResponder];
    if (replacementText.length > 0) {
        self.textField.text = replacementText;
    }
    // Then remove the view from our data
    NSInteger index = [self.tokenViews indexOfObject:tokenView];
    if (index == NSNotFound) {
        return;
    }
    CLToken *removedToken = self.tokens[index];
    [self removeTokenAtIndex:index animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(tokenInputView:didRemoveToken:)]) {
        [self.delegate tokenInputView:self didRemoveToken:removedToken];
    }
}

- (void)tokenViewDidRequestSelection:(CLTokenView *)tokenView
{
    [self selectTokenView:tokenView animated:YES];
}

#pragma mark - Token selection

- (void)scrollTokenViewToVisible:(CLTokenView *)tokenView animated:(BOOL)animated {
    if (CGRectGetMinX(tokenView.frame) < self.scrollView.contentOffset.x) { /* Check if hidden on the left side */
        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.x = CGRectGetMinX(tokenView.frame);
        [self.scrollView setContentOffset:contentOffset animated:animated];
    } else if (CGRectGetMaxX(tokenView.frame) > self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame)) /* Or on the right side */ {
        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.x = CGRectGetMaxX(tokenView.frame) - CGRectGetWidth(self.scrollView.frame);
        [self.scrollView setContentOffset:contentOffset animated:animated];
    }
}

- (void)selectToken:(CLToken *)token animated:(BOOL)animated {
    [self selectTokenView:[self tokenViewForToken:token] animated:animated];
}

- (void)selectTokenView:(CLTokenView *)tokenView animated:(BOOL)animated
{
    [tokenView setSelected:YES animated:animated];
    for (CLTokenView *otherTokenView in self.tokenViews) {
        if (otherTokenView != tokenView) {
            [otherTokenView setSelected:NO animated:animated];
        }
    }
    
    [self scrollTokenViewToVisible:tokenView animated:YES];
    
    [UIView animateWithDuration:animated ? CLTokenViewEditAnimationDuration : 0 animations:^{
        [self repositionViews];
    }];
    
    CLToken *token = self.tokens[[self.tokenViews indexOfObjectIdenticalTo:tokenView]];
    if ([self.delegate respondsToSelector:@selector(tokenInputView:didSelectToken:)]) {
        [self.delegate tokenInputView:self didSelectToken:token];
    }
}

- (void)selectTokens:(NSArray<CLToken *> *)tokens animated:(BOOL)animated {
    for (CLTokenView *otherTokenView in self.tokenViews) {
        [otherTokenView setSelected:NO animated:animated];
    }
    
    for (CLToken *token in tokens) {
        CLTokenView *view = [self tokenViewForToken:token];
        [view setSelected:YES animated:YES updateFirstResponder:NO];
    }
    
    if (tokens.count) {
        [self scrollTokenViewToVisible:[self tokenViewForToken:tokens.firstObject] animated:YES];
    }
    
    [UIView animateWithDuration:animated ? CLTokenViewEditAnimationDuration : 0 animations:^{
        [self repositionViews];
    }];
}

- (void)unselectAllTokenViewsAnimated:(BOOL)animated
{
    BOOL tokenWasFirstResponder = NO;
    for (CLTokenView *tokenView in self.tokenViews) {
        tokenWasFirstResponder |= tokenView.isFirstResponder;
        [tokenView setSelected:NO animated:animated];
    }
    
    if (tokenWasFirstResponder) {
        if ([self.delegate respondsToSelector:@selector(tokenInputViewDidEndEditing:)]) {
            [self.delegate tokenInputViewDidEndEditing:self];
        }
    }
    
    [UIView animateWithDuration:animated ? CLTokenViewEditAnimationDuration : 0 animations:^{
        [self repositionViews];
    }];
}


#pragma mark - Editing

- (BOOL)isEditing
{
    return self.textField.editing;
}


- (void)beginEditing
{
    [self.textField becomeFirstResponder];
    [self unselectAllTokenViewsAnimated:YES];
    [self makeTextFieldVisible];
}

- (void)endEditing
{
    // NOTE: We used to check if .isFirstResponder
    // and then resign first responder, but sometimes
    // we noticed that it would be the first responder,
    // but still return isFirstResponder=NO. So always
    // attempt to resign without checking.
    [self.textField resignFirstResponder];
    [self unselectAllTokenViewsAnimated:YES];
}

#pragma mark - (Optional Views)

- (void)setFieldName:(NSString *)fieldName
{
    if (_fieldName == fieldName) {
        return;
    }
    NSString *oldFieldName = _fieldName;
    _fieldName = fieldName;

    self.fieldLabel.text = _fieldName;
    [self.fieldLabel invalidateIntrinsicContentSize];
    BOOL showField = (_fieldName.length > 0);
    self.fieldLabel.hidden = !showField;
    if (showField && !self.fieldLabel.superview) {
        [self addSubview:self.fieldLabel];
    } else if (!showField && self.fieldLabel.superview) {
        [self.fieldLabel removeFromSuperview];
    }

    if (oldFieldName == nil || ![oldFieldName isEqualToString:fieldName]) {
        [self repositionViews];
    }
}

- (void)setFieldColor:(UIColor *)fieldColor {
    _fieldColor = fieldColor;
    self.fieldLabel.textColor = _fieldColor;
}

- (void)setFieldView:(UIView *)fieldView
{
    if (_fieldView == fieldView) {
        return;
    }
    [_fieldView removeFromSuperview];
    _fieldView = fieldView;
    if (_fieldView != nil) {
        [self addSubview:_fieldView];
    }
    [self repositionViews];
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    if (_placeholderText == placeholderText) {
        return;
    }
    _placeholderText = placeholderText;
    [self updatePlaceholderTextVisibility];
}

- (void)setAccessoryView:(UIView *)accessoryView
{
    if (_accessoryView == accessoryView) {
        return;
    }
    [_accessoryView removeFromSuperview];
    _accessoryView = accessoryView;

    if (_accessoryView != nil) {
        [self.scrollView addSubview:_accessoryView];
    } else {
        // Reset to clear button
        self.accessoryView = self.clearButton;
        return;
    }
    [self repositionViews];
}


#pragma mark - Drawing

- (void)setDrawBottomBorder:(BOOL)drawBottomBorder
{
    if (_drawBottomBorder == drawBottomBorder) {
        return;
    }
    _drawBottomBorder = drawBottomBorder;
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.drawBottomBorder) {

        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect bounds = self.bounds;
        CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextSetLineWidth(context, 0.5);

        CGContextMoveToPoint(context, 0, bounds.size.height);
        CGContextAddLineToPoint(context, CGRectGetWidth(bounds), bounds.size.height);
        CGContextStrokePath(context);
    }
}

@end
