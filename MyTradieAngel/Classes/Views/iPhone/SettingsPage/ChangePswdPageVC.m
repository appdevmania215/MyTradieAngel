//
//  ChangePswdPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "ChangePswdPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"

@interface ChangePswdPageVC ()
{
    BaseVC *baseVC;
}
@end

@implementation ChangePswdPageVC

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
    if (debugBCostPageVC) NSLog(@"BCostPageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.panelView.center = self.view.center;
    self.curPswdText.text = @"";
    self.pswdText.text = @"";
    self.confPswdText.text = @"";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark - Button Delegate Methods
//==================================================
- (IBAction)headerBtnPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (debugChagnePswdPageVC) NSLog(@"ChagnePswdPageVC buttonPressed: %d", button.tag);
    if (button.tag == 10) {
        [baseVC goToPrevPage];
    } else if (button.tag == 11) {
        NSString *curPswd = self.curPswdText.text;
        if ([curPswd length] == 0) {
            [baseVC showToastMessage:@"Enter the current password" ForSec:1];
            return;
        }
        NSString *newPswd = self.pswdText.text;
        if ([newPswd length] == 0) {
            [baseVC showToastMessage:@"Enter the new password" ForSec:1];
            return;
        }
        NSString *confPswd = self.confPswdText.text;
        if ([confPswd length] == 0) {
            [baseVC showToastMessage:@"Enter the confirm password" ForSec:1];
            return;
        }
        
        if ( ![newPswd isEqualToString:confPswd] ) {
            [baseVC showToastMessage:@"New and confirm passwords dont' match" ForSec:1];
            return;
        }
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"change-pwd.php"] forKey:@"url"];
        [dic setObject:curPswd forKey:@"curr"];
        [dic setObject:newPswd forKey:@"new"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:CHANGE_PSWD];
    }
}
@end
