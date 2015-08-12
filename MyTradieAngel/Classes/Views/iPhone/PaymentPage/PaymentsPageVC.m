//
//  PaymentsPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "PaymentsPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"
#import "AppUtils.h"

#import "ActionSheetPicker.h"

#import "PaymentCell.h"
#import "PaymentPageVC.h"

@interface PaymentsPageVC ()<UIActionSheetDelegate>
{
    int curTextFieldTag;
    NSInteger curItemIndex;
    
    BaseVC *baseVC;
    UIActionSheet *actionsheet;
    AbstractActionSheetPicker *actionSheetPicker;
}
@end

@implementation PaymentsPageVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *boldFontName = @"Optima-ExtraBlack";
    UIColor* darkColor = [UIColor colorWithRed:10.0/255 green:78.0/255 blue:108.0/255 alpha:1.0f];
    
    [baseVC makeButtonUI:self.showMoreBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.addBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.searchBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.cancelBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    
    [self.fromDateText setRightViewMode:UITextFieldViewModeAlways];
    self.fromDateText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_icon.png"]];
    
    [self.toDateText setRightViewMode:UITextFieldViewModeAlways];
    self.toDateText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_icon.png"]];
    
    self.popupMaskView = [[UIView alloc] init];
    [self.popupMaskView setFrame:self.view.frame];
    [self.view addSubview:self.popupMaskView];
    [self.popupMaskView setBackgroundColor:[UIColor blackColor]];
    [self.popupMaskView setAlpha:0.5f];
    [self.popupMaskView setHidden:YES];
    
    [self.view addSubview:self.popupFilterView];
    self.popupFilterView.layer.cornerRadius = 10.0f;
    self.popupFilterView.center = self.view.center;
    [self.popupFilterView setHidden:YES];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.filterTitle.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10.0f, 10.0f)];
    maskLayer.path = maskPath.CGPath;
    self.filterTitle.layer.mask = maskLayer;
    
    // Create Action Sheet
    NSString *actionSheetTitle = @"Please select a action you want"; //Action Sheet Title
    //NSString *destructiveTitle = @"Destructive Button"; //Action Sheet Button Titles
    NSString *cancelTitle = @"Cancel";
    actionsheet = [[UIActionSheet alloc]
                        initWithTitle:actionSheetTitle
                        delegate:self
                        cancelButtonTitle:cancelTitle
                        destructiveButtonTitle:nil
                        otherButtonTitles:@"View this payment", @"Delete this payment", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugPaymentsPageVC) NSLog(@"PaymentsPageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.itemCountLabel.text = [NSString stringWithFormat:@"    Total Payments: %d", baseVC.model.allData.count];
}

- (void)viewDidLayoutSubviews
{
    if ([UIScreen mainScreen].bounds.size.height == 568) { // if iphone Retina 4 inch
        CGRect rect = self.popupMaskView.frame;
        rect.size.height = 568.f;
        [self.popupMaskView setFrame:rect];
    }
}

