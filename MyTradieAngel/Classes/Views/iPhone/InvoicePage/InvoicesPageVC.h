//
//  InvoicesPageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface InvoicesPageVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *showMoreBtn;
@property (weak, nonatomic) IBOutlet UIButton *addInvBtn;

@property (weak, nonatomic) IBOutlet UILabel *invoiceNumLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(strong, nonatomic) UIView *popupMaskView;
@property (strong, nonatomic) IBOutlet UIView *popupFilterView;
@property (weak, nonatomic) IBOutlet UILabel *filterTitle;

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UITextField *fromDateText;
@property (weak, nonatomic) IBOutlet UITextField *toDateText;
@property (weak, nonatomic) IBOutlet UITextField *typeText;
@property (weak, nonatomic) IBOutlet UITextField *sortText;
@property (weak, nonatomic) IBOutlet UITextField *invNumText;
@property (weak, nonatomic) IBOutlet UITextField *invCustomerNameText;

@property(strong, nonatomic) UIView *pdfMaskView;
@property (strong, nonatomic) IBOutlet UIView *popupPdfOptView;
@property (weak, nonatomic) IBOutlet UILabel *pdfOptTitle;

@property (weak, nonatomic) IBOutlet UIButton *pdfOKBtn;
@property (weak, nonatomic) IBOutlet UIButton *pdfCancelBtn;
@property (weak, nonatomic) IBOutlet UITextField *emailOptText;
@property (weak, nonatomic) IBOutlet UITextField *emailIdText;


- (void)initWithView:(BaseVC *)rootVC;
- (void)tableViewScrollToTop;
@end
