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
static CGFloat const VSPACE = 0.0;
static CGFloat const MINIMUM_TEXTFIELD_WIDTH = 56.0;

@interface CLTokenInputView () <CLBackspaceDetectingTextFieldDelegate, CLTokenViewDelegate>

@property (strong, nonatomic) NSMutableArray *tokens;
@property (strong, nonatomic) NSMutableArray *tokenViews;
@property (strong, nonatomic) CLBackspaceDetectingTextField *textField;

@property (assign, nonatomic) CGFloat intrinsicContentHeight;

@end

@implementation CLTokenInputView

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.textField = [[CLBackspaceDetectingTextField alloc] initWithFrame:self.bounds];
    self.textField.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.2];
    self.textField.delegate = self;
    [self.textField addTarget:self
                       action:@selector(onTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    [self addSubview:self.textField];

    self.tokens = [NSMutableArray arrayWithCapacity:20];
    self.tokenViews = [NSMutableArray arrayWithCapacity:20];

    self.intrinsicContentHeight = 44.0;
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
    return CGSizeMake(UIViewNoIntrinsicMetric, self.intrinsicContentHeight);
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
    CGFloat availableWidth = CGRectGetWidth(bounds);

    CGFloat curX = 0.0;
    CGFloat curY = 0.0;
    CGRect tokenRect = CGRectNull;
    for (UIView *tokenView in self.tokenViews) {
        tokenRect = tokenView.frame;

        if (curX + CGRectGetWidth(tokenRect) > availableWidth) {
            // Need a new line
            curY += 44.0;
            curX = 0.0;
        }

        tokenRect.origin.x = curX;
        tokenRect.origin.y = curY;
        tokenView.frame = tokenRect;

        curX = CGRectGetMaxX(tokenRect) + HSPACE;
    }

    CGFloat availableWidthForTextField = availableWidth;
    if (!CGRectIsNull(tokenRect)) {
        availableWidth -= CGRectGetMaxX(tokenRect) + HSPACE;
    }
    if (availableWidthForTextField < MINIMUM_TEXTFIELD_WIDTH) {
        availableWidthForTextField = CGRectGetWidth(bounds);
        curX = 0.0;
        curY += 44.0;
    }

    CGRect textFieldRect = self.textField.frame;
    textFieldRect.origin.x = curX;
    textFieldRect.origin.y = curY;
    textFieldRect.size.width = availableWidthForTextField;
    self.textField.frame = textFieldRect;

    self.intrinsicContentHeight = MAX(44.0, CGRectGetMaxY(textFieldRect));
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

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
