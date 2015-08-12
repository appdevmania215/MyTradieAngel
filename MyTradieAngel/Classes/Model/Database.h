//
//  Database.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 1/29/14.
//  Copyright (c) 2014 MRDzA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class Model;

@interface Database : NSObject
{
    Model *model;
    sqlite3 *database;
    NSString *dbName;
}

- (id)initWithModel:(Model *)someModel;
- (void)initDatabase;
- (BOOL)truncateTable:(NSString *)tableName;
- (int)getRowCountOfTable:(NSString *)tableName;

- (NSMutableDictionary *)getInvoices;
- (NSMutableDictionary *)getInvoice;
- (NSMutableDictionary *)delInvoice;
- (NSMutableDictionary *)updateInvoice;
- (NSMutableDictionary *)getLatestInvoiceId;

- (NSMutableDictionary *)getQuotations;
- (NSMutableDictionary *)delQuotation;
- (NSMutableDictionary *)getQuotation;
- (NSMutableDictionary *)updateQuotation;
- (NSMutableDictionary *)getLatestQuotationId;

- (NSMutableDictionary *)getPayments;
- (NSMutableDictionary *)getPayment;
- (NSMutableDictionary *)addPayment;
- (NSMutableDictionary *)delPayment;

- (NSMutableDictionary *)getCustomers;
- (NSMutableDictionary *)getCustomer;
- (NSMutableDictionary *)delCustomer;
- (NSMutableDictionary *)updateCustomer;
- (NSMutableDictionary *)getCustomersLookup;

- (NSMutableDictionary *)getApps;
- (NSMutableDictionary *)delApp;
- (NSMutableDictionary *)updateApp;
- (NSMutableDictionary *)getRecurApps;
- (NSMutableDictionary *)delRecurApp;

- (NSMutableDictionary *)getCosts;
- (NSMutableDictionary *)delCost;
- (NSMutableDictionary *)getCost;
- (NSMutableDictionary *)updateCost;

- (NSMutableDictionary *)getAllHeads;
- (NSMutableDictionary *)getHeads;
- (NSMutableDictionary *)delHead;
- (NSMutableDictionary *)updateHead;

- (NSMutableDictionary *)getSettings;
- (BOOL)refreshData;
- (NSMutableDictionary *)getAllUpdatedData;
- (BOOL)didSyncData;

@end
