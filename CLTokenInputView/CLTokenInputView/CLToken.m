//
//  CLToken.m
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLToken.h"

@implementation CLToken

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[CLToken class]]) {
        return NO;
    }

    CLToken *otherObject = (CLToken *)object;
    if ([otherObject.displayText isEqualToString:self.displayText] &&
        [otherObject.context isEqual:self.context]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash
{
    return self.displayText.hash + self.context.hash;
}

@end
