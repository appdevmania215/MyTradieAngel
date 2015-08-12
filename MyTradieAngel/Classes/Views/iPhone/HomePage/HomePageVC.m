//
//  HomePageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "HomePageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"

#import "WYPopoverController.h"

#import "SettingsMenuVC.h"

@interface HomePageVC ()<WYPopoverControllerDelegate>
{
    BaseVC *baseVC;
    WYPopoverController *popoverController;
}
@end

@implementation HomePageVC

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
    
    [baseVC makeButtonUI:self.appointmentsBtn FontName:boldFontName FontSize:20.f BackColor:darkColor];
    [baseVC makeButtonUI:self.quotationsBtn FontName:boldFontName FontSize:20.f BackColor:darkColor];
    [baseVC makeButtonUI:self.invoicesBtn FontName:boldFontName FontSize:20.f BackColor:darkColor];
    [baseVC makeButtonUI:self.customersBtn FontName:boldFontName FontSize:20.f BackColor:darkColor];
    [baseVC makeButtonUI:self.paymentsBtn FontName:boldFontName FontSize:20.f BackColor:darkColor];
    [baseVC makeButtonUI:self.moneyPageBtn FontName:boldFontName FontSize:20.f BackColor:darkColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugHomePageVC) NSLog(@"HomePageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidLayoutSubviews
{
    self.panelView.center = self.view.center;
}

//==================================================
// Button Delegate Methods
//==================================================
#pragma mark- Button Delegate Methods
//==================================================
- (IBAction)settingsBtnPressed:(id)sender {
    if (debugHomePageVC) NSLog(@"HomePageVC settingsBtnPressed");
    
    baseVC.settingsMenuVC.preferredContentSize = CGSizeMake(200.f, 240.f);
    
    popoverController = [[WYPopoverController alloc] initWithContentViewController:(UIViewController *)baseVC.settingsMenuVC];
    popoverController.delegate = self;
    [popoverController presentPopoverFromRect:self.settingsBtn.bounds inView:self.settingsBtn permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
}
- (IBAction)menuBtnPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (debugHomePageVC) NSLog(@"HomePageVC menuBtnPressed: %d", button.tag);
    if (button.tag == 1) {
        [baseVC goToAppsPage];
    } else if (button.tag == 2) {
        [baseVC goToQuotesPage];
    } else if (button.tag == 3) {
        [baseVC goToInvoicesPage];
    } else if (button.tag == 4) {
        [baseVC goToCustomersPage];
    } else if (button.tag == 5) {
        [baseVC goToPaymentsPage];
    } else if (button.tag == 6) {
        [baseVC goToCostsPage];
    }
}

//==================================================
// Custom Methods
//==================================================
#pragma mark- Custom Methods
//==================================================
- (void)dismissPopoverController
{
    if (debugHomePageVC) NSLog(@"HomePageVC dismissPopoverController");
    [popoverController dismissPopoverAnimated:YES];
    popoverController.delegate = nil;
    popoverController = nil;
}

#pragma mark - WYPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    if (controller == popoverController)
    {
        popoverController.delegate = nil;
        popoverController = nil;
    }
}

@end
