//
//  PaymentPageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface PaymentPageVC : UIViewController

@property(nonatomic, assign) BOOL flag;
@property(nonatomic, retain) NSString *appId;
@property(nonatomic, retain) NSString *payId;
@property(nonatomic, retain) NSString *customerId;
@property(nonatomic, assign) int invNumLength;
@property(nonatomic, retain) NSString *origAmt;

@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *invNumText;
@property (weak, nonatomic) IBOutlet UITextField *custNameText;
@property (weak, nonatomic) IBOutlet UITextField *invAmtText;
@property (weak, nonatomic) IBOutlet UITextField *invDateText;

@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (weak, nonatomic) IBOutlet UITextField *payAmtText;

@property (weak, nonatomic) IBOutlet UIView *payTypeView;
@property (weak, nonatomic) IBOutlet UITextField *payTypeText;
@property (weak, nonatomic) IBOutlet UITextField *anyDetailsText;

- (void)initWithView:(BaseVC *)rootVC;
- (void)initForm;
- (void)showInvoices;
@end
