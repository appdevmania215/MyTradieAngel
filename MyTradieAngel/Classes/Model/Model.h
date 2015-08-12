//
//  Model.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 1/2/14.
//  Copyright (c) 2014 MRDzA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseVC, Database;

@interface Model : NSObject
{
    BaseVC *view;
}

//@property(nonatomic, retain) BaseVC *view;
@property(nonatomic, retain) Database *db;

@property(nonatomic, retain) NSArray *menuItems;
@property(nonatomic, retain) NSArray *curPickerData;

@property(nonatomic, retain) NSArray *dateFormats;
@property(nonatomic, retain) NSArray *sendSmsOpts;
@property(nonatomic, retain) NSArray *invTypes;
@property(nonatomic, retain) NSArray *sorts;
@property(nonatomic, retain) NSArray *customerSorts;
@property(nonatomic, retain) NSArray *costSorts;

@property(nonatomic, retain) NSArray *emailOpts;
@property(nonatomic, retain) NSArray *invoiceEmailIdOpts;
@property(nonatomic, retain) NSArray *quoteEmailIdOpts;

@property(nonatomic, retain) NSArray *repeatWeekOpts;

@property(nonatomic, retain) NSString *sessionId;

@property(nonatomic, retain) NSMutableDictionary *postOpts;
@property(nonatomic, retain) NSDictionary *postOptsBackup;
@property(nonatomic, retain) NSMutableArray *allData;
@property(nonatomic, retain) NSMutableDictionary *data;
@property(nonatomic, retain) NSString *dataId;
@property(nonatomic, retain) NSMutableArray *customers;

- (void)clearData;
- (void)backupData;
- (void)recoverData;

- (NSString *)getInvType:(NSString *)typeString;
- (NSString *)getSortIndex:(NSString *)sortString;
- (NSString *)getCustomerSortIndex:(NSString *)sortString;
- (NSString *)getCostSortIndex:(NSString *)sortString;
- (NSString *)getEmailOptIndex:(NSString *)emailOptString;
- (NSString *)getInvoiceEmailIdOptIndex:(NSString *)emailIdOptString;
- (NSString *)getQuoteEmailIdOptIndex:(NSString *)emailIdOptString;
- (NSString *)getRepeatWeekOptIndex:(NSString *)repeatWeekOptString;

//+(Model*) getInstance;

@end
