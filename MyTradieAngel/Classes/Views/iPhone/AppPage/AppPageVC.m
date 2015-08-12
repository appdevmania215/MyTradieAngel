//
//  AppPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "AppPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"
#import "AppUtils.h"

#import "NSDate+DP.h"
#import "ActionSheetPicker.h"

@interface AppPageVC ()
{
    BaseVC *baseVC;
    AbstractActionSheetPicker *actionSheetPicker;
}
@property (weak, nonatomic) IBOutlet UIView *maskView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbarCancelDone;
@property (weak, nonatomic) IBOutlet UIPickerView *timePicker;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionDone:(id)sender;

@end

@implementation AppPageVC
{
    NSArray *monthDays;
    NSMutableArray *daysArray;
    NSArray *hoursArray;
    NSMutableArray *minutesArray;
    NSArray *amPmArray;
    
    NSString *currentMonthString;
    
    NSDate *fromDate;
    NSDate *toDate;
    
    int whichText;
}

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
    self.appId = @"";
    self.custNameTextLength = 0;
    self.customerId = 0;
    
    monthDays = [NSArray arrayWithObjects:[NSNumber numberWithInt:31], [NSNumber numberWithInt:28], [NSNumber numberWithInt:31], [NSNumber numberWithInt:30], [NSNumber numberWithInt:31], [NSNumber numberWithInt:30], [NSNumber numberWithInt:31], [NSNumber numberWithInt:31], [NSNumber numberWithInt:30], [NSNumber numberWithInt:31], [NSNumber numberWithInt:30], [NSNumber numberWithInt:31],nil];
    
    [self.fromTimeText setRightViewMode:UITextFieldViewModeAlways];
    self.fromTimeText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_icon.png"]];
    [self.toTimeText setRightViewMode:UITextFieldViewModeAlways];
    self.toTimeText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_icon.png"]];
    
    [self.dateText setRightViewMode:UITextFieldViewModeAlways];
    self.dateText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_icon.png"]];
    
    NSString *boldFontName = @"Optima-ExtraBlack";
    UIColor* redColor = [UIColor colorWithRed:255.0/255 green:0/255 blue:0/255 alpha:1.0f];
    UIColor* darkColor = [UIColor colorWithRed:10.0/255 green:78.0/255 blue:108.0/255 alpha:1.0f];
    
    [baseVC makeButtonUI:self.delBtn FontName:boldFontName FontSize:14.f BackColor:redColor];
    [baseVC makeButtonUI:self.saveBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    
    [self hideRepeatOptionView];
    
    [self.maskView setBackgroundColor:[UIColor blackColor]];
    [self.maskView setAlpha:0.5f];
    [self.maskView setHidden:YES];
    self.timePicker.hidden = YES;
    self.toolbarCancelDone.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugAppPageVC) NSLog(@"AppPageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidAppear:(BOOL)animated
{
    if ( !self.fromPdfVC ) {
        [self.appView setHidden:NO];
        [self.invView setHidden:YES];
        
        if ( self.flag ) [self initForm];
        else [self populateData];
    }
}

- (void)viewDidLayoutSubviews
{
    [self.appView layoutSubviews];
    [self.appScrollView setContentSize:CGSizeMake(320.f, 435.f)];
    [self.invView layoutSubviews];
    [self.invScrollView setContentSize:CGSizeMake(320.f, 600.f)];
}

- (void)scrolViewScrollToTop
{
    CGPoint upOffest = CGPointMake(0.f, 0.f);
    [self.appScrollView setContentOffset:upOffest animated:YES];
    [self.invScrollView setContentOffset:upOffest animated:YES];
}

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark - Button Delegate Methods
//==================================================
- (IBAction)buttonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (debugAppPageVC) NSLog(@"AppPageVC buttonPressed: %d", button.tag);
    
    if (button.tag == 1) { // close
        [baseVC goToPrevPage];
    } else if (button.tag == 2) { // invoice
        if ([self.tabBtn.titleLabel.text isEqualToString:@"Invoice"]) {
            [self.tabBtn setTitle:@"Appmt" forState:UIControlStateNormal];
            
            [self.appView setHidden:YES];
            [self.invView setHidden:NO];
            [self scrolViewScrollToTop];
        } else {
            [self.tabBtn setTitle:@"Invoice" forState:UIControlStateNormal];
            
            [self.invView setHidden:YES];
            [self.appView setHidden:NO];
            [self scrolViewScrollToTop];
        }
    } else if (button.tag == 3) { // save button
        if (self.customerId == 0  ||  [self.customerNameText.text isEqualToString:@""]  ||  [self.addressText.text isEqualToString:@""]  ||  [self.contactPhoneNoText.text isEqualToString:@""]  ||  [self.emailIdText.text isEqualToString:@""]  ||  [self.noteText.text isEqualToString:@""]) {
            [baseVC showToastMessage:@"Please fill the form" ForSec:1];
            return;
        }
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        [dic setObject:self.appId forKey:@"id"];
        NSString *date = [AppUtils getDateStringFromDate:fromDate];
        [dic setObject:date forKey:@"dt"];
        [dic setObject:[AppUtils getDateStringWithHourFromDate:fromDate] forKey:@"start"];
        [dic setObject:[AppUtils getDateStringWithHourFromDate:toDate] forKey:@"end"];
        [dic setObject:self.customerNameText.text forKey:@"name"];
        [dic setObject:self.addressText.text forKey:@"add"];
        [dic setObject:self.contactPhoneNoText.text forKey:@"phone"];
        [dic setObject:self.emailIdText.text forKey:@"email"];
        [dic setObject:self.noteText.text forKey:@"notes"];
        [dic setObject:[NSString stringWithFormat:@"%d", self.customerId] forKey:@"cust_id"];
        
        if (self.compBtn.selected) {
            [dic setObject:@"1" forKey:@"complete"];
        } else {
            [dic setObject:@"0" forKey:@"complete"];
        }
        [dic setObject:self.invoiceIdText.text forKey:@"inv_number"];
        [dic setObject:[NSString stringWithFormat:@"%@ 00:00:00", self.dateText.text] forKey:@"inv_date"];
        [dic setObject:self.extraInfoText.text forKey:@"inv_notes"];
        [dic setObject:self.item1Text.text forKey:@"i1"];
        [dic setObject:self.price1Text.text forKey:@"p1"];
        [dic setObject:self.item2Text.text forKey:@"i2"];
        [dic setObject:self.price2Text.text forKey:@"p2"];
        [dic setObject:self.item3Text.text forKey:@"i3"];
        [dic setObject:self.price3Text.text forKey:@"p3"];
        [dic setObject:self.item4Text.text forKey:@"i4"];
        [dic setObject:self.price4Text.text forKey:@"p4"];
        [dic setObject:self.item5Text.text forKey:@"i5"];
        [dic setObject:self.price5Text.text forKey:@"p5"];
        [dic setObject:self.item6Text.text forKey:@"i6"];
        [dic setObject:self.price6Text.text forKey:@"p6"];
        [dic setObject:self.item7Text.text forKey:@"i7"];
        [dic setObject:self.price7Text.text forKey:@"p7"];
        [dic setObject:self.item8Text.text forKey:@"i8"];
        [dic setObject:self.price8Text.text forKey:@"p8"];
        [dic setObject:self.item9Text.text forKey:@"i9"];
        [dic setObject:self.price9Text.text forKey:@"p9"];
        [dic setObject:self.item10Text.text forKey:@"i10"];
        [dic setObject:self.price10Text.text forKey:@"p10"];
        [dic setObject:self.grossTotalText.text forKey:@"gtotal"];
        [dic setObject:self.taxItem forKey:@"tax_label"];
        [dic setObject:[NSString stringWithFormat:@"%.02f", self.taxPercent] forKey:@"tax_percent"];
        [dic setObject:self.netTotalText.text forKey:@"total"];
        
        UIButton *button = (UIButton *)[self.view viewWithTag:15];
        [dic setObject:[NSString stringWithFormat:@"%d", button.selected] forKey:@"recur_flag"];
        if (button.selected) {
            NSArray *weekDays = [NSArray arrayWithObjects:@"mon", @"tue", @"wed", @"thu", @"fri", @"sat", @"sun", @"same_date", nil];
            for (int i=0; i<=7; i++) {
                int tag = i + 21;
                button = (UIButton *)[self.view viewWithTag:tag];
                [dic setObject:[NSString stringWithFormat:@"%d", button.selected] forKey:weekDays[i]];
            }
            [dic setObject:[baseVC.model getRepeatWeekOptIndex:self.repeatOptText.text] forKey:@"every_week"];
        }
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:ADD_APP];
    } else if (button.tag == 4) { // delete
        if ([self.appId isEqualToString:@""]) {
            [baseVC showToastMessage:@"Select the app." ForSec:2];
            return;
        }
        
        UIAlertView *confirmDlg = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure to delete this appointment?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmDlg show];
    } else if (button.tag >= 15  &&  button.tag < 32) { // Repeat and WeekDay buttons
        button.selected = !button.selected;
        if (button.tag == 15) {
            if (button.selected) {
                [UIView animateWithDuration:0.5
                                      delay:0.1
                                    options: UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     [self showRepeatOptionView];
                                 }
                                 completion:^(BOOL finished){
                                 }];
            } else {
                [UIView animateWithDuration:0.5
                                      delay:0.1
                                    options: UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     [self hideRepeatOptionView];
                                 }
                                 completion:^(BOOL finished){
                                 }];
            }
        }
    } else if (button.tag == 32) { // preview invoice pdf
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"generate-invoice-pdf.php"] forKey:@"url"];
        [dic setObject:self.appId forKey:@"id"];
        
        [dic setObject:@"0" forKey:@"send"];
        [dic setObject:@"0" forKey:@"mf"];
        [dic setObject:@"GET_INVOICE_PDF" forKey:@"target"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:GET_INVOICE_PDF];
    } else if (button.tag == 33) { // send invoice
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"generate-invoice-pdf.php"] forKey:@"url"];
        [dic setObject:self.appId forKey:@"id"];
        
        [dic setObject:@"1" forKey:@"send"];
        [dic setObject:@"0" forKey:@"mf"];
        [dic setObject:@"SEND_INVOICE_PDF" forKey:@"target"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:GET_INVOICE_PDF];
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
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:self.appId forKey:@"id"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:DEL_APP];
    }
}

