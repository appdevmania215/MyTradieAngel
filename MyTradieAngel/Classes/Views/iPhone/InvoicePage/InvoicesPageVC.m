//
//  InvoicesPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "InvoicesPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"
#import "AppUtils.h"

#import "InvoiceCell.h"
#import "ActionSheetPicker.h"
#import "AbstractActionSheetPicker.h"

//#import "PaymentsPageVC.h"

@interface InvoicesPageVC ()<UIActionSheetDelegate>
{
    int curTextFieldTag;
    NSInteger curItemIndex;
    
    BaseVC *baseVC;
    UIActionSheet *actionsheet;
    AbstractActionSheetPicker *actionSheetPicker;
}
@end

@implementation InvoicesPageVC

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
    [baseVC makeButtonUI:self.addInvBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.searchBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.cancelBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.pdfOKBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.pdfCancelBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    
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
    
    self.pdfMaskView = [[UIView alloc] init];
    [self.pdfMaskView setFrame:self.view.frame];
    [self.view addSubview:self.pdfMaskView];
    [self.pdfMaskView setBackgroundColor:[UIColor blackColor]];
    [self.pdfMaskView setAlpha:0.5f];
    [self.pdfMaskView setHidden:YES];
    
    [self.view addSubview:self.popupPdfOptView];
    self.popupPdfOptView.layer.cornerRadius = 10.0f;
    self.popupPdfOptView.center = self.view.center;
    [self.popupPdfOptView setHidden:YES];
    
    maskLayer = [CAShapeLayer layer];
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.pdfOptTitle.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10.0f, 10.0f)];
    maskLayer.path = maskPath.CGPath;
    self.pdfOptTitle.layer.mask = maskLayer;
    
    // Create Action Sheet
    NSString *actionSheetTitle = @"Please select a action you want"; //Action Sheet Title
    //NSString *destructiveTitle = @"Destructive Button"; //Action Sheet Button Titles
    NSString *cancelTitle = @"Cancel";
    actionsheet = [[UIActionSheet alloc]
                        initWithTitle:actionSheetTitle
                        delegate:self
                        cancelButtonTitle:cancelTitle
                        destructiveButtonTitle:nil
                        otherButtonTitles:@"Edit this invoice", @"Delete this invoice", @"Payment", @"View Pdf file", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugInvoicesPageVC) NSLog(@"InvoicesPageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.invoiceNumLabel.text = [NSString stringWithFormat:@"    Total Invoices: %d", baseVC.model.allData.count];
}