// =================================================
// UITextField Delegate Delegate Methods
// =================================================
#pragma mark - UITextField Delegate Methods
//==================================================
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag >= 11  &&  textField.tag <= 13)
        return NO;
    else
        return YES;
}

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark- Button Delegate Methods
//==================================================
- (IBAction)buttonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (debugPaymentsPageVC) NSLog(@"PaymentsPageVC buttonPressed: %d", button.tag);
    [self.view setBackgroundColor:[UIColor clearColor]];
    if (button.tag == 1) { // Home button
        [baseVC goToPrevPage];
    } else if (button.tag == 2) { // Show More button
        [self initPopupFilterView];
        
        [self.popupMaskView setHidden:NO];
        [self.popupFilterView setHidden:NO];
    } else if (button.tag == 3) { // Add button
        [baseVC.model backupData];
        baseVC.paymentPageVC.flag = YES;
        [baseVC goToPaymentPage];
    } else if (button.tag == 4) { // OK button
        [self.popupFilterView setHidden:YES];
        [self.popupMaskView setHidden:YES];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-payments.php"] forKey:@"url"];
        [dic setObject:@"0" forKey:@"p"];
        
        if ([self.numText.text length] > 0) [dic setObject:self.numText.text forKey:@"inv_number"];
        if ([self.fromDateText.text length] > 0) [dic setObject:self.fromDateText.text forKey:@"from_date"];
        if ([self.toDateText.text length] > 0) [dic setObject:self.toDateText.text forKey:@"till_date"];
        if ([self.customerNameText.text length] > 0) [dic setObject:self.customerNameText.text forKey:@"cust_name"];
        if ([self.sortText.text length] > 0) [dic setObject:[baseVC.model getSortIndex:self.sortText.text] forKey:@"sort"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:GET_PAYMENT_LIST];
    } else if (button.tag == 5) { // Cancel button
        [self.popupFilterView setHidden:YES];
        [self.popupMaskView setHidden:YES];
    }
}

- (IBAction)textFieldPressed:(id)sender
{
    UITextField *text = (UITextField *)sender;
    
    if (debugPaymentsPageVC) NSLog(@"PaymentsPageVC textFieldPressed: %d", text.tag);
    
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        if (debugPaymentsPageVC) NSLog(@"PaymentsPageVC Picker Canceled");
    };
    
    if (text.tag == 11) {
        NSDate *today = [NSDate date];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a Start Date" datePickerMode:UIDatePickerModeDate selectedDate:today target:self action:@selector(dateWasSelected:sender:) origin:sender];
        [actionSheetPicker showActionSheetPicker];
    } else if (text.tag == 12) {
        NSDate *today = [NSDate date];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a End Date" datePickerMode:UIDatePickerModeDate selectedDate:today target:self action:@selector(dateWasSelected:sender:) origin:sender];
        [actionSheetPicker showActionSheetPicker];
    } else if (text.tag == 13) {
        NSArray *sortArray = [NSArray arrayWithObjects:@"Latest To Oldest", @"Oldest to Latest", nil];
        [ActionSheetStringPicker showPickerWithTitle:@"Select a sort" rows:sortArray initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    }
}

// =================================================
// Implementation Methods
// =================================================
#pragma mark - Implementation Methods
//==================================================
- (void)dateWasSelected:(NSDate *)selectedDate sender:(id)sender {
    UITextField *text = (UITextField *)sender;
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    text.text = [AppUtils getDateStringFromDate:selectedDate];
}
/*
 - (void)animalWasSelected:(NSNumber *)selectedIndex element:(id)element {
 //may have originated from textField or barButtonItem, use an IBOutlet instead of element
 }
 - (void)measurementWasSelectedWithBigUnit:(NSNumber *)bigUnit smallUnit:(NSNumber *)smallUnit element:(id)element {
 }
 */
- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}

// =================================================
// Actionsheet Methods
// =================================================
#pragma mark- Actionsheet Methods
//==================================================
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (debugPaymentsPageVC) NSLog(@"PaymentsPageVC actionSheet clickedButtonAtIndex: %d" , buttonIndex);
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    } else {
        NSDictionary *data = [baseVC.model.allData objectAtIndex:curItemIndex];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        if (buttonIndex == 0) { // edit button
            [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-payment.php"] forKey:@"url"];
            [dic setObject:[data valueForKey:@"pay_id"] forKey:@"id"];
            [dic setObject:@"VIEW_PAYMENT" forKey:@"target"];
            
            [baseVC.model backupData];
            baseVC.model.postOpts = dic;
            [baseVC callServer:GET_PAYMENT_DETAILS];
        } else if (buttonIndex == 1) { // delete button
            UIAlertView *confirmDlg = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure to delete this payment?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [confirmDlg show];
        }
    }
}

