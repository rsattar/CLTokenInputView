//
//  CLTokenInputViewController.h
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLTokenInputView.h"

@interface CLTokenInputViewController : UIViewController <CLTokenInputViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tokenInputTopSpace;
@property (strong, nonatomic) IBOutlet CLTokenInputView *tokenInputView;
@property (strong, nonatomic) IBOutlet CLTokenInputView *secondTokenInputView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopLayoutConstraint;
@end