- (void)viewDidLayoutSubviews
{
    if ([UIScreen mainScreen].bounds.size.height == 568) { // if iphone Retina 4 inch
        CGRect rect = self.popupMaskView.frame;
        rect.size.height = 568.f;
        [self.popupMaskView setFrame:rect];
        [self.pdfMaskView setFrame:rect];
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
    if (textField.tag >= 11  &&  textField.tag <= 16)
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
    
    if (debugInvoicesPageVC) NSLog(@"InvociesPageVC buttonPressed: %d", button.tag);
    [self.view setBackgroundColor:[UIColor clearColor]];
    if (button.tag == 1) {
        [baseVC goToPrevPage];
    } else if (button.tag == 2) {
        [self initPopupFilterView];
        
        [self.popupMaskView setHidden:NO];
        [self.popupFilterView setHidden:NO];
    } else if (button.tag == 3) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-latest-invoice-id.php"] forKey:@"url"];
        
        [baseVC.model backupData];
        baseVC.model.postOpts = dic;
        [baseVC callServer:GET_LATEST_INVOICE_ID];
    } else if (button.tag == 4) { // OK Button
        [self.popupFilterView setHidden:YES];
        [self.popupMaskView setHidden:YES];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-invoices.php"] forKey:@"url"];
        [dic setObject:@"0" forKey:@"p"];
        if ([self.invNumText.text length] > 0) [dic setObject:self.invNumText.text forKey:@"inv_number"];
        if ([self.fromDateText.text length] > 0) [dic setObject:self.fromDateText.text forKey:@"from_date"];
        if ([self.toDateText.text length] > 0) [dic setObject:self.toDateText.text forKey:@"till_date"];
        if ([self.invCustomerNameText.text length] > 0) [dic setObject:self.invCustomerNameText.text forKey:@"cust_name"];
        if ([self.typeText.text length] > 0) [dic setObject:[baseVC.model getInvType:self.typeText.text] forKey:@"types"];
        if ([self.sortText.text length] > 0) [dic setObject:[baseVC.model getSortIndex:self.sortText.text] forKey:@"sort"];
        [dic setObject:@"GET_INVOICE_LIST" forKey:@"target"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:GET_INVOICE_LIST];
    } else if (button.tag == 5) { // Cancel Button
        [self.popupFilterView setHidden:YES];
        [self.popupMaskView setHidden:YES];
    } else if (button.tag == 6) { // OK Button
        [self.popupPdfOptView setHidden:YES];
        [self.pdfMaskView setHidden:YES];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"generate-invoice-pdf.php"] forKey:@"url"];
        NSString *appId = [[baseVC.model.allData objectAtIndex:curItemIndex] valueForKey:@"app_id"];
        [dic setObject:appId forKey:@"id"];
        
        if ([self.emailOptText.text length] > 0) [dic setObject:[baseVC.model getEmailOptIndex:self.emailOptText.text] forKey:@"send"];
        if ([self.emailIdText.text length] > 0) [dic setObject:[baseVC.model getInvoiceEmailIdOptIndex:self.emailIdText.text] forKey:@"mf"];
        [dic setObject:@"GET_INVOICE_PDF" forKey:@"target"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:GET_INVOICE_PDF];
    } else if (button.tag == 7) { // Cancel Button
        [self.popupPdfOptView setHidden:YES];
        [self.pdfMaskView setHidden:YES];
    }
}

- (IBAction)textFieldPressed:(id)sender
{
    UITextField *text = (UITextField *)sender;
    
    if (debugInvoicesPageVC) NSLog(@"InvociesPageVC textFieldPressed: %d", text.tag);
    
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        if (debugInvoicesPageVC) NSLog(@"InvociesPageVC Picker Canceled");
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
        [ActionSheetStringPicker showPickerWithTitle:@"Select a type" rows:baseVC.model.invTypes initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    } else if (text.tag == 14) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select a sort" rows:baseVC.model.sorts initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    } else if (text.tag == 15) {
        done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            if ([sender respondsToSelector:@selector(setText:)]) {
                [sender performSelector:@selector(setText:) withObject:selectedValue];
            }
            if (selectedIndex == 1) {
                [self.emailIdText setHidden:NO];
            } else {
                [self.emailIdText setHidden:YES];
            }
        };
        
        [ActionSheetStringPicker showPickerWithTitle:@"Select a using email option" rows:baseVC.model.emailOpts initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    } else if (text.tag == 16) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select a using email id option" rows:baseVC.model.invoiceEmailIdOpts initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
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
    if (debugInvoicesPageVC) NSLog(@"InvoicesPageVC actionSheet clickedButtonAtIndex: %d" , buttonIndex);
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    } else {
        NSDictionary *data = [baseVC.model.allData objectAtIndex:curItemIndex];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        if (buttonIndex == 0) { // edit button
            [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-invoice.php"] forKey:@"url"];
            [dic setObject:[data valueForKey:@"app_id"] forKey:@"id"];
            [dic setObject:@"EDIT_INVOICE" forKey:@"target"];
            
            [baseVC.model backupData];
            baseVC.model.postOpts = dic;
            [baseVC callServer:GET_INVOICE_DETAILS];
        } else if (buttonIndex == 1) { // delete button
            UIAlertView *confirmDlg = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure to delete this invoice?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [confirmDlg show];
        } else if (buttonIndex == 2) { // money button
            [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-payments.php"] forKey:@"url"];
            [dic setObject:[data valueForKey:@"inv_number"] forKey:@"inv_number"];
            [dic setObject:@"EDIT_INVOICE" forKey:@"target"];
            
            [baseVC pushViewController:(UIViewController *)baseVC.paymentsPageVC];
            
            [baseVC.model backupData];
            baseVC.model.postOpts = dic;
            [baseVC callServer:GET_PAYMENT_LIST];
        } else if (buttonIndex == 3) { // pdf file button
            if ([AppUtils isDeviceOnline]) {
                [self initPopupPdfOptView];
                
                [self.pdfMaskView setHidden:NO];
                [self.popupPdfOptView setHidden:NO];
            } else {
                [baseVC showToastMessage:@"Device is now offline" ForSec:2];
            }
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
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"del-invoice.php"] forKey:@"url"];
        [dic setObject:[data valueForKey:@"app_id"] forKey:@"id"];
        baseVC.model.postOpts = dic;
        [baseVC callServer:DEL_INVOICE];
    }
}

