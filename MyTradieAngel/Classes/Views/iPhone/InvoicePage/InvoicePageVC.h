//
//  InvoicePageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface InvoicePageVC : UIViewController

@property(nonatomic, assign) BOOL flag;
@property(nonatomic, retain) NSString *appId;
@property(nonatomic, assign) int custNameTextLength;
@property(nonatomic, assign) int customerId;
@property(nonatomic, retain) NSString *taxItem;
@property(nonatomic, assign) float taxPercent;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *customerNameText;
@property (weak, nonatomic) IBOutlet UITextField *addressText;
@property (weak, nonatomic) IBOutlet UITextField *contactPhoneNoText;
@property (weak, nonatomic) IBOutlet UITextField *emailIdText;

@property (weak, nonatomic) IBOutlet UITextField *invoiceIdText;
@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (weak, nonatomic) IBOutlet UITextField *extraInfoText;

@property (weak, nonatomic) IBOutlet UITextField *item1Text;
@property (weak, nonatomic) IBOutlet UITextField *price1Text;
@property (weak, nonatomic) IBOutlet UITextField *item2Text;
@property (weak, nonatomic) IBOutlet UITextField *price2Text;
@property (weak, nonatomic) IBOutlet UITextField *item3Text;
@property (weak, nonatomic) IBOutlet UITextField *price3Text;
@property (weak, nonatomic) IBOutlet UITextField *item4Text;
@property (weak, nonatomic) IBOutlet UITextField *price4Text;
@property (weak, nonatomic) IBOutlet UITextField *item5Text;
@property (weak, nonatomic) IBOutlet UITextField *price5Text;
@property (weak, nonatomic) IBOutlet UITextField *item6Text;
@property (weak, nonatomic) IBOutlet UITextField *price6Text;
@property (weak, nonatomic) IBOutlet UITextField *item7Text;
@property (weak, nonatomic) IBOutlet UITextField *price7Text;
@property (weak, nonatomic) IBOutlet UITextField *item8Text;
@property (weak, nonatomic) IBOutlet UITextField *price8Text;
@property (weak, nonatomic) IBOutlet UITextField *item9Text;
@property (weak, nonatomic) IBOutlet UITextField *price9Text;
@property (weak, nonatomic) IBOutlet UITextField *item10Text;
@property (weak, nonatomic) IBOutlet UITextField *price10Text;

@property (weak, nonatomic) IBOutlet UITextField *grossTotalText;
@property (weak, nonatomic) IBOutlet UILabel *taxLabel;
@property (weak, nonatomic) IBOutlet UITextField *taxText;
@property (weak, nonatomic) IBOutlet UITextField *netTotalText;

- (void)initWithView:(BaseVC *)rootVC;
- (void)scrolViewScrollToTop;
- (void)initForm;
- (void)populateData;
- (void)showCustomers;
@end
