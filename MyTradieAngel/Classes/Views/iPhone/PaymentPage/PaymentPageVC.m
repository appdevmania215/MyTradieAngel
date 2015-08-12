//
//  PaymentPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "PaymentPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"
#import "AppUtils.h"

#import "ActionSheetPicker.h"

@interface PaymentPageVC ()
{
    BaseVC *baseVC;
    AbstractActionSheetPicker *actionSheetPicker;
}

@end

@implementation PaymentPageVC

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
    [self.dateText setRightViewMode:UITextFieldViewModeAlways];
    self.dateText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_icon.png"]];
    
    self.payTypeView.layer.cornerRadius = 3.f;
    [self.payTypeText setRightViewMode:UITextFieldViewModeAlways];
    self.payTypeText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdownarrow.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugHeadsPageVC) NSLog(@"HeadsPageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidAppear:(BOOL)animated
{
    if ( self.flag ) [self initForm];
    else [self populateData];
}

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark - Button Delegate Methods
//==================================================
- (IBAction)buttonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (debugPaymentPageVC) NSLog(@"PaymentPageVC buttonPressed: %d", button.tag);
    
    if (button.tag == 1) { // close
        [baseVC goToPrevPage];
    } else if (button.tag == 2) { // save
        if ( [self.appId isEqualToString:@""] ) {
            [baseVC showToastMessage:@"Select the invoice" ForSec:1];
            return;
        }
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"add-payment.php"] forKey:@"url"];
        [dic setObject:self.appId forKey:@"app_id"];
        [dic setObject:self.payId forKey:@"pay_id"];
        [dic setObject:self.customerId forKey:@"cust_id"];
        [dic setObject:self.dateText.text forKey:@"pay_date"];
        [dic setObject:self.invNumText.text forKey:@"inv_number"];
        [dic setObject:self.payTypeText.text forKey:@"pay_mode"];
        [dic setObject:self.payAmtText.text forKey:@"pay_amt"];
        [dic setObject:self.anyDetailsText.text forKey:@"details"];
        [dic setObject:self.custNameText.text forKey:@"cust_name"];
        [dic setObject:@"" forKey:@"cc_percent"];
        [dic setObject:@"" forKey:@"orig_amt"];
        [dic setObject:@"MAKE_PAYMENT" forKey:@"target"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:MAKE_PAYMENT];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 4  ||  textField.tag == 5)
        return NO;
    else
        return YES;
}

- (IBAction)textFieldPressed:(id)sender
{
    UITextField *text = (UITextField *)sender;
    if (debugPaymentPageVC) NSLog(@"PaymentPageVC textFieldPressed: %d", text.tag);
    
    if (text.tag == 4) { // date
        NSDate *today = [NSDate date];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a Date" datePickerMode:UIDatePickerModeDate selectedDate:today target:self action:@selector(dateWasSelected:sender:) origin:sender];
        [actionSheetPicker showActionSheetPicker];
    } else if (text.tag ==  5) { // payment type
        ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            if ([sender respondsToSelector:@selector(setText:)]) {
                [sender performSelector:@selector(setText:) withObject:selectedValue];
            }
        };
        
        ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
            if (debugInvoicesPageVC) NSLog(@"PaymentPageVC Picker Canceled");
        };
        NSArray *array = [[NSArray alloc] initWithObjects:@"CASH", @"CHEQUE", @"EFT", @"CREDIT CARD", nil];
        [ActionSheetStringPicker showPickerWithTitle:@"" rows:array initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 3) { // customer name
        NSString *text = textField.text;
        if (text.length >= 1  &&  text.length > self.invNumLength) {
            [self.view endEditing:YES]; // dismiss keyboard
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-invoices.php"] forKey:@"url"];
            [dic setObject:text forKey:@"query"];
            [dic setObject:@"MAKE_PAYMENT" forKey:@"target"];
            
            baseVC.model.postOpts = dic;
            [baseVC callServer:GET_INVOICE_LIST];
        }
        self.invNumLength = text.length;
    }
    return YES;
}

- (void)showInvoices
{
    if (debugPaymentPageVC) NSLog(@"PaymentPageVC showInvoices");
    
    NSMutableArray *invoices = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in baseVC.model.allData) {
        NSString *invoice = [NSString stringWithFormat:@"Invoice:%@ (%@) Due: %@", [dic valueForKey:@"inv_number"], [dic valueForKey:@"name"], [dic valueForKey:@"due"]];
        [invoices addObject:invoice];
    }
    
    if (invoices.count == 0) return;
    
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        NSDictionary *dic = [baseVC.model.allData objectAtIndex:selectedIndex];
        [self.invNumText performSelectorInBackground:@selector(setText:) withObject:[dic valueForKey:@"inv_number"]];
        [self.custNameText performSelector:@selector(setText:) withObject:[dic valueForKey:@"name"]];
        [self.invAmtText performSelector:@selector(setText:) withObject:[dic valueForKey:@"total"]];
        
        NSString *string = (NSString *)[dic valueForKey:@"inv_date"];
        NSArray *dateStrings = [string componentsSeparatedByString:@" "];
        [self.invDateText performSelector:@selector(setText:) withObject:dateStrings[0]];
        
        [self.payAmtText performSelector:@selector(setText:) withObject:[NSString stringWithFormat:@"%@", [dic valueForKey:@"due"]]];
        
        self.appId = [dic valueForKey:@"app_id"];
        self.customerId = [dic valueForKey:@"cust_id"];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        if (debugPaymentPageVC) NSLog(@"PaymentPageVC Picker Canceled");
    };
    [ActionSheetStringPicker showPickerWithTitle:@"Select a invoice" rows:invoices initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.invNumText];
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
// Custom Methods
// =================================================
#pragma mark - Custom Methods
//==================================================
- (void)initForm
{
    if (debugPaymentPageVC) NSLog(@"PaymentPageVC initForm");
    
    [self.saveBtn setHidden:NO];
    
    self.appId = @"";
    self.payId = @"0";
    self.customerId  = @"";
    self.invNumLength = 0;
    
    self.invNumText.text = @"";
    
    self.custNameText.text = @"";
    self.invAmtText.text = @"";
    self.invDateText.text = @"";
    
    self.dateText.text = [AppUtils getDateStringFromDate:[NSDate date]];
    self.payAmtText.text = @"";
    
    self.payTypeText.text = @"CREDIT CARD";
    self.anyDetailsText.text = @"";
}

- (void)populateData
{
    if (debugPaymentPageVC) NSLog(@"PaymentPageVC populateData");
    
    [self.saveBtn setHidden:YES];
    
    NSDictionary *data = baseVC.model.data;
    
    self.appId = [data valueForKey:@"app_id"];
    self.payId = [data valueForKey:@"pay_id"];
    self.invNumLength = [[data valueForKey:@"inv_number"] length];
    self.customerId = [data valueForKey:@"cust_id"];
    
    self.invNumText.text = [data valueForKey:@"inv_number"];
    
    self.custNameText.text = [data valueForKey:@"cust_name"];
    self.invAmtText.text = [data valueForKey:@"inv_total"];
    self.invDateText.text = [data valueForKey:@"inv_date"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *payDate = [dateFormatter dateFromString:[data valueForKey:@"pay_date"]];
    self.dateText.text = [AppUtils getDateStringFromDate:payDate];
    self.payAmtText.text = [data valueForKey:@"amount"];
    
    self.payTypeText.text = [data valueForKey:@"pay_mode"];
    self.anyDetailsText.text = [data valueForKey:@"details"];
}
@end