// =================================================
// Custom Methods
// =================================================
#pragma mark- Custom Methods
//==================================================
- (void)initPopupFilterView
{
    if (debugInvoicesPageVC) NSLog(@"InvoicesPageVC initPopupFilterView");
    
    self.fromDateText.text = @"";
    self.toDateText.text = @"";
    self.typeText.text = [baseVC.model.invTypes objectAtIndex:0];
    self.sortText.text = [baseVC.model.sorts objectAtIndex:0];
    self.invNumText.text = @"";
    self.invCustomerNameText.text = @"";
}

- (void)initPopupPdfOptView
{
    if (debugInvoicesPageVC) NSLog(@"InvoicesPageVC initPopupPdfOptView");
    
    self.emailOptText.text = [baseVC.model.emailOpts objectAtIndex:0];
    self.emailIdText.text = [baseVC.model.invoiceEmailIdOpts objectAtIndex:0];
    [self.emailIdText setHidden:YES];
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
    return 95.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InvoiceCell";
    InvoiceCell *cell = (InvoiceCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InvoiceCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *data = [baseVC.model.allData objectAtIndex:indexPath.row];
    if (data) {
        cell.invNumLabel.text = [data objectForKey:@"inv_number"] != [NSNull null] ? [data objectForKey:@"inv_number"] : @"";
        cell.dateLabel.text = [data objectForKey:@"inv_date"] != [NSNull null] ? [AppUtils getConvertedDate:[data objectForKey:@"inv_date"]] : @"";
        cell.dateLabel2.text = [[data objectForKey:@"due_days"] intValue] > 0  ? [NSString stringWithFormat:@"Days Due: %@", [data objectForKey:@"due_days"]] : @"";
        cell.customerNameLabel.text = [data objectForKey:@"name"] != [NSNull null] ? [data objectForKey:@"name"] : @"";
        cell.customerAddrLabel.text = [data objectForKey:@"address"] != [NSNull null] ? [data objectForKey:@"address"] : @"";
        cell.customerAddrLabel.text = [data objectForKey:@"address"] != [NSNull null] ? [data objectForKey:@"address"] : @"";
        cell.invAmtLabel.text = [data objectForKey:@"total"] != [NSNull null] ? [data objectForKey:@"total"] : @"";
        cell.invAmtLabel2.text = [[data objectForKey:@"due"] intValue] > 0 ? [NSString stringWithFormat:@"Due: %@", [data objectForKey:@"due"]] : @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (debugInvoicesPageVC) NSLog(@"InvoicesPageVC onSelectListItem");
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
            [baseVC.model.postOpts setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-invoices.php"] forKey:@"url"];
            [baseVC.model.postOpts setObject:@"GET_INVOICE_LIST" forKey:@"target"];
            
            [baseVC callServer:GET_INVOICE_LIST];
        }
    }
}
@end
