//
//  AppsPageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface AppsPageVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *showBtn;

- (void)initWithView:(BaseVC *)rootVC;
@end
