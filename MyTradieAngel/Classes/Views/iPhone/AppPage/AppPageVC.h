//
//  AppPageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface AppPageVC : UIViewController

@property(nonatomic, assign) int selectedYear;
@property(nonatomic, assign) int selectedMonth;

@property(nonatomic, assign) BOOL flag;
@property(nonatomic, assign) BOOL fromPdfVC;
@property(nonatomic, assign) NSString *appId;
@property(nonatomic, assign) int custNameTextLength;
@property(nonatomic, assign) int customerId;
@property(nonatomic, retain) NSString *taxItem;
@property(nonatomic, assign) float taxPercent;

@property (weak, nonatomic) IBOutlet UIButton *tabBtn;
@property (weak, nonatomic) IBOutlet UIButton *delBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (weak, nonatomic) IBOutlet UIView *appView;
@property (weak, nonatomic) IBOutlet UIScrollView *appScrollView;

@property (weak, nonatomic) IBOutlet UITextField *fromTimeText;
@property (weak, nonatomic) IBOutlet UITextField *toTimeText;

@property (weak, nonatomic) IBOutlet UITextField *customerNameText;
@property (weak, nonatomic) IBOutlet UITextField *addressText;
@property (weak, nonatomic) IBOutlet UITextField *contactPhoneNoText;
@property (weak, nonatomic) IBOutlet UITextField *emailIdText;

@property (weak, nonatomic) IBOutlet UITextView *noteText;

@property (weak, nonatomic) IBOutlet UIView *repeatOptionView;
@property (weak, nonatomic) IBOutlet UITextField *repeatOptText;


@property (weak, nonatomic) IBOutlet UIView *invView;
@property (weak, nonatomic) IBOutlet UIScrollView *invScrollView;

@property (weak, nonatomic) IBOutlet UIButton *compBtn;
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
