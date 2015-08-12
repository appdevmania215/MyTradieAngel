//
//  RecurAppCell.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/20/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecurAppCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *customerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *toTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;

@end
