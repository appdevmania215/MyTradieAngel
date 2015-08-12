//
//  InvoicePageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "InvoicePageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"

#import "AppUtils.h"

#import "ActionSheetPicker.h"

@interface InvoicePageVC ()
{
    BaseVC *baseVC;
    AbstractActionSheetPicker *actionSheetPicker;
}
@end

@implementation InvoicePageVC

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugInvoicePageVC) NSLog(@"InvoicePageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidAppear:(BOOL)animated
{
    if ( self.flag ) [self initForm];
    else [self populateData];
}

- (void)viewDidLayoutSubviews
{
    [self.scrollView setContentSize:CGSizeMake(320.f, 680.f)];
}

- (void)scrolViewScrollToTop
{
    CGPoint upOffest = CGPointMake(0.f, 0.f);
    [self.scrollView setContentOffset:upOffest animated:YES];
}

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark - Button Delegate Methods
//==================================================
- (IBAction)buttonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (debugInvoicePageVC) NSLog(@"InvoicePageVC buttonPressed: %d", button.tag);
    
    if (button.tag == 30) { // close
        [baseVC goToPrevPage];
    } else if (button.tag == 31) { // save
        if ([self.customerNameText.text length] == 0) {
            [baseVC showToastMessage:@"Enter the customer name" ForSec:1];
            return;
        }
        if ([self.addressText.text length] == 0) {
            [baseVC showToastMessage:@"Enter the address" ForSec:1];
            return;
        }
        if ([self.contactPhoneNoText.text length] == 0) {
            [baseVC showToastMessage:@"Enter the phone number" ForSec:1];
            return;
        }
        if ([self.emailIdText.text length] == 0) {
            [baseVC showToastMessage:@"Enter the email" ForSec:1];
            return;
        }
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"update-invoice.php"] forKey:@"url"];
        [dic setObject:self.appId forKey:@"id"];
        [dic setObject:[NSString stringWithFormat:@"%d", self.customerId] forKey:@"cust_id"];
        //[dic setObject:self.dateText.text forKey:@"dt"];
        [dic setObject:self.customerNameText.text forKey:@"name"];
        [dic setObject:self.emailIdText.text forKey:@"email"];
        [dic setObject:self.contactPhoneNoText.text forKey:@"phone"];
        [dic setObject:self.addressText.text forKey:@"add"];
        [dic setObject:self.invoiceIdText.text forKey:@"inv_number"];
        [dic setObject:self.dateText.text forKey:@"inv_date"];
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
        [dic setObject:[NSString stringWithFormat:@"%.02f", self.taxPercent] forKey:@"tax_percent"];
        [dic setObject:self.taxItem forKey:@"tax_label"];
        [dic setObject:self.netTotalText.text forKey:@"total"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:UPDATE_INVOICE];
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
    if (textField.tag == 32)
        return NO;
    else
        return YES;
}

