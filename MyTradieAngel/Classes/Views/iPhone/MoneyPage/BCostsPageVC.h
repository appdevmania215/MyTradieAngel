//
//  BCostsPageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface BCostsPageVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *showMoreBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (weak, nonatomic) IBOutlet UILabel *itemCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(strong, nonatomic) UIView *popupMaskView;
@property (strong, nonatomic) IBOutlet UIView *popupFilterView;
@property (weak, nonatomic) IBOutlet UILabel *filterTitle;

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UITextField *fromDateText;
@property (weak, nonatomic) IBOutlet UITextField *toDateText;
@property (weak, nonatomic) IBOutlet UITextField *costText;
@property (weak, nonatomic) IBOutlet UITextField *sortText;

- (void)initWithView:(BaseVC *)rootVC;
- (void)tableViewScrollToTop;
@end