// =================================================
// UITextField Delegate Methods
// =================================================
#pragma mark - UITextField Delegate Methods
//==================================================
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ((textField.tag>10 && textField.tag<30 && textField.tag!=13)  ||  (textField.tag==34))
        return NO;
    else
        return YES;
}

- (IBAction)textFieldPressed:(id)sender
{
    UITextField *text = (UITextField *)sender;
    if (debugAppPageVC) NSLog(@"AppPageVC textFieldPressed: %d", text.tag);
    
    if (text.tag == 11  ||  text.tag == 12) {
        if (text.tag == 11) {
            [self setTimePickerValue:fromDate];
            whichText = 0;
        } else if (text.tag == 12) {
            [self setTimePickerValue:toDate];
            whichText = 1;
        }
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.maskView.hidden = NO;
                             self.timePicker.hidden = NO;
                             self.toolbarCancelDone.hidden = NO;
                         }
                         completion:^(BOOL finished){
                         }];
    } else if (text.tag == 14) { //
        ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            if ([sender respondsToSelector:@selector(setText:)]) {
                [sender performSelector:@selector(setText:) withObject:selectedValue];
            }
        };
        
        ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
            if (debugInvoicesPageVC) NSLog(@"InvociesPageVC Picker Canceled");
        };
        
        [ActionSheetStringPicker showPickerWithTitle:@"Select a type" rows:baseVC.model.repeatWeekOpts initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.customerNameText];
    } else if (text.tag == 34) { // invoice date
        NSDate *today = [NSDate date];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a Date" datePickerMode:UIDatePickerModeDate selectedDate:today target:self action:@selector(dateWasSelected:sender:) origin:sender];
        [actionSheetPicker showActionSheetPicker];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 13) { // customer name
        NSString *text = textField.text;
        if (text.length >= 3  &&  text.length > self.custNameTextLength) {
            [self.view endEditing:YES]; // dismiss keyboard
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-customers-lookup.php"] forKey:@"url"];
            [dic setObject:text forKey:@"query"];
            [dic setObject:@"EDIT_APP" forKey:@"target"];
            
            baseVC.model.postOpts = dic;
            [baseVC callServer:GET_CUSTOMERS_LOOKUP];
        }
        self.custNameTextLength = text.length;
    }
    return YES;
}

