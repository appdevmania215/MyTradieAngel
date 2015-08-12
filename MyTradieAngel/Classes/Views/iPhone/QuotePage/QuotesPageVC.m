//
//  QuotesPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "QuotesPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"
#import "AppUtils.h"

#import "QuoteCell.h"
#import "ActionSheetPicker.h"

@interface QuotesPageVC ()<UIActionSheetDelegate>
{
    int curTextFieldTag;
    NSInteger curItemIndex;
    
    BaseVC *baseVC;
    UIActionSheet *actionsheet;
    AbstractActionSheetPicker *actionSheetPicker;
}

@end

@implementation QuotesPageVC

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
                        otherButtonTitles:@"Edit this quote", @"Delete this quote",  @"View Pdf file", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugQuotesPageVC) NSLog(@"QuotesPageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.itemCountLabel.text = [NSString stringWithFormat:@"    Total Quotations: %d", baseVC.model.allData.count];
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
    
    if (debugQuotesPageVC) NSLog(@"QuotesPageVC buttonPressed: %d", button.tag);
    [self.view setBackgroundColor:[UIColor clearColor]];
    if (button.tag == 1) { // Home button
        [baseVC goToPrevPage];
    } else if (button.tag == 2) { // Show More button
        [self initPopupFilterView];
        
        [self.popupMaskView setHidden:NO];
        [self.popupFilterView setHidden:NO];
    } else if (button.tag == 3) { // Add button
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-latest-quotation-id.php"] forKey:@"url"];
        
        [baseVC.model backupData];
        baseVC.model.postOpts = dic;
        [baseVC callServer:GET_LATEST_QUOTE_ID];
    } else if (button.tag == 4) { // OK button
        [self.popupFilterView setHidden:YES];
        [self.popupMaskView setHidden:YES];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-quotations.php"] forKey:@"url"];
        [dic setObject:@"0" forKey:@"p"];
        if ([self.numText.text length] > 0) [dic setObject:self.numText.text forKey:@"quot_number"];
        if ([self.fromDateText.text length] > 0) [dic setObject:self.fromDateText.text forKey:@"from_date"];
        if ([self.toDateText.text length] > 0) [dic setObject:self.toDateText.text forKey:@"till_date"];
        if ([self.customerNameText.text length] > 0) [dic setObject:self.customerNameText.text forKey:@"cust_name"];
        if ([self.sortText.text length] > 0) [dic setObject:[baseVC.model getSortIndex:self.sortText.text] forKey:@"sort"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:GET_QUOTE_LIST];
    } else if (button.tag == 5) { // Cancel button
        [self.popupFilterView setHidden:YES];
        [self.popupMaskView setHidden:YES];
    } else if (button.tag == 6) { // OK Button
        [self.popupPdfOptView setHidden:YES];
        [self.pdfMaskView setHidden:YES];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"generate-quotation-pdf.php"] forKey:@"url"];
        NSString *appId = [[baseVC.model.allData objectAtIndex:curItemIndex] valueForKey:@"app_id"];
        [dic setObject:appId forKey:@"id"];
        
        if ([self.emailOptText.text length] > 0) [dic setObject:[baseVC.model getEmailOptIndex:self.emailOptText.text] forKey:@"send"];
        if ([self.emailIdText.text length] > 0) [dic setObject:[baseVC.model getQuoteEmailIdOptIndex:self.emailIdText.text] forKey:@"mf"];
        [dic setObject:@"GET_QUOTE_PDF" forKey:@"target"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:GET_QUOTE_PDF];
    } else if (button.tag == 7) { // Cancel Button
        [self.popupPdfOptView setHidden:YES];
        [self.pdfMaskView setHidden:YES];
    }
}

- (IBAction)textFieldPressed:(id)sender
{
    UITextField *text = (UITextField *)sender;
    
    if (debugQuotesPageVC) NSLog(@"QuotesPageVC textFieldPressed: %d", text.tag);
    
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        if (debugQuotesPageVC) NSLog(@"QuotesPageVC Picker Canceled");
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
        [ActionSheetStringPicker showPickerWithTitle:@"Select a using email id option" rows:baseVC.model.quoteEmailIdOpts initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
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
    if (debugQuotesPageVC) NSLog(@"QuotesPageVC actionSheet clickedButtonAtIndex: %d" , buttonIndex);
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    } else {
        NSDictionary *data = [baseVC.model.allData objectAtIndex:curItemIndex];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        if (buttonIndex == 0) { // edit button
            [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-quotation.php"] forKey:@"url"];
            [dic setObject:[data valueForKey:@"app_id"] forKey:@"id"];
            [dic setObject:@"EDIT_QUOTE" forKey:@"target"];
            
            [baseVC.model backupData];
            baseVC.model.postOpts = dic;
            [baseVC callServer:GET_QUOTE_DETAILS];
        } else if (buttonIndex == 1) { // delete button
            UIAlertView *confirmDlg = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure to delete this quote?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [confirmDlg show];
        } else if (buttonIndex == 2) { // pdf file button
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
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"del-quotation.php"] forKey:@"url"];
        [dic setObject:[data valueForKey:@"app_id"] forKey:@"id"];
        baseVC.model.postOpts = dic;
        [baseVC callServer:DEL_QUOTE];
    }
}

// =================================================
// Custom Methods
// =================================================
#pragma mark- Custom Methods
//==================================================
- (void)initPopupFilterView
{
    if (debugQuotesPageVC) NSLog(@"QuotesPageVC initPopupFilterView");
    
    self.fromDateText.text = @"";
    self.toDateText.text = @"";
    self.sortText.text = [baseVC.model.sorts objectAtIndex:0];
    self.numText.text = @"";
    self.customerNameText.text = @"";
}

- (void)initPopupPdfOptView
{
    if (debugQuotesPageVC) NSLog(@"QuotesPageVC initPopupPdfOptView");
    
    self.emailOptText.text = [baseVC.model.emailOpts objectAtIndex:0];
    self.emailIdText.text = [baseVC.model.quoteEmailIdOpts objectAtIndex:0];
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
    return 75.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"QuoteCell";
    QuoteCell *cell = (QuoteCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QuoteCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *data = [baseVC.model.allData objectAtIndex:indexPath.row];
    if (data) {
        cell.numLabel.text = [data objectForKey:@"quot_number"] != [NSNull null] ? [data objectForKey:@"quot_number"] : @"";
        cell.dateLabel.text = [data objectForKey:@"quot_date"] != [NSNull null] ? [AppUtils getConvertedDate:[data objectForKey:@"quot_date"]] : @"";
        cell.customerNameLabel.text = [data objectForKey:@"name"] != [NSNull null] ? [data objectForKey:@"name"] : @"";
        cell.customerAddrLabel.text = [data objectForKey:@"address"] != [NSNull null] ? [NSString stringWithFormat:@"Address: %@", [data objectForKey:@"address"]] : @"";
        if ([data objectForKey:@"qtotal"] != [NSNull null]) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setCurrencySymbol:@""];
            NSString *numberString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[[data objectForKey:@"qtotal"] floatValue]]];
            cell.amtLabel.text = numberString;
        } else {
            cell.amtLabel.text = @"";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (debugQuotesPageVC) NSLog(@"QuotesPageVC onSelectListItem");
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
            [baseVC.model.postOpts setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-quotations.php"] forKey:@"url"];
            [baseVC callServer:GET_QUOTE_LIST];
        }
    }
}
@end