- (IBAction)textFieldPressed:(id)sender
{
    UITextField *text = (UITextField *)sender;
    if (debugInvoicePageVC) NSLog(@"InvociePageVC textFieldPressed: %d", text.tag);
    
    if (text.tag == 32) { // date
        NSDate *today = [NSDate date];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a Date" datePickerMode:UIDatePickerModeDate selectedDate:today target:self action:@selector(dateWasSelected:sender:) origin:sender];
        [actionSheetPicker showActionSheetPicker];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 33) { // customer name
        NSString *text = textField.text;
        if (text.length >= 3  &&  text.length > self.custNameTextLength) {
            [self.view endEditing:YES]; // dismiss keyboard
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-customers-lookup.php"] forKey:@"url"];
            [dic setObject:text forKey:@"query"];
            [dic setObject:@"UPDATE_INVOICE" forKey:@"target"];
            
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
    if (text.tag >= 40  &&  text.tag < 50) {
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

- (void)showCustomers
{
    if (debugInvoicePageVC) NSLog(@"InvoicePageVC showCustomers");
    
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
        if (debugInvoicesPageVC) NSLog(@"InvociesPageVC Picker Canceled");
    };
    [ActionSheetStringPicker showPickerWithTitle:@"Select a type" rows:customers initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.customerNameText];
}

- (float)getTotalPrices
{
    UITextField *text;
    float totalPrice = 0.0f;
    for (int tag=40; tag<50; tag++) {
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

// =================================================
// Custom Methods
// =================================================
#pragma mark - Custom Methods
//==================================================
- (void)initForm
{
    if (debugInvoicePageVC) NSLog(@"InvoicePageVC initForm");
    
    NSMutableDictionary *dic = baseVC.model.postOpts;
    if ([dic objectForKey:@"target"] != [NSNull null]  &&  [[dic valueForKey:@"target"] isEqualToString:@"MAKE_INVOICE_FROM_CUSTOMERS"]) {
        self.custNameTextLength = [[dic objectForKey:@"name"] length];
        self.customerId = [[dic objectForKey:@"cust_id"] intValue];
        self.customerNameText.text = [dic objectForKey:@"name"];
        self.addressText.text = [dic objectForKey:@"address"];
        self.contactPhoneNoText.text = [dic objectForKey:@"phone"];
        self.emailIdText.text = [dic objectForKey:@"email"];
    } else {
        self.custNameTextLength = 0;
        self.customerId = 0;
        self.customerNameText.text = @"";
        self.addressText.text = @"";
        self.contactPhoneNoText.text = @"";
        self.emailIdText.text = @"";
    }
    self.appId = @"";
    
    self.invoiceIdText.text = baseVC.model.dataId;
    self.dateText.text = [AppUtils getDateStringFromDate:[NSDate date]];
    self.extraInfoText.text = @"";
    
    NSMutableDictionary *data = [baseVC.model.data copy];
    float defaultAmt = 0.0f;
    if ( ![[data objectForKey:@"app_default_amt"] isEqualToString:@""] )
        defaultAmt = [[data valueForKey:@"app_default_amt"] floatValue];
    self.item1Text.text = [data valueForKey:@"app_default_label"];
    self.price1Text.text = [NSString stringWithFormat:@"%.02f", defaultAmt];
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
    
    self.grossTotalText.text = [NSString stringWithFormat:@"%.02f", defaultAmt];
    self.taxItem = [data valueForKey:@"tax_label"];
    self.taxPercent = [[data valueForKey:@"tax_percent"] floatValue];
    self.taxLabel.text = [NSString stringWithFormat:@"Add %@ @ %@%%", [data valueForKey:@"tax_label"], [data valueForKey:@"tax_percent"]];
    float tax = defaultAmt * [[data objectForKey:@"tax_percent"] floatValue] / 100.0f;
    self.taxText.text = [NSString stringWithFormat:@"%.02f", tax];
    self.netTotalText.text = [NSString stringWithFormat:@"%.02f", (defaultAmt+tax)];
    
    [self scrolViewScrollToTop];
}

- (void)populateData
{
    if (debugInvoicePageVC) NSLog(@"InvoicePageVC populateData");
    NSDictionary *data = baseVC.model.data;
    self.appId = [data valueForKey:@"app_id"];
    self.custNameTextLength = [[data valueForKey:@"name"] length];
    self.customerId = [[data valueForKey:@"cust_id"] intValue];
    self.customerNameText.text = [data valueForKey:@"name"];
    self.addressText.text = [data valueForKey:@"address"];
    self.contactPhoneNoText.text = [data valueForKey:@"phone"];
    self.emailIdText.text = [data valueForKey:@"email"];
    
    self.invoiceIdText.text = [data valueForKey:@"inv_number"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *invDate = [dateFormatter dateFromString:[data valueForKey:@"inv_date"]];
    self.dateText.text = [AppUtils getDateStringFromDate:invDate];
    self.extraInfoText.text = [data valueForKey:@"inv_notes"];
    
    self.item1Text.text = [data valueForKey:@"item1"];
    self.price1Text.text = [[data valueForKey:@"price1"] floatValue] > 0 ? [data valueForKey:@"price1"] : @"";
    self.item2Text.text = [data valueForKey:@"item2"];
    self.price2Text.text = [[data valueForKey:@"price2"] floatValue] > 0 ? [data valueForKey:@"price2"] : @"";
    self.item3Text.text = [data valueForKey:@"item3"];
    self.price3Text.text = [[data valueForKey:@"price3"] floatValue] > 0 ? [data valueForKey:@"price3"] : @"";
    self.item4Text.text = [data valueForKey:@"item4"];
    self.price4Text.text = [[data valueForKey:@"price4"] floatValue] > 0 ? [data valueForKey:@"price4"] : @"";
    self.item5Text.text = [data valueForKey:@"item5"];
    self.price5Text.text = [[data valueForKey:@"price5"] floatValue] > 0 ? [data valueForKey:@"price5"] : @"";
    self.item6Text.text = [data valueForKey:@"item6"];
    self.price6Text.text = [[data valueForKey:@"price6"] floatValue] > 0 ? [data valueForKey:@"price6"] : @"";
    self.item7Text.text = [data valueForKey:@"item7"];
    self.price7Text.text = [[data valueForKey:@"price7"] floatValue] > 0 ? [data valueForKey:@"price7"] : @"";
    self.item8Text.text = [data valueForKey:@"item8"];
    self.price8Text.text = [[data valueForKey:@"price8"] floatValue] > 0 ? [data valueForKey:@"price8"] : @"";
    self.item9Text.text = [data valueForKey:@"item9"];
    self.price9Text.text = [[data valueForKey:@"price9"] floatValue] > 0 ? [data valueForKey:@"price9"] : @"";
    self.item10Text.text = [data valueForKey:@"item10"];
    self.price10Text.text = [[data valueForKey:@"price10"] floatValue] > 0 ? [data valueForKey:@"price10"] : @"";
    
    self.grossTotalText.text = [data valueForKey:@"gtotal"];
    self.taxItem = [data valueForKey:@"tax_label"];
    self.taxPercent = [[data valueForKey:@"tax_percent"] floatValue];
    self.taxLabel.text = [NSString stringWithFormat:@"Add %@ @ %@%%", [data valueForKey:@"tax_label"], [data valueForKey:@"tax_percent"]];
    float gtotal = [[data objectForKey:@"gtotal"] floatValue];
    float tax = gtotal * [[data objectForKey:@"tax_percent"] floatValue] / 100.0f;
    self.taxText.text = [NSString stringWithFormat:@"%.02f", tax];
    self.netTotalText.text = [data valueForKey:@"total"];
    
    [self scrolViewScrollToTop];
}

@end
