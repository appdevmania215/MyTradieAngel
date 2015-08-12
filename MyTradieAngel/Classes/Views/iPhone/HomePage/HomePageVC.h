//
//  HomePageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface HomePageVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;

@property (weak, nonatomic) IBOutlet UIView *panelView;
@property (weak, nonatomic) IBOutlet UIButton *appointmentsBtn;
@property (weak, nonatomic) IBOutlet UIButton *quotationsBtn;
@property (weak, nonatomic) IBOutlet UIButton *invoicesBtn;
@property (weak, nonatomic) IBOutlet UIButton *customersBtn;
@property (weak, nonatomic) IBOutlet UIButton *paymentsBtn;
@property (weak, nonatomic) IBOutlet UIButton *moneyPageBtn;

- (void)initWithView:(BaseVC *)rootVC;
- (void)dismissPopoverController;

@end
