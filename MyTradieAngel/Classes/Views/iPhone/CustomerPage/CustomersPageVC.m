//
//  CustomersPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "CustomersPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"
#import "AppUtils.h"

#import "CustomerPageVC.h"
#import "InvoicesPageVC.h"
#import "CustomerCell.h"

#import "ActionSheetPicker.h"

@interface CustomersPageVC ()<UIActionSheetDelegate>
{
    int curTextFieldTag;
    NSInteger curItemIndex;
    
    BaseVC *baseVC;
    UIActionSheet *actionsheet;
    AbstractActionSheetPicker *actionSheetPicker;
}

@end

@implementation CustomersPageVC

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
    
    [self.sortText setRightViewMode:UITextFieldViewModeAlways];
    self.sortText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdownarrow.png"]];
    
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
                        otherButtonTitles:@"Edit this customer", @"Delete this customer",  @"Add invoice", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugCustomersPageVC) NSLog(@"CustomersPageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.itemCountLabel.text = [NSString stringWithFormat:@"    Total Customers: %d", baseVC.model.allData.count];
}

- (void)viewDidLayoutSubviews
{
    if ( IS_IPHONE_5 ) { // if iphone Retina 4 inch
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
    if (textField.tag >= 5  &&  textField.tag <= 7)
        return NO;
    else
        return YES;
}

- (IBAction)textFieldPressed:(id)sender
{
    UITextField *text = (UITextField *)sender;
    
    if (debugCustomersPageVC) NSLog(@"CustomersPageVC textFieldPressed: %d", text.tag);
    
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        if (debugCustomersPageVC) NSLog(@"CustomersPageVC Picker Canceled");
    };
    
    if (text.tag == 6) {
        NSDate *today = [NSDate date];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a Start Date" datePickerMode:UIDatePickerModeDate selectedDate:today target:self action:@selector(dateWasSelected:sender:) origin:sender];
        [actionSheetPicker showActionSheetPicker];
    } else if (text.tag == 7) {
        NSDate *today = [NSDate date];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a End Date" datePickerMode:UIDatePickerModeDate selectedDate:today target:self action:@selector(dateWasSelected:sender:) origin:sender];
        [actionSheetPicker showActionSheetPicker];
    } else if (text.tag == 8) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select a sort" rows:baseVC.model.customerSorts initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    }
}

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark- Button Delegate Methods
//==================================================
- (IBAction)buttonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (debugCustomersPageVC) NSLog(@"CustomersPageVC buttonPressed: %d", button.tag);
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    if (button.tag == 1) { // Home button
        [baseVC goToPrevPage];
    } else if (button.tag == 2) { // Show More button
        [self initPopupFilterView];
        
        [self.popupMaskView setHidden:NO];
        [self.popupFilterView setHidden:NO];
    } else if (button.tag == 3) { // Add button
        [baseVC.model backupData];
        baseVC.customerPageVC.flag = YES;
        [baseVC goToCustomerPage];
    } else if (button.tag == 4) { // OK button
        [self.popupFilterView setHidden:YES];
        [self.popupMaskView setHidden:YES];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-customers.php"] forKey:@"url"];
        [dic setObject:@"0" forKey:@"p"];
        if ([self.fromDateText.text length] > 0) [dic setObject:self.fromDateText.text forKey:@"from_date"];
        if ([self.toDateText.text length] > 0) [dic setObject:self.toDateText.text forKey:@"till_date"];
        if ([self.customerNameText.text length] > 0) [dic setObject:self.customerNameText.text forKey:@"cust_name"];
        if ([self.sortText.text length] > 0) [dic setObject:[baseVC.model getCustomerSortIndex:self.sortText.text] forKey:@"sort"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:GET_CUSTOMER_LIST];
    } else if (button.tag == 5) { // Cancel button
        [self.popupFilterView setHidden:YES];
        [self.popupMaskView setHidden:YES];
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
    if (debugCustomersPageVC) NSLog(@"CustomersPageVC actionSheet clickedButtonAtIndex: %d" , buttonIndex);
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    } else {
        NSDictionary *data = [baseVC.model.allData objectAtIndex:curItemIndex];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        if (buttonIndex == 0) { // edit button
            [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-customer.php"] forKey:@"url"];
            [dic setObject:[data valueForKey:@"cust_id"] forKey:@"id"];
            [dic setObject:@"EDIT_CUSTOMER" forKey:@"target"];
            
            [baseVC.model backupData];
            baseVC.model.postOpts = dic;
            [baseVC callServer:GET_CUSTOMER_DETAILS];
        } else if (buttonIndex == 1) { // delete button
            UIAlertView *confirmDlg = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure to delete this customer?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [confirmDlg show];
        } else if (buttonIndex == 2) { // make invoice button
            [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-latest-invoice-id.php"] forKey:@"url"];
            [dic setObject:@"MAKE_INVOICE_FROM_CUSTOMERS" forKey:@"target"];
            [dic setObject:[data valueForKey:@"cust_id"] forKey:@"cust_id"];
            [dic setObject:[data valueForKey:@"name"] forKey:@"name"];
            [dic setObject:[data valueForKey:@"email"] forKey:@"email"];
            [dic setObject:[data valueForKey:@"phone"] forKey:@"phone"];
            [dic setObject:[data valueForKey:@"address"] forKey:@"address"];
            
            baseVC.model.postOpts = dic;
            [baseVC callServer:GET_LATEST_INVOICE_ID];
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
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"del-customer.php"] forKey:@"url"];
        [dic setObject:[data valueForKey:@"cust_id"] forKey:@"id"];
        baseVC.model.postOpts = dic;
        [baseVC callServer:DEL_CUSTOMER];
    }
}

// =================================================
// Custom Methods
// =================================================
#pragma mark- Custom Methods
//==================================================
- (void)initPopupFilterView
{
    if (debugCustomersPageVC) NSLog(@"CustomersPageVC initPopupFilterView");
    
    self.fromDateText.text = @"";
    self.toDateText.text = @"";
    self.sortText.text = [baseVC.model.customerSorts objectAtIndex:0];
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
    return 105.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomerCell";
    CustomerCell *cell = (CustomerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomerCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *data = [baseVC.model.allData objectAtIndex:indexPath.row];
    if (data) {
        cell.nameLabel.text = [data objectForKey:@"name"] != [NSNull null] ? [data objectForKey:@"name"] : @"";
        cell.emailLabel.text = [data objectForKey:@"email"] != [NSNull null] ? [data objectForKey:@"email"] : @"";
        cell.phoneLabel.text = [data objectForKey:@"phone"] != [NSNull null] ? [data objectForKey:@"phone"] : @"";
        cell.addrLabel.text = [data objectForKey:@"address"] != [NSNull null] ? [data objectForKey:@"address"] : @"";
        cell.dateLabel.text = [data objectForKey:@"signup_date"] != [NSNull null] ? [AppUtils getConvertedDate:[data objectForKey:@"signup_date"]] : @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (debugCustomersPageVC) NSLog(@"CustomersPageVC onSelectListItem");
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
            [baseVC.model.postOpts setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-customers.php"] forKey:@"url"];
            [baseVC callServer:GET_CUSTOMER_LIST];
        }
    }
}

@end
