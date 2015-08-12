//
//  CompanyInfoPageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

#import "GCPlaceholderTextView.h"

@interface CompanyInfoPageVC : UIViewController

@property (nonatomic, assign) BOOL flag;
@property (nonatomic, retain) UIImage *logoImage;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *busiNameText;

@property (weak, nonatomic) IBOutlet UIButton *selFileBtn;
@property (weak, nonatomic) IBOutlet UIButton *delLogoBtn;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UITextField *addrText;
@property (weak, nonatomic) IBOutlet UITextField *subCityText;
@property (weak, nonatomic) IBOutlet UITextField *pCodeText;

@property (weak, nonatomic) IBOutlet UITextField *abnText;
@property (weak, nonatomic) IBOutlet UITextField *bankText;

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *invMailContentText;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *invText;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *quoteMailContentText;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *quoteText;

@property (weak, nonatomic) IBOutlet UITextField *dateFormatText;

@property (weak, nonatomic) IBOutlet UITextField *appDescText;
@property (weak, nonatomic) IBOutlet UITextField *appAmountText;
@property (weak, nonatomic) IBOutlet UITextField *taxDescText;
@property (weak, nonatomic) IBOutlet UITextField *taxPercentText;
@property (weak, nonatomic) IBOutlet UITextField *ccChargesText;

@property (weak, nonatomic) IBOutlet UITextField *smsCustText;
@property (weak, nonatomic) IBOutlet UILabel *sendSmsLabel;
@property (weak, nonatomic) IBOutlet UITextField *sendSmsText;
@property (weak, nonatomic) IBOutlet UITextField *smsConfMailText;


- (void)initWithView:(BaseVC *)rootVC;

@end
