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

static CGFloat const HSPACE = 0.0;
static CGFloat const TEXT_FIELD_HSPACE = 4.0; // Note: Same as CLTokenView.PADDING_X
static CGFloat const VSPACE = 4.0;
static CGFloat const MINIMUM_TEXTFIELD_WIDTH = 56.0;
static CGFloat const PADDING_TOP = 10.0;
static CGFloat const PADDING_BOTTOM = 10.0;
static CGFloat const PADDING_LEFT = 8.0;
static CGFloat const PADDING_RIGHT = 8.0;
static CGFloat const STANDARD_ROW_HEIGHT = 25.0;

static CGFloat const FIELD_LABEL_MARGIN_LEFT = 4.0; // Note: Same as CLTokenView.PADDING_X

@interface CLTokenInputView () <CLBackspaceDetectingTextFieldDelegate, CLTokenViewDelegate>

@property (strong, nonatomic) NSMutableArray *tokens;
@property (strong, nonatomic) NSMutableArray *tokenViews;
@property (strong, nonatomic) CLBackspaceDetectingTextField *textField;
@property (strong, nonatomic) UILabel *fieldLabel;


@property (assign, nonatomic) CGFloat intrinsicContentHeight;

@end

@implementation CLTokenInputView

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.textField = [[CLBackspaceDetectingTextField alloc] initWithFrame:self.bounds];
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.delegate = self;
    [self.textField addTarget:self
                       action:@selector(onTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    [self addSubview:self.textField];

    self.tokens = [NSMutableArray arrayWithCapacity:20];
    self.tokenViews = [NSMutableArray arrayWithCapacity:20];

    self.fieldLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.fieldLabel.font = self.textField.font;
    self.fieldLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:self.fieldLabel];
    self.fieldLabel.hidden = YES;

    self.intrinsicContentHeight = STANDARD_ROW_HEIGHT;
    [self repositionViews];
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
    return CGSizeMake(UIViewNoIntrinsicMetric, MAX(45, self.intrinsicContentHeight));
}


#pragma mark - Adding / Removing Tokens

- (void)addToken:(CLToken *)token
{
    if ([self.tokens containsObject:token]) {
        return;
    }

    [self.tokens addObject:token];
    CLTokenView *tokenView = [[CLTokenView alloc] initWithToken:token];
    tokenView.delegate = self;
    CGSize intrinsicSize = tokenView.intrinsicContentSize;
    tokenView.frame = CGRectMake(0, 0, intrinsicSize.width, intrinsicSize.height);
    [self.tokenViews addObject:tokenView];
    [self addSubview:tokenView];

    self.textField.text = @"";
    // Clearing text programmatically doesn't call this automatically
    [self onTextFieldDidChange:self.textField];

    [self repositionViews];
}


#pragma mark - Repositioning Views

