//
//  SettingsMenuVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "SettingsMenuVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"

#import "HomePageVC.h"

@interface SettingsMenuVC ()
{
    BaseVC *baseVC;
}
@end

@implementation SettingsMenuVC

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
    NSString *boldFontName = @"Optima-ExtraBlack";
    UIColor* darkColor = [UIColor colorWithRed:10.0/255 green:78.0/255 blue:108.0/255 alpha:1.0f];
    
    [baseVC makeButtonUI:self.companyInfoBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.setupHeadsBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.syncBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.refreshBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.changePswdBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.logoutBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugHomePageVC) NSLog(@"SettingsMenuVC initWithView");
    baseVC = rootVC;
}

//==================================================
// Button Delegate Methods
//==================================================
#pragma mark- Button Delegate Methods
//==================================================
- (IBAction)companyInfoBtnPressed:(id)sender {
    if (debugSettingsMenuVC) NSLog(@"SettingsMenuVC companyInfoBtnPressed");
    [baseVC.homePageVC dismissPopoverController];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-settings.php"] forKey:@"url"];
    [dic setObject:@"GET_COMPANYINFO" forKey:@"target"];
    baseVC.model.postOpts = dic;
    [baseVC callServer:GET_USER_SETTINGS];
}

- (IBAction)setupHeadsBtnPressed:(id)sender {
    if (debugSettingsMenuVC) NSLog(@"SettingsMenuVC setupHeadsBtnPressed");
    [baseVC.homePageVC dismissPopoverController];
    [baseVC goToHeadsPage];
}

- (IBAction)syncBtnPressed:(id)sender {
    if (debugSettingsMenuVC) NSLog(@"SettingsMenuVC syncBtnPressed");
    [baseVC.homePageVC dismissPopoverController];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"update-db.php"] forKey:@"url"];
    baseVC.model.postOpts = dic;
    [baseVC callServer:SYNC_DATA];
}

- (IBAction)refreshBtnPressed:(id)sender {
    if (debugSettingsMenuVC) NSLog(@"SettingsMenuVC refreshBtnPressed");
    [baseVC.homePageVC dismissPopoverController];
    
    UIAlertView *confirmDlg = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure to refresh app data?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [confirmDlg show];
}

- (IBAction)changePswdBtnPressed:(id)sender {
    if (debugSettingsMenuVC) NSLog(@"SettingsMenuVC changePswdBtnPressed");
    [baseVC.homePageVC dismissPopoverController];
    [baseVC goToChangePswdPage];
}

- (IBAction)logoutBtnPressed:(id)sender {
    if (debugSettingsMenuVC) NSLog(@"SettingsMenuVC logoutBtnPressed");
    [baseVC.homePageVC dismissPopoverController];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"logout.php"] forKey:@"url"];
    
    baseVC.model.postOpts = dic;
    [baseVC callServer:LOGOUT];
}

// =================================================
// AlertView Delegate Methods
// =================================================
#pragma mark- AlertView Delegate Methods
//==================================================
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"refresh-db.php"] forKey:@"url"];
        baseVC.model.postOpts = dic;
        [baseVC callServer:REFRESH_DATA];
    }
}
@end
