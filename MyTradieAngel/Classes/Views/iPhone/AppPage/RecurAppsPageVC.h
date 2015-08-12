//
//  RecurAppsPageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface RecurAppsPageVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *itemNumLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)initWithView:(BaseVC *)rootVC;
- (void)tableViewScrollToTop;

@end