- (IBAction)priceTextChanged:(id)sender {
    UITextField *text = (UITextField *)sender;
    if (debugInvoicePageVC) NSLog(@"InvoicePageVC priceTextChanged: %d", text.tag);
    if (text.tag > 40  &&  text.tag <= 50) {
        float totalPrice = [self getTotalPrices];
        NSString *string = [NSString stringWithFormat:@"%.02f", ceilf(totalPrice * 100) / 100];
        self.grossTotalText.text = string;
        float taxPrice = self.taxPercent * totalPrice / 100;
        string = [NSString stringWithFormat:@"%.02f", ceilf(taxPrice * 100) / 100];
        self.taxText.text = string;
        totalPrice += taxPrice;
        string = [NSString stringWithFormat:@"%.02f", ceilf(totalPrice * 100) / 100];
        self.netTotalText.text = string;
    }
}

- (float)getTotalPrices
{
    UITextField *text;
    float totalPrice = 0.0f;
    for (int tag=41; tag<=50; tag++) {
        text = (UITextField *)[self.view viewWithTag:tag];
        float price = [text.text floatValue];
        totalPrice += price;
    }
    return totalPrice;
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

- (void)showCustomers
{
    if (debugAppPageVC) NSLog(@"AppPageVC showCustomers");
    
    NSMutableArray *customers = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in baseVC.model.customers) {
        NSString *customer = [NSString stringWithFormat:@"%@", [dic valueForKey:@"value"]];
        [customers addObject:customer];
    }
    
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        NSString *string = (NSString *)selectedValue;
        NSArray *custStrings = [string componentsSeparatedByString:@","];
        [self.customerNameText performSelector:@selector(setText:) withObject:custStrings[0]];
        [self.emailIdText performSelector:@selector(setText:) withObject:custStrings[1]];
        NSDictionary *dic = baseVC.model.customers[selectedIndex];
        self.customerId = [[dic valueForKey:@"data"] intValue];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        if (debugInvoicesPageVC) NSLog(@"AppPageVC Picker Canceled");
    };
    [ActionSheetStringPicker showPickerWithTitle:@"Select a type" rows:customers initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.customerNameText];
}

