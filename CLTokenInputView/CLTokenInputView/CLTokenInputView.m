//
//  CLTokenInputView.m
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLTokenInputView.h"

#import "CLBackspaceDetectingTextField.h"

@interface CLTokenInputView () <CLBackspaceDetectingTextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *tokens;
@property (strong, nonatomic) NSMutableArray *tokenViews;
@property (strong, nonatomic) CLBackspaceDetectingTextField *textField;

@end

@implementation CLTokenInputView

- (void)commonInit
{
    self.backgroundColor = [UIColor redColor];
    self.textField = [[CLBackspaceDetectingTextField alloc] initWithFrame:self.bounds];
    self.textField.delegate = self;
    [self.textField addTarget:self
                       action:@selector(onTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    [self addSubview:self.textField];

    self.tokens = [NSMutableArray arrayWithCapacity:20];
    self.tokenViews = [NSMutableArray arrayWithCapacity:20];
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
    return CGSizeMake(UIViewNoIntrinsicMetric, 44.0);
}


#pragma mark - Adding / Removing Tokens

- (void)addToken:(CLToken *)token
{
    if ([self.tokens containsObject:token]) {
        return;
    }

    [self.tokens addObject:token];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidDeleteBackwards:(UITextField *)textField
{
    if (textField.text.length == 0) {
        NSLog(@"Attempt to select last token");
    } else {
        NSLog(@"Deleted");
    }
}


#pragma mark - Text Field Changes

- (void)onTextFieldDidChange:(id)sender
{
    [self.delegate tokenInputView:self didChangeText:self.textField.text];
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