- (void)repositionViews
{
    CGRect bounds = self.bounds;
    CGFloat availableWidth = CGRectGetWidth(bounds) - PADDING_LEFT - PADDING_RIGHT;

    CGFloat curX = PADDING_LEFT;
    CGFloat curY = PADDING_TOP;
    CGFloat totalHeight = STANDARD_ROW_HEIGHT;

    // Position field label (if field name is set)
    if (!self.fieldLabel.hidden) {
        CGRect fieldLabelRect = self.fieldLabel.frame;
        fieldLabelRect.origin.x = curX + FIELD_LABEL_MARGIN_LEFT;
        fieldLabelRect.origin.y = curY + ((STANDARD_ROW_HEIGHT-CGRectGetHeight(fieldLabelRect))/2.0);
        self.fieldLabel.frame = fieldLabelRect;

        curX = CGRectGetMaxX(fieldLabelRect) + HSPACE;
    }

    // Position token views
    CGRect tokenRect = CGRectNull;
    for (UIView *tokenView in self.tokenViews) {
        tokenRect = tokenView.frame;

        if (curX + CGRectGetWidth(tokenRect) > availableWidth) {
            // Need a new line
            curX = PADDING_LEFT;
            curY += STANDARD_ROW_HEIGHT+VSPACE;
            totalHeight += STANDARD_ROW_HEIGHT;
        }

        tokenRect.origin.x = curX;
        // Center our tokenView vertially within STANDARD_ROW_HEIGHT
        tokenRect.origin.y = curY + ((STANDARD_ROW_HEIGHT-CGRectGetHeight(tokenRect))/2.0);
        tokenView.frame = tokenRect;

        curX = CGRectGetMaxX(tokenRect) + HSPACE;
    }

    CGFloat availableWidthForTextField = availableWidth;
    if (!CGRectIsNull(tokenRect)) {
        availableWidthForTextField -= curX - HSPACE + TEXT_FIELD_HSPACE;
        // Remove HSPACE, replace with TEXT_FIELD_HSPACE
        curX -= HSPACE;
    }
    if (availableWidthForTextField < MINIMUM_TEXTFIELD_WIDTH) {
        availableWidthForTextField = availableWidth;
        curX = PADDING_LEFT;
        curY += STANDARD_ROW_HEIGHT+VSPACE;
        totalHeight += STANDARD_ROW_HEIGHT;
    }
    // Always indent by a little bit
    curX += TEXT_FIELD_HSPACE;
    availableWidthForTextField -= TEXT_FIELD_HSPACE;

    CGRect textFieldRect = self.textField.frame;
    textFieldRect.origin.x = curX;
    textFieldRect.origin.y = curY;
    textFieldRect.size.width = availableWidthForTextField;
    textFieldRect.size.height = STANDARD_ROW_HEIGHT;
    self.textField.frame = textFieldRect;

    self.intrinsicContentHeight = CGRectGetMaxY(textFieldRect)+PADDING_BOTTOM;
    [self invalidateIntrinsicContentSize];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidDeleteBackwards:(UITextField *)textField
{
    if (textField.text.length == 0) {
        NSLog(@"Attempt to select last token");
        CLTokenView *tokenView = self.tokenViews.lastObject;
        if (tokenView) {
            [self selectTokenView:tokenView animated:YES];
            [self.textField resignFirstResponder];
        }
    } else {
        NSLog(@"Deleted");
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self unselectAllTokenViewsAnimated:YES];
}


#pragma mark - Text Field Changes

- (void)onTextFieldDidChange:(id)sender
{
    [self.delegate tokenInputView:self didChangeText:self.textField.text];
}


#pragma mark - CLTokenViewDelegate

- (void)tokenViewDidRequestDelete:(CLTokenView *)tokenView replaceWithText:(NSString *)replacementText
{
    NSInteger index = [self.tokenViews indexOfObject:tokenView];
    if (index == NSNotFound) {
        return;
    }
    // First, refocus the text field
    [self.textField becomeFirstResponder];
    if (replacementText.length > 0) {
        self.textField.text = replacementText;
    }
    // Then remove the view from our data
    [self.tokenViews removeObjectAtIndex:index];
    [tokenView removeFromSuperview];
    CLToken *removedToken = self.tokens[index];
    [self.tokens removeObjectAtIndex:index];
    [self.delegate tokenInputView:self didRemoveToken:removedToken];
    [self repositionViews];
}

- (void)tokenViewDidRequestSelection:(CLTokenView *)tokenView
{
    [self selectTokenView:tokenView animated:YES];
}


#pragma mark - Token selection

- (void)selectTokenView:(CLTokenView *)tokenView animated:(BOOL)animated
{
    [tokenView setSelected:YES animated:animated];
    for (CLTokenView *otherTokenView in self.tokenViews) {
        if (otherTokenView != tokenView) {
            [otherTokenView setSelected:NO animated:animated];
        }
    }
}

- (void)unselectAllTokenViewsAnimated:(BOOL)animated
{
    for (CLTokenView *tokenView in self.tokenViews) {
        [tokenView setSelected:NO animated:animated];
    }
}


#pragma mark - (Optional) Field Name

- (void)setFieldName:(NSString *)fieldName
{
    if (_fieldName == fieldName) {
        return;
    }
    NSString *oldFieldName = _fieldName;
    _fieldName = fieldName;

    self.fieldLabel.text = _fieldName;
    [self.fieldLabel sizeToFit];
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

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