// =================================================
// UIPickerViewDelegate Methods
// =================================================
#pragma mark - UIPickerViewDelegate(TimePicker) Methods
//==================================================
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}

// =================================================
// UIPickerViewDelegate Methods
// =================================================
#pragma mark - UIPickerViewDatasource(TimePicker) Methods
//==================================================
- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    // Custom View created for each component
    UILabel *pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        CGRect frame;
        if (component == 0) {
            frame = CGRectMake(0.0, 0.0, 120.f, 60.f);
        } else {
            frame = CGRectMake(0.0, 0.0, 60.f, 60.f);
        }
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:20.0f]];
    }
    
    if (component == 0) {
        pickerLabel.text = [daysArray objectAtIndex:row]; // Date
    } else if (component == 1) {
        pickerLabel.text =  [hoursArray objectAtIndex:row]; // Hours
    } else if (component == 2) {
        pickerLabel.text =  [minutesArray objectAtIndex:row]; // Mins
    } else {
        pickerLabel.text =  [amPmArray objectAtIndex:row]; // AM/PM
    }
    
    return pickerLabel;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) { // day
        return [daysArray count];
    } else if (component == 1) { // hour
        return 12;
    } else if (component == 2) { // min
        return 4;
    } else { // am/pm
        return 2;
    }
}

- (IBAction)actionCancel:(id)sender
{
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.maskView.hidden = YES;
                         self.timePicker.hidden = YES;
                         self.toolbarCancelDone.hidden = YES;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (IBAction)actionDone:(id)sender
{
    NSString *dateString = [NSString stringWithFormat:@"%d-%02d-%02d %@:%@:00 %@", self.selectedYear, self.selectedMonth, [self.timePicker selectedRowInComponent:0]+1, [hoursArray objectAtIndex:[self.timePicker selectedRowInComponent:1]], [minutesArray objectAtIndex:[self.timePicker selectedRowInComponent:2]], [amPmArray objectAtIndex:[self.timePicker selectedRowInComponent:3]]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSDate *date = [formatter dateFromString:dateString];
    
    dateString = [self getStringForTimeText:date];
    if (whichText == 0) {
        fromDate = date;
        self.fromTimeText.text = dateString;
    } else {
        toDate = date;
        self.toTimeText.text = dateString;
    }
    if ([fromDate compare:toDate] == NSOrderedDescending) {
        date = fromDate;
        dateString = self.fromTimeText.text;
        fromDate = toDate;
        self.fromTimeText.text = self.toTimeText.text;
        toDate = date;
        self.toTimeText.text = dateString;
    }
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.maskView.hidden = YES;
                         self.timePicker.hidden = YES;
                         self.toolbarCancelDone.hidden = YES;
                     }
                     completion:^(BOOL finished){
                     }];
}

