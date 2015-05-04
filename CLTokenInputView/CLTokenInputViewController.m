//
//  CLTokenInputViewController.m
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLTokenInputViewController.h"

#import "CLToken.h"

@interface CLTokenInputViewController ()

@property (strong, nonatomic) NSArray *names;
@property (strong, nonatomic) NSArray *filteredNames;

@property (strong, nonatomic) NSMutableArray *selectedNames;

@end

@implementation CLTokenInputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Token Input Test";
        self.names = @[@"Brenden Mulligan",
                       @"Cluster Labs, Inc.",
                       @"Pat Fives",
                       @"Rizwan Sattar",
                       @"Taylor Hughes"];
        self.filteredNames = nil;
        self.selectedNames = [NSMutableArray arrayWithCapacity:self.names.count];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (![self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.tokenInputTopSpace.constant = 0.0;
    }
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [infoButton addTarget:self action:@selector(onFieldInfoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.tokenInputView.fieldName = @"To:";
    self.tokenInputView.fieldView = infoButton;
    self.tokenInputView.placeholderText = @"Enter a name";
    self.tokenInputView.accessoryView = [self contactAddButton];
    self.tokenInputView.drawBottomBorder = YES;
    
    self.secondTokenInputView.fieldName = NSLocalizedString(@"Cc:", nil);
    self.secondTokenInputView.drawBottomBorder = YES;
    self.secondTokenInputView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.tokenInputView.editing) {
        [self.tokenInputView beginEditing];
    }
}


#pragma mark - CLTokenInputViewDelegate

- (void)tokenInputView:(CLTokenInputView *)view didChangeText:(NSString *)text
{
    if ([text isEqualToString:@""]){
        self.filteredNames = nil;
        self.tableView.hidden = YES;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@", text];
        self.filteredNames = [self.names filteredArrayUsingPredicate:predicate];
        self.tableView.hidden = NO;
    }
    [self.tableView reloadData];
}

- (void)tokenInputView:(CLTokenInputView *)view didAddToken:(CLToken *)token
{
    NSString *name = token.displayText;
    [self.selectedNames addObject:name];
}

- (void)tokenInputView:(CLTokenInputView *)view didRemoveToken:(CLToken *)token
{
    NSString *name = token.displayText;
    [self.selectedNames removeObject:name];
}

- (CLToken *)tokenInputView:(CLTokenInputView *)view tokenForText:(NSString *)text
{
    if (self.filteredNames.count > 0) {
        NSString *matchingName = self.filteredNames[0];
        CLToken *match = [[CLToken alloc] initWithDisplayText:matchingName context:nil];
        return match;
    }
    // TODO: Perhaps if the text is a valid phone number, or email address, create a token
    // to "accept" it.
    return nil;
}

- (void)tokenInputViewDidEndEditing:(CLTokenInputView *)view
{
    NSLog(@"token input view did end editing: %@", view);
    view.accessoryView = nil;
}

- (void)tokenInputViewDidBeginEditing:(CLTokenInputView *)view
{
    
    NSLog(@"token input view did begin editing: %@", view);
    view.accessoryView = [self contactAddButton];
    [self.view removeConstraint:self.tableViewTopLayoutConstraint];
    self.tableViewTopLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.view addConstraint:self.tableViewTopLayoutConstraint];
    [self.view layoutIfNeeded];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *name = self.filteredNames[indexPath.row];
    cell.textLabel.text = name;
    if ([self.selectedNames containsObject:name]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *name = self.filteredNames[indexPath.row];
    CLToken *token = [[CLToken alloc] initWithDisplayText:name context:nil];
    if (self.tokenInputView.isEditing) {
        [self.tokenInputView addToken:token];
    }
    else if(self.secondTokenInputView.isEditing){
        [self.secondTokenInputView addToken:token];
    }
}


#pragma mark - Demo Button Actions


- (void)onFieldInfoButtonTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Field View Button"
                                                        message:@"This view is optional and can be a UIButton, etc."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
}


- (void)onAccessoryContactAddButtonTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Accessory View Button"
                                                        message:@"This view is optional and can be a UIButton, etc."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Demo Buttons
- (UIButton *)contactAddButton
{
    UIButton *contactAddButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [contactAddButton addTarget:self action:@selector(onAccessoryContactAddButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return contactAddButton;
}

@end
