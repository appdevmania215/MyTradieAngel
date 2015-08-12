//
//  LoginPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/26/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "LoginPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"
#import "AppUtils.h"

@interface LoginPageVC ()
{
    BaseVC *baseVC;
}
@end

@implementation LoginPageVC

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
    
    self.userIdText.backgroundColor = [UIColor whiteColor];
    self.userIdText.layer.cornerRadius = 3.0f;
    self.userIdText.leftViewMode = UITextFieldViewModeAlways;
    UIView *leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.userIdText.leftView = leftView1;
    self.userIdText.font = [UIFont fontWithName:fontName size:16.0f];
    
    self.pwdText.backgroundColor = [UIColor whiteColor];
    self.pwdText.layer.cornerRadius = 3.0f;
    self.pwdText.leftViewMode = UITextFieldViewModeAlways;
    UIView *leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.pwdText.leftView = leftView2;
    self.pwdText.font = [UIFont fontWithName:fontName size:16.0f];
    
    self.loginBtn.backgroundColor = darkColor;
    self.loginBtn.layer.cornerRadius = 3.0f;
    self.loginBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:20.0f];
    [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginBtn setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    
    self.forgotBtn.backgroundColor = [UIColor clearColor];
    self.forgotBtn.titleLabel.font = [UIFont fontWithName:fontName size:12.0f];
    [self.forgotBtn setTitleColor:darkColor forState:UIControlStateNormal];
    [self.forgotBtn setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateHighlighted];
    
    self.signupBtn.backgroundColor = darkColor;
    self.signupBtn.layer.cornerRadius = 3.0f;
    self.signupBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:20.0f];
    [self.signupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signupBtn setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugLoginPageVC) NSLog(@"LoginPageVC initWithView");
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
- (IBAction)loginBtnPressed:(id)sender {
    if (debugLoginPageVC) NSLog(@"LoginPageVC loginBtnPressed");
    
    NSString *userId = self.userIdText.text;
    userId = [userId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    userId = @"root"; // for test
    if ([userId length] == 0) {
        [baseVC showToastMessage:@"Enter the User Id" ForSec:1];
        return;
    }
    NSString *pwd = self.pwdText.text;
    pwd = [pwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    pwd = @"master"; // for test
    if ([pwd length] == 0) {
        [baseVC showToastMessage:@"Enter the password" ForSec:1];
        return;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"login.php"] forKey:@"url"];
    [dic setObject:userId forKey:@"userid"];
    [dic setObject:pwd forKey:@"pwd"];
    
    baseVC.model.postOpts = dic;
    [baseVC callServer:LOGIN];
}
- (IBAction)pswdBtnPressed:(id)sender {
    if (debugLoginPageVC) NSLog(@"LoginPageVC pswdBtnPressed");
}
- (IBAction)registerBtnPressed:(id)sender {
    if (debugLoginPageVC) NSLog(@"LoginPageVC registerBtnPressed");
    [baseVC goToSignupPage];
}
@end