// =================================================
// Custom Methods
// =================================================
#pragma mark - Custom Methods
//==================================================
- (void)showRepeatOptionView
{
    CGRect rect = self.repeatOptionView.frame;
    rect.size.height = 110.f;
    [self.repeatOptionView setFrame:rect];
    [self.repeatOptionView setHidden:NO];
}

- (void)hideRepeatOptionView
{
    CGRect rect = self.repeatOptionView.frame;
    rect.size.height = 0.f;
    [self.repeatOptionView setFrame:rect];
    [self.repeatOptionView setHidden:YES];
}

- (void)initForm
{
    if (debugAppPageVC) NSLog(@"AppPageVC initForm");
    [self.tabBtn setHidden:YES];
    [self hideRepeatOptionView];
    
    [self.delBtn setHidden:NO];
    [self.saveBtn setHidden:NO];
    self.compBtn.selected = NO;
    
    self.appId = @"";
    self.custNameTextLength = 0;
    self.customerId = 0;
    
    NSString *fromDateString = [NSString stringWithFormat:@"%d-%2d-01 09:00:00", self.selectedYear, self.selectedMonth];
    fromDate = [AppUtils getDateTimeFromString:fromDateString];
    NSString *toDateString = [NSString stringWithFormat:@"%d-%2d-01 09:15:00", self.selectedYear, self.selectedMonth];
    toDate = [AppUtils getDateTimeFromString:toDateString];
    [self initTimePicker:fromDate];
    
    self.fromTimeText.text = [self getStringForTimeText:fromDate];
    self.toTimeText.text = [self getStringForTimeText:toDate];
    
    self.customerNameText.text = @"";
    self.addressText.text = @"";
    self.emailIdText.text = @"";
    self.contactPhoneNoText.text = @"";
    self.noteText.text = @"";
    
    UIButton *button = (UIButton *)[self.view viewWithTag:15];
    button.selected = NO;
    for (int tag=21; tag<=28; tag++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:tag];
        button.selected = NO;
    }
    self.repeatOptText.text = [baseVC.model.repeatWeekOpts objectAtIndex:0];
    
    self.dateText.text = @"0000-00-00";
    self.extraInfoText.text = @"";
    
    self.item1Text.text = @"";
    self.price1Text.text = @"";
    self.item2Text.text = @"";
    self.price2Text.text = @"";
    self.item3Text.text = @"";
    self.price3Text.text = @"";
    self.item4Text.text = @"";
    self.price4Text.text = @"";
    self.item5Text.text = @"";
    self.price5Text.text = @"";
    self.item6Text.text = @"";
    self.price6Text.text = @"";
    self.item7Text.text = @"";
    self.price7Text.text = @"";
    self.item8Text.text = @"";
    self.price8Text.text = @"";
    self.item9Text.text = @"";
    self.price9Text.text = @"";
    self.item10Text.text = @"";
    self.price10Text.text = @"";
    
    self.grossTotalText.text = @"";
    self.taxItem = @"";
    self.taxPercent = 0;
    self.taxLabel.text = @"";
    self.taxText.text = @"";
    self.netTotalText.text = @"";
}

