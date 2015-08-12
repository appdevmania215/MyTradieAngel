//
//  QuotePageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "QuotePageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"

#import "AppUtils.h"

#import "ActionSheetPicker.h"

@interface QuotePageVC ()
{
    BaseVC *baseVC;
    AbstractActionSheetPicker *actionSheetPicker;
}
@end

@implementation QuotePageVC

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
    if (debugQuotePageVC) NSLog(@"QuotePageVC initWithView");
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
    if (debugQuotePageVC) NSLog(@"QuotePageVC buttonPressed: %d", button.tag);
    
    if (button.tag == 1) { // close
        [baseVC goToPrevPage];
    } else if (button.tag == 2) { // save
        if (self.customerId == 0) {
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
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"update-quotation.php"] forKey:@"url"];
        [dic setObject:self.appId forKey:@"id"];
        [dic setObject:[NSString stringWithFormat:@"%d", self.customerId] forKey:@"cust_id"];
        //[dic setObject:self.dateText.text forKey:@"dt"];
        [dic setObject:self.customerNameText.text forKey:@"name"];
        [dic setObject:self.emailIdText.text forKey:@"email"];
        [dic setObject:self.contactPhoneNoText.text forKey:@"phone"];
        [dic setObject:self.addressText.text forKey:@"add"];
        [dic setObject:self.quoteIdText.text forKey:@"quot_number"];
        [dic setObject:self.dateText.text forKey:@"q_date"];
        [dic setObject:self.item1Text.text forKey:@"qi1"];
        [dic setObject:self.price1Text.text forKey:@"qp1"];
        [dic setObject:self.item2Text.text forKey:@"qi2"];
        [dic setObject:self.price2Text.text forKey:@"qp2"];
        [dic setObject:self.item3Text.text forKey:@"qi3"];
        [dic setObject:self.price3Text.text forKey:@"qp3"];
        [dic setObject:self.item4Text.text forKey:@"qi4"];
        [dic setObject:self.price4Text.text forKey:@"qp4"];
        [dic setObject:self.item5Text.text forKey:@"qi5"];
        [dic setObject:self.price5Text.text forKey:@"qp5"];
        [dic setObject:self.item6Text.text forKey:@"qi6"];
        [dic setObject:self.price6Text.text forKey:@"qp6"];
        [dic setObject:self.item7Text.text forKey:@"qi7"];
        [dic setObject:self.price7Text.text forKey:@"qp7"];
        [dic setObject:self.item8Text.text forKey:@"qi8"];
        [dic setObject:self.price8Text.text forKey:@"qp8"];
        [dic setObject:self.item9Text.text forKey:@"qi9"];
        [dic setObject:self.price9Text.text forKey:@"qp9"];
        [dic setObject:self.item10Text.text forKey:@"qi10"];
        [dic setObject:self.price10Text.text forKey:@"qp10"];
        [dic setObject:self.grossTotalText.text forKey:@"qgtotal"];
        [dic setObject:[NSString stringWithFormat:@"%.02f", self.taxPercent] forKey:@"tax_percent"];
        [dic setObject:self.taxItem forKey:@"tax_label"];
        [dic setObject:self.netTotalText.text forKey:@"qtotal"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:UPDATE_QUOTE];
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
    if (textField.tag == 4)
        return NO;
    else
        return YES;
}

- (IBAction)textFieldPressed:(id)sender
{
    UITextField *text = (UITextField *)sender;
    if (debugQuotePageVC) NSLog(@"QuotePageVC textFieldPressed: %d", text.tag);
    
    if (text.tag == 4) { // date
        NSDate *today = [NSDate date];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a Date" datePickerMode:UIDatePickerModeDate selectedDate:today target:self action:@selector(dateWasSelected:sender:) origin:sender];
        [actionSheetPicker showActionSheetPicker];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 3) { // customer name
        NSString *text = textField.text;
        if (text.length >= 3  &&  text.length > self.custNameTextLength) {
            [self.view endEditing:YES]; // dismiss keyboard
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-customers-lookup.php"] forKey:@"url"];
            [dic setObject:text forKey:@"query"];
            [dic setObject:@"UPDATE_QUOTE" forKey:@"target"];
            
            baseVC.model.postOpts = dic;
            [baseVC callServer:GET_CUSTOMERS_LOOKUP];
        }
        self.custNameTextLength = text.length;
    }
    return YES;
}

- (IBAction)priceTextChanged:(id)sender {
    UITextField *text = (UITextField *)sender;
    if (debugQuotePageVC) NSLog(@"QuotePageVC priceTextChanged: %d", text.tag);
    if (text.tag >= 11  &&  text.tag <= 20) {
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
    if (debugQuotePageVC) NSLog(@"QuotePageVC showCustomers");
    
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
        if (debugQuotesPageVC) NSLog(@"InvociesPageVC Picker Canceled");
    };
    [ActionSheetStringPicker showPickerWithTitle:@"Select a type" rows:customers initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.customerNameText];
}

