//
//  SignupPageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/26/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface SignupPageVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *businessNameText;
@property (weak, nonatomic) IBOutlet UITextField *adminNameText;
@property (weak, nonatomic) IBOutlet UITextField *userIdText;
@property (weak, nonatomic) IBOutlet UITextField *pwdText;
@property (weak, nonatomic) IBOutlet UITextField *pwdConfirmText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

- (void)initWithView:(BaseVC *)rootVC;
- (void)initSignupForm;
@end