- (void)populateData
{
    if (debugAppPageVC) NSLog(@"AppPageVC populateData");
    [self.tabBtn setTitle:@"Invoice" forState:UIControlStateNormal];
    [self.tabBtn setHidden:NO];
    [self hideRepeatOptionView];
    
    NSDictionary *dic = baseVC.model.data;
    if ([[dic objectForKey:@"app_completed"] intValue] == 1) {
        [self.delBtn setHidden:YES];
        [self.saveBtn setHidden:YES];
        self.compBtn.selected = YES;
    } else {
        [self.delBtn setHidden:NO];
        [self.saveBtn setHidden:NO];
        self.compBtn.selected = NO;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    fromDate = [formatter dateFromString:[dic objectForKey:@"start_time"]];
    toDate = [formatter dateFromString:[dic objectForKey:@"end_time"]];
    [self initTimePicker:fromDate];
    
    self.fromTimeText.text = [self getStringForTimeText:fromDate];
    self.toTimeText.text = [self getStringForTimeText:toDate];
    
    self.appId = [dic valueForKey:@"event_id"];
    self.custNameTextLength = [[dic valueForKey:@"name"] length];
    self.customerId = [[dic valueForKey:@"cust_id"] intValue];
    
    self.customerNameText.text = [dic objectForKey:@"name"];
    self.addressText.text = [dic objectForKey:@"address"];
    self.emailIdText.text = [dic objectForKey:@"email"];
    self.contactPhoneNoText.text = [dic objectForKey:@"phone"];
    self.noteText.text = [dic objectForKey:@"notes"];
    
    UIButton *button = (UIButton *)[self.view viewWithTag:15];
    button.selected = NO;
    for (int tag=21; tag<=28; tag++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:tag];
        button.selected = NO;
    }
    self.repeatOptText.text = [baseVC.model.repeatWeekOpts objectAtIndex:0];
    
    self.invoiceIdText.text = [dic valueForKey:@"inv_number"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *invDate = [dateFormatter dateFromString:[dic valueForKey:@"inv_date"]];
    self.dateText.text = [AppUtils getDateStringFromDate:invDate];
    self.extraInfoText.text = [dic valueForKey:@"inv_notes"];
    
    self.item1Text.text = [dic valueForKey:@"item1"];
    self.price1Text.text = [[dic valueForKey:@"price1"] floatValue] > 0 ? [dic valueForKey:@"price1"] : @"";
    self.item2Text.text = [dic valueForKey:@"item2"];
    self.price2Text.text = [[dic valueForKey:@"price2"] floatValue] > 0 ? [dic valueForKey:@"price2"] : @"";
    self.item3Text.text = [dic valueForKey:@"item3"];
    self.price3Text.text = [[dic valueForKey:@"price3"] floatValue] > 0 ? [dic valueForKey:@"price3"] : @"";
    self.item4Text.text = [dic valueForKey:@"item4"];
    self.price4Text.text = [[dic valueForKey:@"price4"] floatValue] > 0 ? [dic valueForKey:@"price4"] : @"";
    self.item5Text.text = [dic valueForKey:@"item5"];
    self.price5Text.text = [[dic valueForKey:@"price5"] floatValue] > 0 ? [dic valueForKey:@"price5"] : @"";
    self.item6Text.text = [dic valueForKey:@"item6"];
    self.price6Text.text = [[dic valueForKey:@"price6"] floatValue] > 0 ? [dic valueForKey:@"price6"] : @"";
    self.item7Text.text = [dic valueForKey:@"item7"];
    self.price7Text.text = [[dic valueForKey:@"price7"] floatValue] > 0 ? [dic valueForKey:@"price7"] : @"";
    self.item8Text.text = [dic valueForKey:@"item8"];
    self.price8Text.text = [[dic valueForKey:@"price8"] floatValue] > 0 ? [dic valueForKey:@"price8"] : @"";
    self.item9Text.text = [dic valueForKey:@"item9"];
    self.price9Text.text = [[dic valueForKey:@"price9"] floatValue] > 0 ? [dic valueForKey:@"price9"] : @"";
    self.item10Text.text = [dic valueForKey:@"item10"];
    self.price10Text.text = [[dic valueForKey:@"price10"] floatValue] > 0 ? [dic valueForKey:@"price10"] : @"";
    
    self.grossTotalText.text = [dic valueForKey:@"gtotal"];
    self.taxItem = [dic valueForKey:@"tax_label"];
    self.taxPercent = [[dic valueForKey:@"tax_percent"] floatValue];
    self.taxLabel.text = [NSString stringWithFormat:@"Add %@ @ %@%%", [dic valueForKey:@"tax_label"], [dic valueForKey:@"tax_percent"]];
    float gtotal = [[dic objectForKey:@"gtotal"] floatValue];
    float tax = gtotal * [[dic objectForKey:@"tax_percent"] floatValue] / 100.0f;
    self.taxText.text = [NSString stringWithFormat:@"%.02f", tax];
    self.netTotalText.text = [dic valueForKey:@"total"];
}

- (void)initTimePicker:(NSDate *)date
{
    if (debugAppPageVC) NSLog(@"AppPageVC initTimePicker");
    
    // Custom Time Picker
    self.maskView.hidden = YES;
    self.timePicker.hidden = YES;
    self.toolbarCancelDone.hidden = YES;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    // PickerView -  days data
    daysArray = [[NSMutableArray alloc]init];
    int days = [[monthDays objectAtIndex:self.selectedMonth-1] integerValue];
    if (self.selectedYear%4 == 0  &&  self.selectedMonth == 2) days = 29;
    for (int i=1; i<=days; i++) {
        NSString *dateString = [NSString stringWithFormat:@"%d-%d-%d", self.selectedYear, self.selectedMonth, i];
        [formatter setDateFormat:@"yyyy-M-d"];
        NSDate *oneDate = [formatter dateFromString:dateString];
        [formatter setDateFormat:@"EEE dd"];
        [daysArray addObject:[formatter stringFromDate:oneDate]];
    }
    
    // PickerView -  Hours data
    hoursArray = @[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12"];
    
    // PickerView -  Minutes data
    minutesArray = [[NSMutableArray alloc]init];
    for (int i=0; i<60; i+=15) {
        [minutesArray addObject:[NSString stringWithFormat:@"%02d", i]];
    }
    
    // PickerView -  AM PM data
    amPmArray = @[@"AM",@"PM"];
    
    [self.timePicker reloadAllComponents];
}

- (void)setTimePickerValue:(NSDate *)dateTime
{
    if (debugAppPageVC) NSLog(@"AppPageVC setTimePickerValue: %@", dateTime);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    // Get Current  Date
    [formatter setDateFormat:@"EEE dd"];
    NSString *currentDateString = [formatter stringFromDate:dateTime];
    
    // Get Current  AM PM
    [formatter setDateFormat:@"a"];
    NSString *currentTimeAMPMString = [formatter stringFromDate:dateTime];
    
    // Get Current  Hour
    [formatter setDateFormat:@"hh"];
    NSString *currentHourString = [formatter stringFromDate:dateTime];
    
    // Get Current  Minutes
    [formatter setDateFormat:@"mm"];
    NSString *currentMinutesString = [formatter stringFromDate:dateTime];
    int min = [[formatter stringFromDate:dateTime] intValue];
    if (min > 45  &&  min < 60) {
        currentMinutesString = @"00";
        int hour = [currentHourString intValue] + 1;
        if (hour >= 12) {
            hour = hour % 12;
            if ([currentTimeAMPMString isEqualToString:@"PM"]) {
                currentTimeAMPMString = @"AM";
            } else {
                currentTimeAMPMString = @"PM";
            }
        }
        currentHourString = [NSString stringWithFormat:@"%02d", hour];
    }
    else if (min > 30  &&  min < 45) currentMinutesString = @"45";
    else if (min > 15  &&  min < 30) currentMinutesString = @"30";
    else if (min > 0  &&  min < 15) currentMinutesString = @"15";
    
    // PickerView - Default Selection as per current Date
    [self.timePicker selectRow:[daysArray indexOfObject:currentDateString] inComponent:0 animated:YES];
    [self.timePicker selectRow:[hoursArray indexOfObject:currentHourString] inComponent:1 animated:YES];
    [self.timePicker selectRow:[minutesArray indexOfObject:currentMinutesString] inComponent:2 animated:YES];
    [self.timePicker selectRow:[amPmArray indexOfObject:currentTimeAMPMString] inComponent:3 animated:YES];
}

- (NSString *)getStringForTimeText:(NSDate *)date
{
    if (debugAppPageVC) NSLog(@"AppPageVC getStringForTimeText: %@", date);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"EEE, MMM d, hh:mm a"];
    NSString *dateString = [formatter stringFromDate:date];
    
    return dateString;
}
@end
