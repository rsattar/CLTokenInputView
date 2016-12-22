//
//  CLTokenView.m
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLTokenView.h"

#import <QuartzCore/QuartzCore.h>

static NSString *const UNSELECTED_LABEL_FORMAT = @"%@,";
static NSString *const UNSELECTED_LABEL_NO_COMMA_FORMAT = @"%@";


@interface CLTokenView ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) UIView *selectedBackgroundView;
@property (strong, nonatomic) UILabel *selectedLabel;

@property (copy, nonatomic) NSString *displayText;

@end

@implementation CLTokenView

- (id)initWithToken:(CLToken *)token font:(nullable UIFont *)font
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        UIColor *tintColor = [UIColor colorWithRed:0.0823 green:0.4941 blue:0.9843 alpha:1.0];
        if ([self respondsToSelector:@selector(tintColor)]) {
            tintColor = self.tintColor;
        }
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        if (font) {
            self.label.font = font;
        }
        self.label.textColor = tintColor;
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];

        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView.backgroundColor = tintColor;
        self.selectedBackgroundView.layer.cornerRadius = 3.0;
        [self addSubview:self.selectedBackgroundView];
        self.selectedBackgroundView.hidden = YES;

        self.selectedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.selectedLabel.font = self.label.font;
        self.selectedLabel.textColor = [UIColor whiteColor];
        self.selectedLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.selectedLabel];
        self.selectedLabel.hidden = YES;

        self.displayText = token.displayText;

        self.hideUnselectedComma = NO;

        [self updateLabelAttributedText];
        self.selectedLabel.text = token.displayText;

        // Listen for taps
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:tapRecognizer];

        [self setNeedsLayout];

    }
    return self;
}

#pragma mark - Size Measurements

- (CGSize)intrinsicContentSize
{
    CGSize labelIntrinsicSize = self.selectedLabel.intrinsicContentSize;
    return CGSizeMake(labelIntrinsicSize.width+self.padding.left+self.padding.right, labelIntrinsicSize.height+self.padding.top+self.padding.bottom);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize fittingSize = CGSizeMake(size.width-(self.padding.left+self.padding.right), size.height-(self.padding.top+self.padding.bottom));
    CGSize labelSize = [self.selectedLabel sizeThatFits:fittingSize];
    return CGSizeMake(labelSize.width+(self.padding.left+self.padding.right), labelSize.height+(self.padding.top+self.padding.bottom));
}


#pragma mark - Tinting


- (void)setTintColor:(UIColor *)tintColor
{
    if ([UIView instancesRespondToSelector:@selector(setTintColor:)]) {
        super.tintColor = tintColor;
    }
    self.label.textColor = tintColor;
    self.selectedBackgroundView.backgroundColor = tintColor;
    [self updateLabelAttributedText];
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

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (_selected == selected) {
        return;
    }
    _selected = selected;

    if (selected && !self.isFirstResponder) {
        [self becomeFirstResponder];
    } else if (!selected && self.isFirstResponder) {
        [self resignFirstResponder];
    }
    CGFloat selectedAlpha = (_selected ? 1.0 : 0.0);
    if (animated) {
        if (_selected) {
            self.selectedBackgroundView.alpha = 0.0;
            self.selectedBackgroundView.hidden = NO;
            self.selectedLabel.alpha = 0.0;
            self.selectedLabel.hidden = NO;
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.selectedBackgroundView.alpha = selectedAlpha;
            self.selectedLabel.alpha = selectedAlpha;
        } completion:^(BOOL finished) {
            if (!_selected) {
                self.selectedBackgroundView.hidden = YES;
                self.selectedLabel.hidden = YES;
            }
        }];
    } else {
        self.selectedBackgroundView.hidden = !_selected;
        self.selectedLabel.hidden = !_selected;
    }
}


#pragma mark - Attributed Text
- (void)setDefaultTextAttributes:(NSDictionary<NSString *,id> *)defaultTextAttributes
{
    if (![_defaultTextAttributes isEqualToDictionary:defaultTextAttributes]) {
        _defaultTextAttributes = defaultTextAttributes;
        [self updateLabelAttributedText];
        [self setNeedsLayout];
    }
}

- (void)setSelectedTextAttributes:(NSDictionary<NSString *,id> *)selectedTextAttributes
{
    if (![_selectedTextAttributes isEqualToDictionary:selectedTextAttributes]) {
        _selectedTextAttributes = selectedTextAttributes;
        [self updateLabelAttributedText];
        [self setNeedsLayout];
    }
}

- (void)updateLabelAttributedText
{
    // Configure for the token, unselected shows "[displayText]," and selected is "[displayText]"
    NSString *format = UNSELECTED_LABEL_FORMAT;
    if (self.hideUnselectedComma) {
        format = UNSELECTED_LABEL_NO_COMMA_FORMAT;
    }
    NSString *labelString = [NSString stringWithFormat:format, self.displayText];
    NSDictionary<NSString *, id>* attributes = self.defaultTextAttributes ?: @{NSFontAttributeName : self.label.font,
                                                                           NSForegroundColorAttributeName : [UIColor lightGrayColor]};
    NSMutableAttributedString *attrString =
    [[NSMutableAttributedString alloc] initWithString:labelString
                                           attributes:attributes];
    NSRange tintRange = [labelString rangeOfString:self.displayText];
    // Make the name part the system tint color
    UIColor *tintColor = self.selectedBackgroundView.backgroundColor;
    if ([UIView instancesRespondToSelector:@selector(tintColor)]) {
        tintColor = self.tintColor;
    }
    [attrString setAttributes:@{NSForegroundColorAttributeName : tintColor}
                        range:tintRange];
    self.label.attributedText = attrString;
    
    NSMutableDictionary<NSString *, id>* selectedAttributes;
    if (self.selectedTextAttributes) {
        selectedAttributes = self.selectedTextAttributes;
    } else {
        selectedAttributes = [[NSMutableDictionary alloc] initWithDictionary: attributes];
        [selectedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    }
    self.selectedLabel.attributedText = [[NSAttributedString alloc] initWithString:self.displayText attributes:selectedAttributes];
    
}


#pragma mark - Laying out

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect bounds = self.bounds;

    self.backgroundView.frame = bounds;
    self.selectedBackgroundView.frame = bounds;

    CGRect labelFrame = UIEdgeInsetsInsetRect(bounds, self.padding);
    self.selectedLabel.frame = labelFrame;
    labelFrame.size.width += self.padding.left + self.padding.right;
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

- (UIKeyboardAppearance)keyboardAppearance
{
    return self.inputKeyboardAppearance;
}

- (UIKeyboardType)keyboardType
{
    return self.inputKeyboardType;
}


#pragma mark - First Responder (needed to capture keyboard)

-(BOOL)canBecomeFirstResponder
{
    return YES;
}


-(BOOL)resignFirstResponder
{
    BOOL didResignFirstResponder = [super resignFirstResponder];
    [self setSelected:NO animated:NO];
    return didResignFirstResponder;
}

-(BOOL)becomeFirstResponder
{
    BOOL didBecomeFirstResponder = [super becomeFirstResponder];
    [self setSelected:YES animated:NO];
    return didBecomeFirstResponder;
}


@end
