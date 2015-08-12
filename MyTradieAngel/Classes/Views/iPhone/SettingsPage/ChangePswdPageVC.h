//
//  ChangePswdPageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface ChangePswdPageVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *panelView;
@property (weak, nonatomic) IBOutlet UITextField *curPswdText;
@property (weak, nonatomic) IBOutlet UITextField *pswdText;
@property (weak, nonatomic) IBOutlet UITextField *confPswdText;

- (void)initWithView:(BaseVC *)rootVC;

@end
