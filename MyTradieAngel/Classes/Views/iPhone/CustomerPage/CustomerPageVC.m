//
//  CustomerPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "CustomerPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"
#import "AppUtils.h"

@interface CustomerPageVC ()
{
    BaseVC *baseVC;
}
@end

@implementation CustomerPageVC

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

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark - Button Delegate Methods
//==================================================
- (IBAction)buttonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (debugCustomerPageVC) NSLog(@"CustomerPageVC buttonPressed: %d", button.tag);
    
    if (button.tag == 1) { // close
        [baseVC goToPrevPage];
    } else if (button.tag == 2) { // save
        if ([self.custNameText.text length] == 0) {
            [baseVC showToastMessage:@"Enter the customer name" ForSec:1];
            return;
        }
        /*
         if ([self.custAddrText.text length] == 0) {
         [baseVC showToastMessage:@"Enter the address" ForSec:1];
         return;
         }
         if ([self.custPhoneText.text length] == 0) {
         [baseVC showToastMessage:@"Enter the phone number" ForSec:1];
         return;
         } */
        if ([self.custEmailText.text length] == 0) {
            [baseVC showToastMessage:@"Enter the email" ForSec:1];
            return;
        }
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"update-customer.php"] forKey:@"url"];
        [dic setObject:[NSString stringWithFormat:@"%d", self.customerId] forKey:@"id"];
        [dic setObject:self.custNameText.text forKey:@"name"];
        [dic setObject:self.custEmailText.text forKey:@"email"];
        [dic setObject:self.custPhoneText.text forKey:@"phone"];
        [dic setObject:self.custAddrText.text forKey:@"address"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:UPDATE_CUSTOMER];
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

// =================================================
// Custom Methods
// =================================================
#pragma mark - Custom Methods
//==================================================
- (void)initForm
{
    if (debugCustomerPageVC) NSLog(@"CustomerPageVC initForm");
    
    self.customerId = 0;
    self.custNameText.text = @"";
    self.custAddrText.text = @"";
    self.custPhoneText.text = @"";
    self.custEmailText.text = @"";
}

- (void)populateData
{
    if (debugCustomerPageVC) NSLog(@"CustomerPageVC populateData");
    
    NSDictionary *data = baseVC.model.data;
    self.customerId = [[data valueForKey:@"cust_id"] intValue];
    self.custNameText.text = [data valueForKey:@"name"];
    self.custAddrText.text = [data valueForKey:@"address"];
    self.custPhoneText.text = [data valueForKey:@"phone"];
    self.custEmailText.text = [data valueForKey:@"email"];
}
@end
