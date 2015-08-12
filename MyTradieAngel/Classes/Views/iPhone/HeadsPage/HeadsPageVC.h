//
//  HeadsPageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface HeadsPageVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *itemCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(strong, nonatomic) UIView *popupMaskView;
@property (strong, nonatomic) IBOutlet UIView *popupEditView;
@property (weak, nonatomic) IBOutlet UILabel *popupTitle;

@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UITextField *headText;

- (void)initWithView:(BaseVC *)rootVC;
- (void)tableViewScrollToTop;

@end
