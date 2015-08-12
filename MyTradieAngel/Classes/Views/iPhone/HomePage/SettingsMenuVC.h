//
//  SettingsMenuVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface SettingsMenuVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *companyInfoBtn;
@property (weak, nonatomic) IBOutlet UIButton *setupHeadsBtn;
@property (weak, nonatomic) IBOutlet UIButton *syncBtn;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UIButton *changePswdBtn;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

- (void)initWithView:(BaseVC *)rootVC;

@end