- (float)getTotalPrices
{
    UITextField *text;
    float totalPrice = 0.0f;
    for (int tag=11; tag<=20; tag++) {
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
    if (debugQuotePageVC) NSLog(@"QuotePageVC initForm");
    self.appId = @"";
    self.custNameTextLength = 0;
    self.customerId = 0;
    self.customerNameText.text = @"";
    self.addressText.text = @"";
    self.contactPhoneNoText.text = @"";
    self.emailIdText.text = @"";
    
    self.quoteIdText.text = baseVC.model.dataId;
    self.dateText.text = [AppUtils getDateStringFromDate:[NSDate date]];
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
    
    NSMutableDictionary *data = [baseVC.model.data copy];
    
    self.grossTotalText.text = @"0.00";
    self.taxItem = [data valueForKey:@"tax_label"];
    self.taxPercent = [[data valueForKey:@"tax_percent"] floatValue];
    self.taxLabel.text = [NSString stringWithFormat:@"Add %@ @ %@%%", [data valueForKey:@"tax_label"], [data valueForKey:@"tax_percent"]];
    self.taxText.text = @"0.00";
    self.netTotalText.text = @"0.00";
    
    [self scrolViewScrollToTop];
}

- (void)populateData
{
    if (debugQuotePageVC) NSLog(@"QuotePageVC populateData");
    NSDictionary *data = baseVC.model.data;
    self.appId = [data valueForKey:@"app_id"];
    self.custNameTextLength = [[data valueForKey:@"name"] length];
    self.customerId = [[data valueForKey:@"cust_id"] intValue];
    self.customerNameText.text = [data valueForKey:@"name"];
    self.addressText.text = [data valueForKey:@"address"];
    self.contactPhoneNoText.text = [data valueForKey:@"phone"];
    self.emailIdText.text = [data valueForKey:@"email"];
    
    self.quoteIdText.text = [data valueForKey:@"quot_number"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *invDate = [dateFormatter dateFromString:[data valueForKey:@"q_date"]];
    self.dateText.text = [AppUtils getDateStringFromDate:invDate];
    self.extraInfoText.text = [data valueForKey:@"inv_notes"];
    
    self.item1Text.text = [data valueForKey:@"qitem1"];
    self.price1Text.text = [[data valueForKey:@"qprice1"] floatValue] > 0 ? [data valueForKey:@"qprice1"] : @"";
    self.item2Text.text = [data valueForKey:@"qitem2"];
    self.price2Text.text = [[data valueForKey:@"qprice2"] floatValue] > 0 ? [data valueForKey:@"qprice2"] : @"";
    self.item3Text.text = [data valueForKey:@"qitem3"];
    self.price3Text.text = [[data valueForKey:@"qprice3"] floatValue] > 0 ? [data valueForKey:@"qprice3"] : @"";
    self.item4Text.text = [data valueForKey:@"qitem4"];
    self.price4Text.text = [[data valueForKey:@"qprice4"] floatValue] > 0 ? [data valueForKey:@"qprice4"] : @"";
    self.item5Text.text = [data valueForKey:@"qitem5"];
    self.price5Text.text = [[data valueForKey:@"qprice5"] floatValue] > 0 ? [data valueForKey:@"qprice5"] : @"";
    self.item6Text.text = [data valueForKey:@"qitem6"];
    self.price6Text.text = [[data valueForKey:@"qprice6"] floatValue] > 0 ? [data valueForKey:@"qprice6"] : @"";
    self.item7Text.text = [data valueForKey:@"qitem7"];
    self.price7Text.text = [[data valueForKey:@"qprice7"] floatValue] > 0 ? [data valueForKey:@"qprice7"] : @"";
    self.item8Text.text = [data valueForKey:@"qitem8"];
    self.price8Text.text = [[data valueForKey:@"qprice8"] floatValue] > 0 ? [data valueForKey:@"qprice8"] : @"";
    self.item9Text.text = [data valueForKey:@"qitem9"];
    self.price9Text.text = [[data valueForKey:@"qprice9"] floatValue] > 0 ? [data valueForKey:@"qprice9"] : @"";
    self.item10Text.text = [data valueForKey:@"qitem10"];
    self.price10Text.text = [[data valueForKey:@"qprice10"] floatValue] > 0 ? [data valueForKey:@"qprice10"] : @"";
    
    self.grossTotalText.text = [data valueForKey:@"qgtotal"];
    self.taxItem = [data valueForKey:@"tax_label"];
    self.taxPercent = [[data valueForKey:@"tax_percent"] floatValue];
    self.taxLabel.text = [NSString stringWithFormat:@"Add %@ @ %@%%", [data valueForKey:@"tax_label"], [data valueForKey:@"tax_percent"]];
    float qgtotal = [[data objectForKey:@"qgtotal"] floatValue];
    float tax = qgtotal * [[data objectForKey:@"tax_percent"] floatValue] / 100.0f;
    self.taxText.text = [NSString stringWithFormat:@"%.02f", tax];
    self.netTotalText.text = [data valueForKey:@"qtotal"];
    
    [self scrolViewScrollToTop];
}
@end
