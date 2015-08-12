//
//  SignupPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/26/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "SignupPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"

@interface SignupPageVC ()
{
    BaseVC *baseVC;
}
@end

@implementation SignupPageVC

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
    NSString *fontName = @"Optima-Italic";
    NSString *boldFontName = @"Optima-ExtraBlack";
    
    self.titleLabel.font = [UIFont fontWithName:boldFontName size:24.0f];
    self.subTitleLabel.font = [UIFont fontWithName:fontName size:14.0f];
    
    UIColor* darkColor = [UIColor colorWithRed:10.0/255 green:78.0/255 blue:108.0/255 alpha:1.0f];
    
    self.businessNameText.backgroundColor = [UIColor whiteColor];
    self.businessNameText.layer.cornerRadius = 3.0f;
    self.businessNameText.leftViewMode = UITextFieldViewModeAlways;
    UIView *leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.businessNameText.leftView = leftView1;
    self.businessNameText.font = [UIFont fontWithName:fontName size:16.0f];
    
    self.adminNameText.backgroundColor = [UIColor whiteColor];
    self.adminNameText.layer.cornerRadius = 3.0f;
    self.adminNameText.leftViewMode = UITextFieldViewModeAlways;
    UIView *leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.adminNameText.leftView = leftView2;
    self.adminNameText.font = [UIFont fontWithName:fontName size:16.0f];
    
    self.userIdText.backgroundColor = [UIColor whiteColor];
    self.userIdText.layer.cornerRadius = 3.0f;
    self.userIdText.leftViewMode = UITextFieldViewModeAlways;
    UIView *leftView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.userIdText.leftView = leftView3;
    self.userIdText.font = [UIFont fontWithName:fontName size:16.0f];
    
    self.pwdText.backgroundColor = [UIColor whiteColor];
    self.pwdText.layer.cornerRadius = 3.0f;
    self.pwdText.leftViewMode = UITextFieldViewModeAlways;
    UIView *leftView4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.pwdText.leftView = leftView4;
    self.pwdText.font = [UIFont fontWithName:fontName size:16.0f];
    
    self.pwdConfirmText.backgroundColor = [UIColor whiteColor];
    self.pwdConfirmText.layer.cornerRadius = 3.0f;
    self.pwdConfirmText.leftViewMode = UITextFieldViewModeAlways;
    UIView *leftView5 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.pwdConfirmText.leftView = leftView5;
    self.pwdConfirmText.font = [UIFont fontWithName:fontName size:16.0f];
    
    self.emailText.backgroundColor = [UIColor whiteColor];
    self.emailText.layer.cornerRadius = 3.0f;
    self.emailText.leftViewMode = UITextFieldViewModeAlways;
    UIView *leftView6 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.emailText.leftView = leftView6;
    self.emailText.font = [UIFont fontWithName:fontName size:16.0f];
    
    self.saveBtn.backgroundColor = darkColor;
    self.saveBtn.layer.cornerRadius = 3.0f;
    self.saveBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:20.0f];
    [self.saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    
    self.cancelBtn.backgroundColor = darkColor;
    self.cancelBtn.layer.cornerRadius = 3.0f;
    self.cancelBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:20.0f];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugSignupPageVC) NSLog(@"SignupPageVC initWithView");
    baseVC = rootVC;
}

//==================================================
// TextField Delegate Methods
//==================================================
#pragma mark- Button Delegate Methods
//==================================================
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//==================================================
// Button Delegate Methods
//==================================================
#pragma mark- Button Delegate Methods
//==================================================
- (IBAction)saveBtnPressed:(id)sender
{
    if (debugSignupPageVC) NSLog(@"SignupPageVC saveBtnPressed");
    
    NSString *businessName = self.businessNameText.text;
    businessName = [businessName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([businessName length] == 0) {
        [baseVC showToastMessage:@"Enter the Business Name" ForSec:1];
        return;
    }
    NSString *adminName = self.adminNameText.text;
    adminName = [adminName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([adminName length] == 0) {
        [baseVC showToastMessage:@"Enter the Admin Name" ForSec:1];
        return;
    }
    NSString *userId = self.userIdText.text;
    userId = [userId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([userId length] == 0) {
        [baseVC showToastMessage:@"Enter the user id" ForSec:1];
        return;
    }
    NSString *pwd = self.pwdText.text;
    pwd = [pwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([pwd length] == 0) {
        [baseVC showToastMessage:@"Enter the login password" ForSec:1];
        return;
    }
    NSString *pwdConfirm = self.pwdConfirmText.text;
    pwdConfirm = [pwdConfirm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([pwdConfirm length] == 0) {
        [baseVC showToastMessage:@"Enter the Confirm password" ForSec:1];
        return;
    }
    NSString *email = self.emailText.text;
    email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([email length] == 0) {
        [baseVC showToastMessage:@"Enter the Your Email" ForSec:1];
        return;
    }
    
    if ( ![pwd isEqualToString:pwdConfirm] ) {
        [baseVC showToastMessage:@"Password isn't same as Confirm password" ForSec:1];
        return;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"register.php"] forKey:@"url"];
    [dic setObject:businessName forKey:@"business_name"];
    [dic setObject:adminName forKey:@"admin_name"];
    [dic setObject:userId forKey:@"userid"];
    [dic setObject:pwd forKey:@"pwd"];
    [dic setObject:email forKey:@"email"];
    
    baseVC.model.postOpts = dic;
    [baseVC callServer:SIGNUP];
}

- (IBAction)cancelBtnPressed:(id)sender
{
    if (debugSignupPageVC) NSLog(@"SignupPageVC saveBtnPressed");
    [baseVC goToLoginPage];
}

//==================================================
// Custom Methods
//==================================================
#pragma mark- Custom Methods
//==================================================
- (void)initSignupForm
{
    if (debugSignupPageVC) NSLog(@"SignupPageVC initSignupForm");
    self.businessNameText.text = @"";
    self.adminNameText.text = @"";
    self.userIdText.text = @"";
    self.pwdText.text = @"";
    self.pwdConfirmText.text = @"";
    self.emailText.text = @"";
}
@end
