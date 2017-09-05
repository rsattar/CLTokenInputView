//
//  CLConstants.m
//  CLTokenInputView
//
//  Created by NakCheon Jung on 05/09/2017.
//  Copyright © 2017 Cluster Labs, Inc. All rights reserved.
//

#import "CLConstants.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

int ddLogLevel =
#ifdef DEBUG
DDLogLevelVerbose;
#else
DDLogLevelError;
#endif
