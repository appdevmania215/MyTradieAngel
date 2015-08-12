//
//  Model.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 1/2/14.
//  Copyright (c) 2014 MRDzA. All rights reserved.
//

#import "Model.h"
#import "BaseVC.h"
#import "AppConst.h"
#import "Database.h"

@implementation Model

//@synthesize view;

- (id) init
{
    if (debugModel) NSLog(@"Model init");
    
    self = [super init];
    if (self != nil) {
        self.db = [[Database alloc] initWithModel:self];
        
        self.menuItems = [[NSArray alloc] initWithObjects:@"Appointments", @"Invoices", @"Quotations", @"Payments", @"Customers", @"Settings", @"Logout", nil];
        
        self.dateFormats = [[NSArray alloc] initWithObjects:@"yyyy-mm-dd", @"yyyy/mm/dd", @"mm-dd-yyyy", @"mm/dd/yyyy", @"dd-mm-yyyy", @"dd/mm/yyyy", nil];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int h=8; h<=48; h++) {
            NSString *item = [NSString stringWithFormat:@"%d hours before appointment", h];
            [arr addObject:item];
        }
        self.sendSmsOpts = [[NSArray alloc] initWithArray:arr];
        self.invTypes = [[NSArray alloc] initWithObjects:@"Both Paid and Unpaid", @"Only Paid", @"Only Unpaid", nil];
        self.sorts = [[NSArray alloc] initWithObjects:@"Latest To Oldest", @"Oldest to Latest", @"Largest to Smallest Amount", @"Smallest to Largest Amount", nil];
        self.customerSorts = [[NSArray alloc] initWithObjects:@"By Name", @"By Email", @"Signup Earliest to Latest", @"Signup Latest to Earliest", nil];
        self.costSorts = [[NSArray alloc] initWithObjects:@"By Head", @"By Amount", @"Earliest to Latest", @"Latest to Earliest", nil];
        
        self.emailOpts = [[NSArray alloc] initWithObjects:@"Don't send email", @"Send email", nil];
        self.invoiceEmailIdOpts = [[NSArray alloc] initWithObjects:@"Use email id as in Invoice", @"Use email id as on File", nil];
        self.quoteEmailIdOpts = [[NSArray alloc] initWithObjects:@"Use email id as in Quotation", @"Use email id as on File", nil];
        
        self.repeatWeekOpts = [[NSArray alloc] initWithObjects:@"Choose to repeat weekly", @"After 1 week", @"After 2 weeks", @"After 3 weeks", @"After 4 weeks", @"After 5 weeks", @"After 6 weeks", @"After 7 weeks", @"After 8 weeks", @"After 9 weeks", @"After 10 weeks", @"After 11 weeks", @"After 12 weeks", nil];
        
        self.postOpts = [[NSMutableDictionary alloc] init];
        self.allData = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)clearData
{
    self.sessionId = @"";
    self.postOpts = nil;
    self.postOptsBackup = nil;
    self.allData = nil;
    self.data = nil;
    self.dataId = 0;
}

- (void)backupData
{
    self.postOptsBackup = [[NSDictionary alloc] initWithDictionary:self.postOpts copyItems:YES];
}

- (void)recoverData
{
    self.postOpts = [[NSMutableDictionary alloc] initWithDictionary:self.postOptsBackup copyItems:YES];
    self.postOptsBackup = nil;
}

- (NSString *)getInvType:(NSString *)typeString
{
    if (debugModel) NSLog(@"Model getInvType: %@", typeString);
    int index = [self.invTypes indexOfObject:typeString];
    NSString *indexString = [NSString stringWithFormat:@"%d", index];
    return indexString;
}

- (NSString *)getSortIndex:(NSString *)sortString
{
    if (debugModel) NSLog(@"Model getInvSort: %@", sortString);
    int index = [self.sorts indexOfObject:sortString];
    index += 1;
    NSString *indexString = [NSString stringWithFormat:@"%d", index];
    return indexString;
}

- (NSString *)getCustomerSortIndex:(NSString *)sortString
{
    if (debugModel) NSLog(@"Model getCustomerSortIndex: %@", sortString);
    int index = [self.customerSorts indexOfObject:sortString];
    index += 1;
    NSString *indexString = [NSString stringWithFormat:@"%d", index];
    return indexString;
}

- (NSString *)getCostSortIndex:(NSString *)sortString
{
    if (debugModel) NSLog(@"Model getCostSortIndex: %@", sortString);
    int index = [self.costSorts indexOfObject:sortString];
    index += 1;
    NSString *indexString = [NSString stringWithFormat:@"%d", index];
    return indexString;
}

- (NSString *)getEmailOptIndex:(NSString *)emailOptString
{
    if (debugModel) NSLog(@"Model getEmailOpt: %@", emailOptString);
    int index = [self.emailOpts indexOfObject:emailOptString];
    NSString *indexString = [NSString stringWithFormat:@"%d", index];
    return indexString;
}

- (NSString *)getInvoiceEmailIdOptIndex:(NSString *)emailIdOptString
{
    if (debugModel) NSLog(@"Model getInvoiceEmailIdOptIndex: %@", emailIdOptString);
    int index = [self.invoiceEmailIdOpts indexOfObject:emailIdOptString];
    NSString *indexString = [NSString stringWithFormat:@"%d", index];
    return indexString;
}

- (NSString *)getQuoteEmailIdOptIndex:(NSString *)emailIdOptString
{
    if (debugModel) NSLog(@"Model getQuoteEmailIdOptIndex: %@", emailIdOptString);
    int index = [self.quoteEmailIdOpts indexOfObject:emailIdOptString];
    NSString *indexString = [NSString stringWithFormat:@"%d", index];
    return indexString;
}

- (NSString *)getRepeatWeekOptIndex:(NSString *)repeatWeekOptString
{
    if (debugModel) NSLog(@"Model getRepeatWeekOptIndex: %@", repeatWeekOptString);
    int index = [self.repeatWeekOpts indexOfObject:repeatWeekOptString];
    NSString *indexString = [NSString stringWithFormat:@"%d", index];
    return indexString;
}

/*
+(Model*)getInstance{
    static Model *sharedInstance = nil;
    if ( sharedInstance == nil ) {
        sharedInstance = [[Model alloc] init];
    }
    return sharedInstance;
}
*/
@end
