//
//  BCostPageVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"

@interface BCostPageVC : UIViewController

@property(nonatomic, retain) NSMutableArray *allHeads;
@property(nonatomic, retain) NSMutableArray *allHeadIds;

@property(nonatomic, assign) BOOL imagePickerFlag;
@property(nonatomic, assign) BOOL flag;
@property(nonatomic, retain) NSString *costId;

@property (weak, nonatomic) IBOutlet UITextField *headText;
@property (weak, nonatomic) IBOutlet UITextField *descText;
@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (weak, nonatomic) IBOutlet UITextField *amtText;
@property (weak, nonatomic) IBOutlet UITextField *taxOptText;
@property (weak, nonatomic) IBOutlet UIImageView *receiptImageView;

- (void)initWithView:(BaseVC *)rootVC;

@end
