//
//  CLTokenInputViewController.m
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLTokenInputViewController.h"

#import "CLToken.h"

UIColor *randomColor() {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@interface CLTokenData : NSObject

@property (nonatomic, nonnull) NSString *name;
@property (nonatomic, nullable) UIColor *color;

@end

@implementation CLTokenData

+ (instancetype)tokenWithName:(NSString *)name color:(UIColor *)color {
    CLTokenData *token = [self new];
    token.name = name;
    token.color = color;
    return token;
}

@end

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
        self.names = @[
					   [CLTokenData tokenWithName:@"Brenden Mulligan" color:randomColor()],
					   [CLTokenData tokenWithName:@"Cluster Labs, Inc." color:randomColor()],
					   [CLTokenData tokenWithName:@"Pat Fives" color:randomColor()],
					   [CLTokenData tokenWithName:@"Rizwan Sattar" color:randomColor()],
					   [CLTokenData tokenWithName:@"Taylor Hughes" color:randomColor()],
					   ];
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
    [super viewDidAppear:animated];
}


#pragma mark - CLTokenInputViewDelegate

- (void)tokenInputView:(CLTokenInputView *)view didChangeText:(NSString *)text
{
    if ([text isEqualToString:@""]){
        self.filteredNames = nil;
        self.tableView.hidden = YES;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name contains[cd] %@", text];
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        self.filteredNames = [[self.names filteredArrayUsingPredicate:predicate] sortedArrayUsingDescriptors:@[sortDescriptor]];
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
        CLTokenData *matchingData = self.filteredNames[0];
        CLToken *match = [[CLToken alloc] initWithDisplayText:matchingData.name context:matchingData];
        if (matchingData.color) {
            match.color = matchingData.color;
        }
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
    CLTokenData *nameData = self.filteredNames[indexPath.row];
    cell.textLabel.text = nameData.name;
	cell.textLabel.textColor = nameData.color ?: [UIColor blackColor];
    if ([self.selectedNames containsObject:nameData.name]) {
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

    CLTokenData *nameData = self.filteredNames[indexPath.row];
    CLToken *token = [[CLToken alloc] initWithDisplayText:nameData.name	context:nameData];
	if (nameData.color) {
		token.color = nameData.color;
	}
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