// =================================================
// AlertView Delegate Methods
// =================================================
#pragma mark- AlertView Delegate Methods
//==================================================
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [baseVC.model backupData];
        
        NSDictionary *data = [baseVC.model.allData objectAtIndex:curItemIndex];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"del-payment.php"] forKey:@"url"];
        [dic setObject:[data valueForKey:@"pay_id"] forKey:@"id"];
        baseVC.model.postOpts = dic;
        [baseVC callServer:DEL_PAYMENT];
    }
}

// =================================================
// Custom Methods
// =================================================
#pragma mark- Custom Methods
//==================================================
- (void)initPopupFilterView
{
    if (debugPaymentsPageVC) NSLog(@"PaymentsPageVC initPopupFilterView");
    
    self.fromDateText.text = @"";
    self.toDateText.text = @"";
    self.sortText.text = [baseVC.model.sorts objectAtIndex:0];
    self.numText.text = @"";
    self.customerNameText.text = @"";
}

// =================================================
// TableView Delegate Methods
// =================================================
#pragma mark- TableView Delegate Methods
//==================================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return baseVC.model.allData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 135.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PaymentCell";
    PaymentCell *cell = (PaymentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PaymentCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *data = [baseVC.model.allData objectAtIndex:indexPath.row];
    if (data) {
        cell.numLabel.text = [data objectForKey:@"inv_number"] != [NSNull null] ? [NSString stringWithFormat:@"Invoice# %@", [data valueForKey:@"inv_number"]] : @"";
        cell.dateLabel.text = [data objectForKey:@"inv_date"] != [NSNull null] ? [NSString stringWithFormat:@"dated %@", [AppUtils getConvertedDate:[data objectForKey:@"inv_date"]]] : @"";
        if ([data objectForKey:@"inv_total"] != [NSNull null]) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setCurrencySymbol:@""];
            NSString *numberString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[[data objectForKey:@"inv_total"] floatValue]]];
            cell.totalLabel.text = numberString;
        } else {
            cell.totalLabel.text = @"";
        }
        cell.paidDateLabel.text = [data objectForKey:@"pay_date"] != [NSNull null] ? [AppUtils getConvertedDate:[data objectForKey:@"pay_date"]] : @"";
        cell.customerNameLabel.text = [data objectForKey:@"cust_name"] != [NSNull null] ? [data objectForKey:@"cust_name"] : @"";
        if ([data objectForKey:@"pay_amt"] != [NSNull null]) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setCurrencySymbol:@""];
            NSString *numberString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[[data objectForKey:@"pay_amt"] floatValue]]];
            cell.amtLabel.text = numberString;
        } else {
            cell.amtLabel.text = @"";
        }
        cell.modeLabel.text = [data objectForKey:@"pay_mode"] != [NSNull null] ? [data valueForKey:@"pay_mode"] : @"";
        cell.modeDetailLabel.text = [data objectForKey:@"details"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (debugPaymentsPageVC) NSLog(@"PaymentsPageVC onSelectListItem");
    curItemIndex = indexPath.row;
    [actionsheet showInView:self.view];
}

- (void)tableViewScrollToTop
{
    if ([self numberOfSectionsInTableView:self.tableView] > 0) {
        NSIndexPath* top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
        [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *visibleRows = [self.tableView visibleCells];
    UITableViewCell *lastVisibleCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableView indexPathForCell:lastVisibleCell];
    
    if (baseVC.model.allData.count % MAXROWS == 0) {
        if (path.row == baseVC.model.allData.count-1) {
            int page = [[baseVC.model.postOpts valueForKey:@"p"] intValue] > 0  ?  [[baseVC.model.postOpts valueForKey:@"p"] intValue]  :  1;
            page += 1;
            [baseVC.model.postOpts setObject:[NSString stringWithFormat:@"%d", page] forKey:@"p"];
            [baseVC.model.postOpts setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-payments.php"] forKey:@"url"];
            [baseVC callServer:GET_PAYMENT_LIST];
        }
    }
}
@end
