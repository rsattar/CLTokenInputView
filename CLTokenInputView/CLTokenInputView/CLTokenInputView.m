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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

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

@end
