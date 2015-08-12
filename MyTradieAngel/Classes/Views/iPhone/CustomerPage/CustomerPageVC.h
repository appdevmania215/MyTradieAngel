//
//  CustomerPageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface CustomerPageVC : UIViewController

@property(nonatomic, assign) BOOL flag;
@property(nonatomic, assign) int customerId;

@property (weak, nonatomic) IBOutlet UITextField *custNameText;
@property (weak, nonatomic) IBOutlet UITextField *custAddrText;
@property (weak, nonatomic) IBOutlet UITextField *custPhoneText;
@property (weak, nonatomic) IBOutlet UITextField *custEmailText;

- (void)initWithView:(BaseVC *)rootVC;
- (void)initForm;
- (void)populateData;

@end
