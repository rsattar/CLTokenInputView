//
//  CLTokenView.m
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLTokenView.h"

#import <QuartzCore/QuartzCore.h>

static CGFloat const PADDING_IMAGE_LEFT = 7.0;
static CGFloat const PADDING_IMAGE_RIGHT = 6.0;

static CGFloat const PADDING_X = 5.0;
static CGFloat const PADDING_Y = 2.0;

static NSString *const UNSELECTED_LABEL_FORMAT = @"%@,";
static NSString *const UNSELECTED_LABEL_NO_COMMA_FORMAT = @"%@";

CGFloat const CLTokenViewEditAnimationDuration = 0.3;

@interface CLTokenView ()

@property (nonatomic) CLToken *token;

@property (strong, nonatomic, readwrite) UIImageView *imageView;
@property (strong, nonatomic, readwrite) UILabel *label;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIButton *deleteButton;

@property (copy, nonatomic) NSString *displayText;

@end

@implementation CLTokenView

- (id)initWithToken:(CLToken *)token font:(nullable UIFont *)font
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.token = token;
        
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.backgroundColor = token.backgroundColor ?: [UIColor clearColor];
        self.backgroundView.layer.cornerRadius = 3.0;
        [self addSubview:self.backgroundView];
        
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteButton.alpha = 0.0f;
        [self.deleteButton setImage:[self deleteButtonImage] forState:UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteButton sizeToFit];
        [self.backgroundView addSubview:self.deleteButton];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_X, PADDING_Y, 0, 0)];
        self.label.font = token.font ?: font ?: [UIFont systemFontOfSize:12.0f];
        self.label.textColor = [UIColor whiteColor];
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.image = token.image;
        self.imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.imageView];
        
        self.displayText = token.displayText;
        self.hideUnselectedComma = YES;
        
        [self updateLabelAttributedText];
        
        // Listen for taps
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:tapRecognizer];
        
        [self setNeedsLayout];
        
    }
    return self;
}


- (UIImage *)deleteButtonImage {
    NSURL *bundleURL = [[NSBundle bundleForClass:[CLTokenView class]] URLForResource:@"CLTokenInputView" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    NSString *imagePath = [bundle pathForResource:@"delete-token" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

- (void)deleteButtonTapped {
    [self.delegate tokenViewDidRequestDelete:self replaceWithText:nil];
}

#pragma mark - Size Measurements

- (CGSize)intrinsicContentSize
{
    CGSize labelIntrinsicSize = self.label.intrinsicContentSize;
    CGFloat width = labelIntrinsicSize.width+(2.0*PADDING_X);
    if (self.imageView.image) {
        width += self.imageView.image.size.width + PADDING_IMAGE_RIGHT;
    }
    if (self.selected) {
        width += self.deleteButton.frame.size.width + (PADDING_X / 2);
    }
    
    return CGSizeMake(width, labelIntrinsicSize.height+(2.0*PADDING_Y));
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize fittingSize = CGSizeMake(size.width-(2.0*PADDING_X), size.height-(2.0*PADDING_Y));
    CGSize labelSize = [self.label sizeThatFits:fittingSize];
    CGFloat width = labelSize.width+(2.0*PADDING_X);
    if (self.imageView.image) {
        width += self.imageView.image.size.width + PADDING_IMAGE_RIGHT;
    }
    if (self.selected) {
        width += self.deleteButton.frame.size.width + (PADDING_X / 2);
    }
    
    return CGSizeMake(width, labelSize.height+(2.0*PADDING_Y));
}

#pragma mark - Hide Unselected Comma


- (void)setHideUnselectedComma:(BOOL)hideUnselectedComma
{
    if (_hideUnselectedComma == hideUnselectedComma) {
        return;
    }
    _hideUnselectedComma = hideUnselectedComma;
    [self updateLabelAttributedText];
}


#pragma mark - Taps

-(void)handleTapGestureRecognizer:(id)sender
{
    [self.delegate tokenViewDidRequestSelection:self];
}


#pragma mark - Selection

- (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [self setSelected:selected animated:animated updateFirstResponder:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated updateFirstResponder:(BOOL)updateFirstResponder
{
    if (_selected == selected) {
        return;
    }
    _selected = selected;

    if (selected && !self.isFirstResponder && updateFirstResponder) {
        [self becomeFirstResponder];
    } else if (!selected && self.isFirstResponder && updateFirstResponder) {
        [self resignFirstResponder];
    }
    
    self.backgroundView.backgroundColor = selected ? [self darkerColorForColor:self.token.backgroundColor] : self.token.backgroundColor;

    // Animate in/out delete button
    if (selected) {
        CGRect deleteButtonFrame = self.deleteButton.frame;
        deleteButtonFrame.origin.x = CGRectGetWidth(self.backgroundView.frame);
        deleteButtonFrame.size.width = deleteButtonFrame.size.height = 14.0f;
        deleteButtonFrame.origin.y = CGRectGetHeight(self.backgroundView.frame) / 2 - CGRectGetHeight(deleteButtonFrame) / 2;
        self.deleteButton.frame = deleteButtonFrame;
    }
    
    CGSize intrinsicSize = [self intrinsicContentSize];
    [UIView animateWithDuration:animated ? CLTokenViewEditAnimationDuration : 0 animations:^{
        self.frame = ({
            CGRect frame = self.frame;
            frame.size.width = intrinsicSize.width;
            frame;
        });
        self.deleteButton.alpha = selected ? 1.0f : 0.0f;
    }];
}


#pragma mark - Attributed Text


- (void)updateLabelAttributedText
{
    // Configure for the token, unselected shows "[displayText]," and selected is "[displayText]"
    NSString *format = UNSELECTED_LABEL_FORMAT;
    if (self.hideUnselectedComma) {
        format = UNSELECTED_LABEL_NO_COMMA_FORMAT;
    }
    NSString *labelString = [NSString stringWithFormat:format, self.displayText];
    NSMutableAttributedString *attrString =
    [[NSMutableAttributedString alloc] initWithString:labelString
                                           attributes:@{NSFontAttributeName : self.label.font,
                                                        NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    NSRange tintRange = [labelString rangeOfString:self.displayText];
    [attrString setAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}
                        range:tintRange];
    self.label.attributedText = attrString;
}


#pragma mark - Laying out

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect bounds = self.bounds;

    CGRect imageViewFrame = CGRectInset(bounds, PADDING_IMAGE_LEFT, PADDING_Y);
    imageViewFrame.size.width = self.imageView.image.size.width;
    self.imageView.frame = imageViewFrame;
    
    CGRect labelFrame = CGRectInset(bounds, PADDING_X, PADDING_Y);
    labelFrame.size.width += PADDING_X*2.0;
    if (self.imageView.image) {
        labelFrame.origin.x += imageViewFrame.size.width + PADDING_IMAGE_RIGHT;
    }
    self.label.frame = labelFrame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - UIKeyInput protocol

- (BOOL)hasText
{
    return YES;
}

- (void)insertText:(NSString *)text
{
    [self.delegate tokenViewDidRequestDelete:self replaceWithText:text];
}

- (void)deleteBackward
{
    [self.delegate tokenViewDidRequestDelete:self replaceWithText:nil];
}


#pragma mark - UITextInputTraits protocol (inherited from UIKeyInput protocol)

// Since a token isn't really meant to be "corrected" once created, disable autocorrect on it
// See: https://github.com/clusterinc/CLTokenInputView/issues/2
- (UITextAutocorrectionType)autocorrectionType
{
    return UITextAutocorrectionTypeNo;
}


#pragma mark - First Responder (needed to capture keyboard)

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
