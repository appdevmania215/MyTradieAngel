//
//  InvoiceCell.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 2/21/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvoiceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *invNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel2;
@property (weak, nonatomic) IBOutlet UILabel *customerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *customerAddrLabel;
@property (weak, nonatomic) IBOutlet UILabel *invAmtLabel;
@property (weak, nonatomic) IBOutlet UILabel *invAmtLabel2;

@end