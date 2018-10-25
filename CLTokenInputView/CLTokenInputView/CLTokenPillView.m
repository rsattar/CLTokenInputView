//
//  CLTokenPillView.m
//  CLTokenInputView
//
//  Created by Doug Ross on 10/8/18.
//  Copyright © 2018 Cluster Labs, Inc. All rights reserved.
//

#import "CLToken.h"
#import "CLTokenPillView.h"

static const CGFloat kPillSpacing = 8.0f;
static const CGFloat kTitleHSpacing = 12.0f;
static const CGFloat kTitleVSpacing = 5.0f;
static const CGFloat kImageSpacing = 8.0f;
static const CGFloat kImageWidth = 10.0f;
static const CGFloat kImageHeight = 10.0f;

@interface CLTokenPillView ()
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UIView *pillView;
@property (strong, nonatomic) UIImageView *dismissImage;
@property (strong, nonatomic) UIView *dismissTapZone;
@end

@implementation CLTokenPillView

#pragma mark - Lifecycle

- (instancetype)initWithToken:(CLToken *)token font:(nullable UIFont *)font {
    self = [super init];
    if (self != nil) {
        _token = token;
        
        _pillView = [UIView new];
        _pillView.backgroundColor = UIColor.whiteColor;
        _pillView.layer.borderColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.0f].CGColor;
        _pillView.layer.cornerRadius = 12.0f;

        _pillView.layer.borderWidth = 1.0f;
        [self addSubview:_pillView];
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(kTitleHSpacing, kTitleVSpacing, 0.0f, 0.0f)];
        _title.font = font;
        _title.text = token.displayText;
        _title.textColor = [UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:1.0f];
        [_pillView addSubview:_title];
        
        _dismissImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dismissX" inBundle:[NSBundle bundleForClass:[CLTokenPillView class]] compatibleWithTraitCollection:nil]];
        _dismissImage.frame = CGRectMake(0.0f, 0.0f, kImageWidth, kImageHeight);
        [_pillView addSubview:_dismissImage];
        
        _dismissTapZone = [UIView new];
        _dismissTapZone.backgroundColor = UIColor.clearColor;
        UITapGestureRecognizer *dismissTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTapped:)];
        [_dismissTapZone addGestureRecognizer:dismissTapRecognizer];
        [_pillView addSubview:_dismissTapZone];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tokenTapped:)];
        [self addGestureRecognizer:tapRecognizer];
        
        self.maxWidth = CGFLOAT_MAX;
    }
    return self;
}

#pragma mark - Layout Related

- (CGSize)intrinsicContentSize {
    CGSize titleIntrinsicSize = self.title.intrinsicContentSize;
    
    CGFloat width = titleIntrinsicSize.width + kTitleHSpacing*2.0f + kImageWidth + kImageSpacing + kPillSpacing;
    
    return CGSizeMake(MIN(width, self.maxWidth), titleIntrinsicSize.height + kTitleVSpacing*2.0);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return self.intrinsicContentSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect pillViewFrame = self.bounds;
    pillViewFrame.size.width -= kPillSpacing;
    self.pillView.frame = pillViewFrame;
    
    CGSize titleIntrinsicSize = self.title.intrinsicContentSize;
    CGRect titleFrame = CGRectMake(kTitleHSpacing, kTitleVSpacing, titleIntrinsicSize.width, titleIntrinsicSize.height);
    self.title.frame = titleFrame;
    
    CGRect dismissImageFrame = self.dismissImage.frame;
    CGFloat dismissImageX = titleFrame.origin.x + titleFrame.size.width + kTitleHSpacing;
    CGFloat dismissImageY = pillViewFrame.size.height/2.0f - 4.0f;
    self.dismissImage.frame = CGRectMake(dismissImageX, dismissImageY, dismissImageFrame.size.width, dismissImageFrame.size.height);
    
    // if we are too wide, then we need to compress by taking width away from the title and
    // shifting the dismissImage left by that amount.  Should only happen if maxWidth has been
    // set.
    CGFloat layoutWidth = CGRectGetMaxX(self.dismissImage.frame) + kImageSpacing + kPillSpacing;
    if (layoutWidth > CGRectGetMaxX(self.bounds)) {
        CGFloat amountToAdjust = layoutWidth - CGRectGetMaxX(self.bounds);
        titleFrame = UIEdgeInsetsInsetRect(self.title.frame,
                                                 UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, amountToAdjust));
        self.title.frame = titleFrame;
        self.dismissImage.frame = UIEdgeInsetsInsetRect(self.dismissImage.frame,
                                                        UIEdgeInsetsMake(0.0f, -amountToAdjust, 0.0f, amountToAdjust));
    }
    
    CGFloat dismissTapZoneX = titleFrame.origin.x + titleFrame.size.width + kTitleHSpacing/2.0f;
    CGFloat dismissTapZoneWidth = pillViewFrame.size.width - titleFrame.size.width - kTitleHSpacing - kTitleHSpacing/2.0;
    self.dismissTapZone.frame = CGRectMake(dismissTapZoneX, 0.0f, dismissTapZoneWidth, pillViewFrame.size.height);
}

#pragma mark - Tinting

- (void)setTintColor:(UIColor *)tintColor {
    // for now let's do nothing
}

#pragma mark - Hide Unselected Comma

- (void)setHideUnselectedComma:(BOOL)hideUnselectedComma {
    // no-op for this subclass... we don't show commas when using pills
}

#pragma mark - Actions

- (IBAction)tokenTapped:(UITapGestureRecognizer *)sender {
    [self.delegate tokenViewDidRequestSelection:self];
}

- (void)dismissTapped:(UIButton *)sender {
    [self.delegate tokenViewDidRequestDelete:self replaceWithText:nil];
}

#pragma mark - Selection

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.selected == selected) {
        return;
    }
    [self setSelectedIVar:selected];

    if (selected && !self.isFirstResponder) {
        [self becomeFirstResponder];
    } else if (!selected && self.isFirstResponder) {
        [self resignFirstResponder];
    }

    [UIView animateWithDuration:0.25f animations:^{
        if (self.selected) {
            self.pillView.backgroundColor = [UIColor colorWithRed:0.0f green:0.51f blue:0.894f alpha:1.0f];
            self.title.textColor = UIColor.whiteColor;
            self.dismissImage.image = [UIImage imageNamed:@"dismissXWhite"
                                                 inBundle:[NSBundle bundleForClass:[CLTokenPillView class]] compatibleWithTraitCollection:nil];
        } else {
            self.pillView.backgroundColor = UIColor.whiteColor;
            self.title.textColor = UIColor.blackColor;
            self.dismissImage.image = [UIImage imageNamed:@"dismissX"
                                                 inBundle:[NSBundle bundleForClass:[CLTokenPillView class]] compatibleWithTraitCollection:nil];
        }
    }];
}

@end

