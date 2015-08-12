
//
//  Database.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 1/29/14.
//  Copyright (c) 2014 MRDzA. All rights reserved.
//

#import "Database.h"
#import "AppConst.h"
#import "Model.h"
#import "AppUtils.h"

@implementation Database

- (id)initWithModel:(Model *)someModel
{
    if (debugDatabase) NSLog(@"Database initWithModel");
    
    self = [super init];
    
    if (self != nil) {
        model = someModel;
        dbName = @"d_business.db";
        [self initDatabase];
    }
    return self;
}

// --------------
- (void)dealloc {
    if (debugDatabase) NSLog(@"Database dealloc");
    
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: closing database with message '%s'", sqlite3_errmsg(database));
    }
}

- (void)initDatabase
{
    if (debugDatabase) NSLog(@"Database initDatabase");
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *dbPath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), dbName];
    NSLog(@"%@", dbPath);
    BOOL dbExists = [fileMgr fileExistsAtPath:dbPath];
    
    // if DB empty then copy the db file
    if ( !dbExists ) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:dbName];
        
        NSLog(@"Default DB Path: %@", defaultDBPath);
        
        NSError *error;
        BOOL success = [fileMgr copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        if ( !success ) {
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            return;
        }
    }
    
    if (sqlite3_open_v2([dbPath UTF8String], &database, SQLITE_OPEN_READWRITE |
                        SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, 0) == SQLITE_OK) {
        if (debugDatabase) NSLog(@"Database Successfully Opend :)");
    } else {
        NSLog(@"ERROR: DB opening current database");
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with code '%s'.", sqlite3_errmsg(database));
    }
}

- (BOOL)truncateTable:(NSString *)tableName
{
    if (debugDatabase) NSLog(@"Database truncateTable: %@", tableName);
    BOOL result = NO;
    int returnCode;
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@; VACUUM", tableName];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        returnCode = sqlite3_step(statement);
        result = YES;
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (int)getRowCountOfTable:(NSString *)tableName
{
    if (debugDatabase) NSLog(@"Database getCountOfTable: %@", tableName);
    
    int count = 0;
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*)  FROM %@", tableName];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        //Loop through all the returned rows (should be just one)
        while (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
    }
    sqlite3_finalize(statement);
    
    return  count;
}

- (NSMutableDictionary *)getInvoices
{
    if (debugDatabase) NSLog(@"Database getInvoices");
    
    NSString *sql = @"app_completed=1";
    int page = 1;
    if ([model.postOpts objectForKey:@"p"] != nil  &&  [[model.postOpts objectForKey:@"p"] intValue] > 0) {
        page = [[model.postOpts objectForKey:@"p"] intValue];
    }
    if ([model.postOpts objectForKey:@"from_date"] != nil  &&  ![[model.postOpts objectForKey:@"from_date"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND inv_date>='%@ 00:00:00'", sql, [model.postOpts objectForKey:@"from_date"]];
    }
    if ([model.postOpts objectForKey:@"till_date"] != nil  &&  ![[model.postOpts objectForKey:@"till_date"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND inv_date<='%@ 23:59:59'", sql, [model.postOpts objectForKey:@"till_date"]];
    }
    if ([model.postOpts objectForKey:@"types"] != nil) {
        if ([[model.postOpts objectForKey:@"types"] intValue] == 1) {
            sql = [NSString stringWithFormat:@"%@ AND total-amt_paid<0.001 AND amt_paid>0", sql];
        } else if ([[model.postOpts objectForKey:@"types"] intValue] == 2) {
            sql = [NSString stringWithFormat:@"%@ AND total-amt_paid>0.001", sql];
        }
    }
    if ([model.postOpts objectForKey:@"inv_number"] != nil  &&  ![[model.postOpts objectForKey:@"inv_number"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND inv_number='%@'", sql, [model.postOpts objectForKey:@"inv_number"]];
    }
    if ([model.postOpts objectForKey:@"cust_name"] != nil  &&  ![[model.postOpts objectForKey:@"cust_name"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND name LIKE '%@%%'", sql, [model.postOpts objectForKey:@"cust_name"]];
    }
    if ([model.postOpts objectForKey:@"sort"] == nil  ||  [[model.postOpts objectForKey:@"sort"] isEqualToString:@"1"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY inv_date DESC", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"2"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY inv_date", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"3"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY total DESC", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"4"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY total", sql];
    }
    
    if ([model.postOpts objectForKey:@"query"] != nil  &&  ![[model.postOpts objectForKey:@"query"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"app_completed=1 AND inv_number LIKE '%@%%' AND total-amt_paid>0.001  ORDER BY inv_number", [model.postOpts valueForKey:@"query"]];
    }
    int startRow = MAXROWS * (page-1);
    
    sql = [NSString stringWithFormat:@"SELECT *  FROM d_apps  WHERE %@  LIMIT %d,%d", sql, startRow, MAXROWS];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"response_code" forKey:@"OK"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            float amtDue = sqlite3_column_double(statement, 22);
            amtDue -= sqlite3_column_double(statement, 39);
            NSString *dueDays = [NSString stringWithFormat:@"0"];
            if (amtDue > 0.01f) {
                dueDays = [AppUtils getDiffDatesFromDate:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 11)]];
            }
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"app_id"];
            NSString *date = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)];
            if ([date rangeOfString:@"1970"].location != NSNotFound) {
                [dic setObject:@"" forKey:@"app_date"];
            } else {
                [dic setObject:date forKey:@"app_date"];
            }
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 10)] forKey:@"inv_number"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 11)] forKey:@"inv_date"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 4)] forKey:@"name"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 8)] forKey:@"address"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 22)] forKey:@"total"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 41)] forKey:@"gtotal"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", amtDue] forKey:@"due"];
            [dic setObject:dueDays forKey:@"due_days"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 38)] forKey:@"cust_id"];
            
            [arr addObject:dic];
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement); NSLog(@"%@", result);
    return result;
}

- (NSMutableDictionary *)delInvoice
{
    if (debugDatabase) NSLog(@"Database delInvoice");
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM d_apps  WHERE app_id=%d", [[model.postOpts objectForKey:@"id"] intValue]];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 26)] forKey:@"qitem1"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 27)] forKey:@"qprice1"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 28)] forKey:@"qitem2"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 29)] forKey:@"qprice2"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 30)] forKey:@"qitem3"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 31)] forKey:@"qprice3"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 32)] forKey:@"qitem4"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 33)] forKey:@"qprice4"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 34)] forKey:@"qitem5"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 35)] forKey:@"qprice5"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 36)] forKey:@"qtotal"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 37)] forKey:@"quot_sent"];
        }
    } 
    sqlite3_finalize(statement);
    
    sql = @"UPDATE d_apps  SET app_completed='0', inv_number='', inv_date='1970-01-01 00:00:00', item1='', price1='0', item2='', price2='0', item3='', price3='0', item4='', price4='0', item5='', price5='0', total='0', inv_sent='1970-01-01 00:00:00', amt_paid='0', synced='1'";
    
    if ([dic objectForKey:@"qitem1"] == [NSNull null]) sql = [NSString stringWithFormat:@"%@, qitem1=''", sql];
    if ([dic objectForKey:@"qitem2"] == [NSNull null]) sql = [NSString stringWithFormat:@"%@, qitem2=''", sql];
    if ([dic objectForKey:@"qitem3"] == [NSNull null]) sql = [NSString stringWithFormat:@"%@, qitem3=''", sql];
    if ([dic objectForKey:@"qitem4"] == [NSNull null]) sql = [NSString stringWithFormat:@"%@, qitem4=''", sql];
    if ([dic objectForKey:@"qitem5"] == [NSNull null]) sql = [NSString stringWithFormat:@"%@, qitem5=''", sql];
    if ([dic objectForKey:@"qprice1"] == [NSNull null]) sql = [NSString stringWithFormat:@"%@, qprice1='0'", sql];
    if ([dic objectForKey:@"qprice2"] == [NSNull null]) sql = [NSString stringWithFormat:@"%@, qprice2='0'", sql];
    if ([dic objectForKey:@"qprice3"] == [NSNull null]) sql = [NSString stringWithFormat:@"%@, qprice3='0'", sql];
    if ([dic objectForKey:@"qprice4"] == [NSNull null]) sql = [NSString stringWithFormat:@"%@, qprice4='0'", sql];
    if ([dic objectForKey:@"qprice5"] == [NSNull null]) sql = [NSString stringWithFormat:@"%@, qprice5='0'", sql];
    if ([dic objectForKey:@"qtotal"] == [NSNull null]) sql = [NSString stringWithFormat:@"%@, qtotal='0'", sql];
    if ([dic objectForKey:@"quot_sent"] == [NSNull null]) sql = [NSString stringWithFormat:@"%@, quot_sent='1970-01-01 00:00:00'", sql];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sql = [NSString stringWithFormat:@"%@  WHERE app_id=%d", sql, [[model.postOpts objectForKey:@"id"] intValue]];
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
        } else {
            [result setObject:@"ERROR" forKey:@"response_code"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);

    return result;
}

- (NSMutableDictionary *)getInvoice
{
    if (debugDatabase) NSLog(@"Database getInvoice");
    
    NSDictionary *settings = [[self getSettings] objectForKey:@"data"];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM d_apps  WHERE app_id=%d", [[model.postOpts objectForKey:@"id"] intValue]];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"OK" forKey:@"response_code"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"app_id"];
            NSString *date = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)];
            if ([date rangeOfString:@"1970"].location != NSNotFound) {
                [dic setObject:@"" forKey:@"app_date"];
            } else {
                [dic setObject:date forKey:@"app_date"];
            }
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 4)] forKey:@"name"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 5)] forKey:@"email"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 6)] forKey:@"phone"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 8)] forKey:@"address"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 38)] forKey:@"cust_id"];
            
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 10)] forKey:@"inv_number"];
            date = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 11)];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            if ([date rangeOfString:@"0000-00"].location != NSNotFound) {
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *today = [NSDate date];
                date = [dateFormatter stringFromDate:today];
            } else {
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *today = [dateFormatter dateFromString:date];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                date = [dateFormatter stringFromDate:today];
            }
            [dic setObject:date forKey:@"inv_date"];
            if ([date rangeOfString:@"1970"].location != NSNotFound) {
                [dic setObject:@"" forKey:@"inv_date"];
            }
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 12)] forKey:@"item1"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 13)] forKey:@"price1"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 14)] forKey:@"item2"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 15)] forKey:@"price2"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 16)] forKey:@"item3"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 17)] forKey:@"price3"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 18)] forKey:@"item4"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 19)] forKey:@"price4"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 20)] forKey:@"item5"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 21)] forKey:@"price5"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 44)] forKey:@"item6"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 45)] forKey:@"price6"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 46)] forKey:@"item7"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 47)] forKey:@"price7"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 48)] forKey:@"item8"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 49)] forKey:@"price8"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 50)] forKey:@"item9"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 51)] forKey:@"price9"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 52)] forKey:@"item10"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 53)] forKey:@"price10"];
            
            
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 22)] forKey:@"total"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 39)] forKey:@"amt_paid"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 41)] forKey:@"gtotal"];
            [dic setObject:[settings objectForKey:@"tax_percent"] forKey:@"tax_percent"];
            [dic setObject:[settings objectForKey:@"tax_label"] forKey:@"tax_label"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 65)] forKey:@"inv_notes"];

            [arr addObject:dic];
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)updateInvoice
{
    if (debugDatabase) NSLog(@"Database updateInvoice");
    
    NSString *sql;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;

    int appId = [[model.postOpts objectForKey:@"id"] intValue];
    if (appId <= 0) appId = 0;
    NSString *name = [model.postOpts objectForKey:@"name"];
    NSString *email = [model.postOpts objectForKey:@"email"];
    NSString *phone = [model.postOpts objectForKey:@"phone"];
    NSString *address = [model.postOpts objectForKey:@"add"];
    int custId = [[model.postOpts objectForKey:@"cust_id"] intValue];
    if (custId == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *now = [NSDate date];
        NSString *dsignup = [dateFormatter stringFromDate:now];
        
        sql = @"INSERT INTO d_customers  VALUES(?, ?, ?, ?, ?, '1')";
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [email UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [phone UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4, [address UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5, [dsignup UTF8String], -1, SQLITE_TRANSIENT);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                sql = [NSString stringWithFormat:@"SELECT cust_id  FROM d_customers  WHERE name='%@' AND email='%@' AND phone='%@'", name, email, phone];
                sqlite3_stmt *statement1;
                if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement1, nil) == SQLITE_OK) {
                    while (sqlite3_step(statement1) == SQLITE_ROW) { //Loop through all the returned rows
                        custId = sqlite3_column_int(statement1, 0);
                    }
                } else {
                    NSLog(@"Error: %s", sqlite3_errmsg(database));
                    [result setObject:@"ERROR" forKey:@"response_code"];
                    [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
                }
                sqlite3_finalize(statement1);
            }
        } else {
            NSLog(@"Error: %s", sqlite3_errmsg(database));
            [result setObject:@"ERROR" forKey:@"response_code"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
        }
        sqlite3_finalize(statement);
    }
    
    if (custId == 0) return result;
    
    NSString *invNum = [model.postOpts objectForKey:@"inv_number"];
    NSString *invDate = [NSString stringWithFormat:@"%@ 00:00:00", [model.postOpts objectForKey:@"inv_date"]];
    NSString *item1 = [model.postOpts objectForKey:@"i1"];
    float price1 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p1"] isEqualToString:@""] ) {
        price1 = [[model.postOpts objectForKey:@"p1"] floatValue];
    }
    NSString *item2 = [model.postOpts objectForKey:@"i2"];
    float price2 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p2"] isEqualToString:@""] ) {
        price2 = [[model.postOpts objectForKey:@"p2"] floatValue];
    }
    NSString *item3 = [model.postOpts objectForKey:@"i3"];
    float price3 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p3"] isEqualToString:@""] ) {
        price3 = [[model.postOpts objectForKey:@"p3"] floatValue];
    }
    NSString *item4 = [model.postOpts objectForKey:@"i4"];
    float price4 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p4"] isEqualToString:@""] ) {
        price4 = [[model.postOpts objectForKey:@"p4"] floatValue];
    }
    NSString *item5 = [model.postOpts objectForKey:@"i5"];
    float price5 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p5"] isEqualToString:@""] ) {
        price5 = [[model.postOpts objectForKey:@"p5"] floatValue];
    }
    NSString *item6 = [model.postOpts objectForKey:@"i6"];
    float price6 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p6"] isEqualToString:@""] ) {
        price6 = [[model.postOpts objectForKey:@"p6"] floatValue];
    }
    NSString *item7 = [model.postOpts objectForKey:@"i7"];
    float price7 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p7"] isEqualToString:@""] ) {
        price7 = [[model.postOpts objectForKey:@"p7"] floatValue];
    }
    NSString *item8 = [model.postOpts objectForKey:@"i8"];
    float price8 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p8"] isEqualToString:@""] ) {
        price8 = [[model.postOpts objectForKey:@"p8"] floatValue];
    }
    NSString *item9 = [model.postOpts objectForKey:@"i9"];
    float price9 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p9"] isEqualToString:@""] ) {
        price9 = [[model.postOpts objectForKey:@"p9"] floatValue];
    }
    NSString *item10 = [model.postOpts objectForKey:@"i10"];
    float price10 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p10"] isEqualToString:@""] ) {
        price10 = [[model.postOpts objectForKey:@"p10"] floatValue];
    }
    float total = 0.0f;
    if ( ![[model.postOpts objectForKey:@"total"] isEqualToString:@""] ) {
        total = [[model.postOpts objectForKey:@"total"] floatValue];
    }
    float gtotal = 0.0f;
    if ( ![[model.postOpts objectForKey:@"gtotal"] isEqualToString:@""] ) {
        gtotal = [[model.postOpts objectForKey:@"gtotal"] floatValue];
    }
    NSString *taxLabel = [model.postOpts objectForKey:@"tax_label"];
    float taxPercent = 0.0f;
    if ( ![[model.postOpts objectForKey:@"tax_percent"] isEqualToString:@""] ) {
        taxPercent = [[model.postOpts objectForKey:@"tax_percent"] floatValue];
    }
    NSString *invNotes = [model.postOpts objectForKey:@"inv_notes"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (appId > 0) {
        sql = [NSString stringWithFormat:@"SELECT *  FROM d_apps  WHERE app_id=%d", appId];
        
        sqlite3_stmt *statement1;
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement1, nil) == SQLITE_OK) {
            while (sqlite3_step(statement1) == SQLITE_ROW) { //Loop through all the returned rows
                [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement1, 26)] forKey:@"qitem1"];
                [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement1, 27)] forKey:@"qprice1"];
                [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement1, 28)] forKey:@"qitem2"];
                [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement1, 29)] forKey:@"qprice2"];
                [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement1, 30)] forKey:@"qitem3"];
                [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement1, 31)] forKey:@"qprice3"];
                [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement1, 32)] forKey:@"qitem4"];
                [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement1, 33)] forKey:@"qprice4"];
                [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement1, 34)] forKey:@"qitem5"];
                [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement1, 35)] forKey:@"qprice5"];
                [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement1, 36)] forKey:@"qtotal"];
                [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement1, 40)] forKey:@"notified"];
            }
        } else {
            NSLog(@"Error: %s", sqlite3_errmsg(database));
            [result setObject:@"ERROR" forKey:@"response_code"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
        }
        sqlite3_finalize(statement1);
        
        sql = [NSString stringWithFormat:@"UPDATE d_apps  SET name=?, email=?, phone=?, address=?, inv_number=?, inv_date=?, item1=?, price1=?, item2=?, price2=?, item3=?, price3=?, item4=?, price4=?, item5=?, price5=?, item6=?, price6=?, item7=?, price7=?, item8=?, price8=?, item9=?, price9=?, item10=?, price10=?, total=?, cust_id=?, qitem1=?, qprice1=?, qitem2=?, qprice2=?, qitem3=?, qprice3=?, qitem4=?, qprice4=?, qitem5=?, qprice5=?, qtotal=?, notified=?, gtotal=?, tax_percent=?, tax_label=?, inv_notes=?, synced='1'  WHERE app_id=%d", appId];
    } else {
        sql = @"INSERT INTO d_apps  (date, start_time, end_time, name, email, phone, address, inv_number, inv_date, item1, price1, item2, price2, item3, price3, item4, price4, item5, price5, item6, price6, item7, price7, item8, price8, item9, price9, item10, price10, total, cust_id, qitem1, qprice1, qitem2, qprice2, qitem3, qprice3, qitem4, qprice4, qitem5, qprice5, qtotal, app_completed, notified, gtotal, tax_percent, tax_label, inv_notes, synced)  VALUES('1970-01-01 00:00:00', '1970-01-01 00:00:00', '1970-01-01 00:00:00', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '', '0', '', '0', '', '0', '', '0', '', '0', '0', '1', ?, ?, ?, ?, ?, '1')";
    }
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [email UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [phone UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [address UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [invNum UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [invDate UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 7, [item1 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 8, price1);
        sqlite3_bind_text(statement, 9, [item2 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 10, price2);
        sqlite3_bind_text(statement, 11, [item3 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 12, price3);
        sqlite3_bind_text(statement, 13, [item4 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 14, price4);
        sqlite3_bind_text(statement, 15, [item5 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 16, price5);
        sqlite3_bind_text(statement, 17, [item6 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 18, price6);
        sqlite3_bind_text(statement, 19, [item7 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 20, price7);
        sqlite3_bind_text(statement, 21, [item8 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 22, price8);
        sqlite3_bind_text(statement, 23, [item9 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 24, price9);
        sqlite3_bind_text(statement, 25, [item10 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 26, price10);
        sqlite3_bind_double(statement, 27, total);
        sqlite3_bind_int(statement, 28, custId);
        if (appId > 0) {
            if ([dic objectForKey:@"qitem1"] == [NSNull null]) {
                sqlite3_bind_text(statement, 29, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_text(statement, 29, [[dic objectForKey:@"qitem1"] UTF8String], -1, SQLITE_TRANSIENT);
            }
            if ([dic objectForKey:@"qprice1"] == [NSNull null]) {
                sqlite3_bind_double(statement, 30, 0.0f);
            } else {
                sqlite3_bind_double(statement, 30, [[dic objectForKey:@"qprice1"] floatValue]);
            }
            if ([dic objectForKey:@"qitem2"] == [NSNull null]) {
                sqlite3_bind_text(statement, 31, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_text(statement, 31, [[dic objectForKey:@"qitem2"] UTF8String], -1, SQLITE_TRANSIENT);
            }
            if ([dic objectForKey:@"qprice2"] == [NSNull null]) {
                sqlite3_bind_double(statement, 32, 0.0f);
            } else {
                sqlite3_bind_double(statement, 32, [[dic objectForKey:@"qprice2"] floatValue]);
            }
            if ([dic objectForKey:@"qitem3"] == [NSNull null]) {
                sqlite3_bind_text(statement, 33, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_text(statement, 33, [[dic objectForKey:@"qitem3"] UTF8String], -1, SQLITE_TRANSIENT);
            }
            if ([dic objectForKey:@"qprice3"] == [NSNull null]) {
                sqlite3_bind_double(statement, 34, 0.0f);
            } else {
                sqlite3_bind_double(statement, 34, [[dic objectForKey:@"qprice3"] floatValue]);
            }
            if ([dic objectForKey:@"qitem4"] == [NSNull null]) {
                sqlite3_bind_text(statement, 35, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_text(statement, 35, [[dic objectForKey:@"qitem4"] UTF8String], -1, SQLITE_TRANSIENT);
            }
            if ([dic objectForKey:@"qprice4"] == [NSNull null]) {
                sqlite3_bind_double(statement, 36, 0.0f);
            } else {
                sqlite3_bind_double(statement, 36, [[dic objectForKey:@"qprice4"] floatValue]);
            }
            if ([dic objectForKey:@"qitem5"] == [NSNull null]) {
                sqlite3_bind_text(statement, 37, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_text(statement, 37, [[dic objectForKey:@"qitem5"] UTF8String], -1, SQLITE_TRANSIENT);
            }
            if ([dic objectForKey:@"qprice5"] == [NSNull null]) {
                sqlite3_bind_double(statement, 38, 0.0f);
            } else {
                sqlite3_bind_double(statement, 38, [[dic objectForKey:@"qprice5"] floatValue]);
            }
            if ([dic objectForKey:@"qtotal"] == [NSNull null]) {
                sqlite3_bind_double(statement, 39, 0.0f);
            } else {
                sqlite3_bind_double(statement, 39, [[dic objectForKey:@"qtotal"] floatValue]);
            }
            if ([dic objectForKey:@"notified"] == [NSNull null]) {
                sqlite3_bind_double(statement, 40, 0);
            } else {
                sqlite3_bind_double(statement, 40, [[dic objectForKey:@"notified"] intValue]);
            }
        } else {
            sqlite3_bind_text(statement, 29, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_double(statement, 30, 0.0f);
            sqlite3_bind_text(statement, 31, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_double(statement, 32, 0.0f);
            sqlite3_bind_text(statement, 33, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_double(statement, 34, 0.0f);
            sqlite3_bind_text(statement, 35, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_double(statement, 36, 0.0f);
            sqlite3_bind_text(statement, 37, [@"" UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_double(statement, 38, 0.0f);
            sqlite3_bind_double(statement, 39, 0.0f);
            sqlite3_bind_double(statement, 40, 0);
        }
        sqlite3_bind_double(statement, 41, gtotal);
        sqlite3_bind_double(statement, 42, taxPercent);
        sqlite3_bind_text(statement, 43, [taxLabel UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 44, [invNotes UTF8String], -1, SQLITE_TRANSIENT);

        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getLatestInvoiceId
{
    if (debugDatabase) NSLog(@"Database getLatestInvoiceId");
    
    NSString *sql = @"SELECT inv_number  FROM d_apps  ORDER BY cast(inv_number AS signed integer) DESC  LIMIT 0, 1";
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"response_code" forKey:@"OK"];
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            int latestId = sqlite3_column_int(statement, 0);
            [result setObject:@"response_code" forKey:@"OK"];
            [result setObject:[NSString stringWithFormat:@"%d", latestId+1] forKey:@"data"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);

    return result;
}

- (NSMutableDictionary *)getQuotations
{
    if (debugDatabase) NSLog(@"Database getQuotations");
    
    NSString *sql = @"qprice1>0.01";
    int page = 0;
    if ([model.postOpts objectForKey:@"p"] != nil  &&  [[model.postOpts objectForKey:@"p"] intValue] > 0) {
        page = [[model.postOpts objectForKey:@"p"] intValue];
    }
    if ([model.postOpts objectForKey:@"from_date"] != nil  &&  ![[model.postOpts objectForKey:@"from_date"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND q_date>='%@ 00:00:00'", sql, [model.postOpts objectForKey:@"from_date"]];
    }
    if ([model.postOpts objectForKey:@"till_date"] != nil  &&  ![[model.postOpts objectForKey:@"till_date"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND q_date<='%@ 23:59:59'", sql, [model.postOpts objectForKey:@"till_date"]];
    }
    if ([model.postOpts objectForKey:@"quot_number"] != nil  &&  ![[model.postOpts objectForKey:@"quot_number"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND quot_number='%@'", sql, [model.postOpts objectForKey:@"quot_number"]];
    }
    if ([model.postOpts objectForKey:@"cust_name"] != nil  &&  ![[model.postOpts objectForKey:@"cust_name"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND name LIKE '%@%%'", sql, [model.postOpts objectForKey:@"cust_name"]];
    }
    if ([model.postOpts objectForKey:@"sort"] == nil  ||  [[model.postOpts objectForKey:@"sort"] isEqualToString:@"1"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY q_date DESC", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"2"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY q_date", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"3"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY qtotal DESC", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"4"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY qtotal", sql];
    }
    int startRow = MAXROWS * (page-1);
    
    sql = [NSString stringWithFormat:@"SELECT *  FROM d_apps  WHERE %@  LIMIT %d,%d", sql, startRow, MAXROWS];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"response_code" forKey:@"OK"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"app_id"];
            NSString *date = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)];
            if ([date rangeOfString:@"1970"].location != NSNotFound) {
                [dic setObject:@"" forKey:@"app_date"];
            } else {
                [dic setObject:date forKey:@"app_date"];
            }
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 24)] forKey:@"quot_number"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 25)] forKey:@"quot_date"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 4)] forKey:@"name"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 8)] forKey:@"address"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 64)] forKey:@"qgtotal"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 36)] forKey:@"qtotal"];
            
            [arr addObject:dic];
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    return result;
}

- (NSMutableDictionary *)delQuotation
{
    if (debugDatabase) NSLog(@"Database delQuotation");
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE d_apps  SET quot_number='', q_date='1970-01-01 00:00:00', qitem1='', qprice1='0', qitem2='', qprice2='0', qitem3='', qprice3='0', qitem4='', qprice4='0', qitem5='', qprice5='0', qitem6='', qprice6='0', qitem7='', qprice7='0', qitem8='', qprice8='0', qitem9='', qprice9='0', qitem10='', qprice10='0', qtotal='0', quot_sent='1970-01-01 00:00:00', synced='1'  WHERE app_id=%d", [[model.postOpts objectForKey:@"id"] intValue]];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
        } else {
            [result setObject:@"ERROR" forKey:@"response_code"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getQuotation
{
    if (debugDatabase) NSLog(@"Database getQuotation");
    
    NSDictionary *settings = [[self getSettings] objectForKey:@"data"];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM d_apps  WHERE app_id=%d", [[model.postOpts objectForKey:@"id"] intValue]];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"OK" forKey:@"response_code"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"app_id"];
            NSString *date = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)];
            if ([date rangeOfString:@"1970"].location != NSNotFound) {
                [dic setObject:@"" forKey:@"app_date"];
            } else {
                [dic setObject:date forKey:@"app_date"];
            }
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 4)] forKey:@"name"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 5)] forKey:@"email"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 6)] forKey:@"phone"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 8)] forKey:@"address"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 38)] forKey:@"cust_id"];
            
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 24)] forKey:@"quot_number"];
            date = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 25)];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            if ([date rangeOfString:@"0000-00"].location != NSNotFound) {
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *today = [NSDate date];
                date = [dateFormatter stringFromDate:today];
            } else {
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *today = [dateFormatter dateFromString:date];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                date = [dateFormatter stringFromDate:today];
            }
            if ([date rangeOfString:@"1970"].location != NSNotFound) {
                [dic setObject:@"" forKey:@"q_date"];
            } else {
                [dic setObject:date forKey:@"q_date"];
            }
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 26)] forKey:@"qitem1"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 27)] forKey:@"qprice1"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 28)] forKey:@"qitem2"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 29)] forKey:@"qprice2"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 30)] forKey:@"qitem3"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 31)] forKey:@"qprice3"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 32)] forKey:@"qitem4"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 33)] forKey:@"qprice4"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 34)] forKey:@"qitem5"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 35)] forKey:@"qprice5"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 54)] forKey:@"qitem6"];
            if (sqlite3_column_double(statement, 55) > 0) {
                [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 55)] forKey:@"qprice6"];
            } else {
                [dic setObject:@"0" forKey:@"qprice6"];
            }
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 56)] forKey:@"qitem7"];
            if (sqlite3_column_double(statement, 57) > 0) {
                [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 57)] forKey:@"qprice7"];
            } else {
                [dic setObject:@"0" forKey:@"qprice7"];
            }
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 58)] forKey:@"qitem8"];
            if (sqlite3_column_double(statement, 59) > 0) {
                [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 59)] forKey:@"qprice8"];
            } else {
                [dic setObject:@"0" forKey:@"qprice8"];
            }
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 60)] forKey:@"qitem9"];
            if (sqlite3_column_double(statement, 61) > 0) {
                [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 61)] forKey:@"qprice9"];
            } else {
                [dic setObject:@"0" forKey:@"qprice9"];
            }
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 62)] forKey:@"qitem10"];
            if (sqlite3_column_double(statement, 63) > 0) {
                [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 63)] forKey:@"qprice10"];
            } else {
                [dic setObject:@"0" forKey:@"qprice10"];
            }
            
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 64)] forKey:@"qgtotal"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 36)] forKey:@"qtotal"];
            [dic setObject:[settings objectForKey:@"tax_label"] forKey:@"tax_label"];
            [dic setObject:[settings objectForKey:@"tax_percent"] forKey:@"tax_percent"];
            
            [arr addObject:dic];
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getLatestQuotationId
{
    if (debugDatabase) NSLog(@"Database getLatestQuotationId");
    
    NSString *sql = @"SELECT quot_number  FROM d_apps  ORDER BY cast(quot_number AS signed integer) DESC  LIMIT 0, 1";
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"response_code" forKey:@"OK"];
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            int latestId = sqlite3_column_int(statement, 0);
            [result setObject:@"response_code" forKey:@"OK"];
            [result setObject:[NSString stringWithFormat:@"%d", latestId+1] forKey:@"data"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)updateQuotation
{
    if (debugDatabase) NSLog(@"Database updateQuotation");
    
    NSString *sql;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;

    int appId = [[model.postOpts objectForKey:@"id"] intValue];
    if (appId < 0) appId = 0;
    NSString *name = [model.postOpts objectForKey:@"name"];
    NSString *email = [model.postOpts objectForKey:@"email"];
    NSString *phone = [model.postOpts objectForKey:@"phone"];
    NSString *address = [model.postOpts objectForKey:@"add"];
    int custId = [[model.postOpts objectForKey:@"cust_id"] intValue];
    NSString *quotNum = [model.postOpts objectForKey:@"quot_number"];
    NSString *qDate = [NSString stringWithFormat:@"%@ 00:00:00", [model.postOpts objectForKey:@"q_date"]];
    NSString *qitem1 = [model.postOpts objectForKey:@"qi1"];
    float qprice1 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"qp1"] isEqualToString:@""] ) {
        qprice1 = [[model.postOpts objectForKey:@"qp1"] floatValue];
    }
    NSString *qitem2 = [model.postOpts objectForKey:@"qi2"];
    float qprice2 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"qp2"] isEqualToString:@""] ) {
        qprice2 = [[model.postOpts objectForKey:@"qp2"] floatValue];
    }
    NSString *qitem3 = [model.postOpts objectForKey:@"qi3"];
    float qprice3 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"qp3"] isEqualToString:@""] ) {
        qprice3 = [[model.postOpts objectForKey:@"qp3"] floatValue];
    }
    NSString *qitem4 = [model.postOpts objectForKey:@"qi4"];
    float qprice4 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"qp4"] isEqualToString:@""] ) {
        qprice4 = [[model.postOpts objectForKey:@"qp4"] floatValue];
    }
    NSString *qitem5 = [model.postOpts objectForKey:@"qi5"];
    float qprice5 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"qp5"] isEqualToString:@""] ) {
        qprice5 = [[model.postOpts objectForKey:@"qp5"] floatValue];
    }
    NSString *qitem6 = [model.postOpts objectForKey:@"qi6"];
    float qprice6 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"qp6"] isEqualToString:@""] ) {
        qprice6 = [[model.postOpts objectForKey:@"qp6"] floatValue];
    }
    NSString *qitem7 = [model.postOpts objectForKey:@"qi7"];
    float qprice7 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"qp7"] isEqualToString:@""] ) {
        qprice7 = [[model.postOpts objectForKey:@"qp7"] floatValue];
    }
    NSString *qitem8 = [model.postOpts objectForKey:@"qi8"];
    float qprice8 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"qp8"] isEqualToString:@""] ) {
        qprice8 = [[model.postOpts objectForKey:@"p8"] floatValue];
    }
    NSString *qitem9 = [model.postOpts objectForKey:@"qi9"];
    float qprice9 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"qp9"] isEqualToString:@""] ) {
        qprice9 = [[model.postOpts objectForKey:@"qp9"] floatValue];
    }
    NSString *qitem10 = [model.postOpts objectForKey:@"qi10"];
    float qprice10 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"qp10"] isEqualToString:@""] ) {
        qprice10 = [[model.postOpts objectForKey:@"qp10"] floatValue];
    }
    float qgtotal = 0.0f;
    if ( ![[model.postOpts objectForKey:@"qgtotal"] isEqualToString:@""] ) {
        qgtotal = [[model.postOpts objectForKey:@"qgtotal"] floatValue];
    }

    float taxPercent = 0.0f;
    if ( ![[model.postOpts objectForKey:@"tax_percent"] isEqualToString:@""] ) {
        taxPercent = [[model.postOpts objectForKey:@"tax_percent"] floatValue];
    }
    NSString *taxLabel = [model.postOpts objectForKey:@"tax_label"];
    float qtotal = 0.0f;
    if ( ![[model.postOpts objectForKey:@"qtotal"] isEqualToString:@""] ) {
        qtotal = [[model.postOpts objectForKey:@"qtotal"] floatValue];
    }
    
    if (custId == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *now = [NSDate date];
        NSString *dsignup = [dateFormatter stringFromDate:now];
        
        sql = @"INSERT INTO d_customers  VALUES(?, ?, ?, ?, ?, '1')";
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [email UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [phone UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4, [address UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5, [dsignup UTF8String], -1, SQLITE_TRANSIENT);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                sql = [NSString stringWithFormat:@"SELECT cust_id  FROM d_customers  WHERE name='%@' AND email='%@' AND phone='%@'", name, email, phone];
                sqlite3_stmt *statement1;
                if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement1, nil) == SQLITE_OK) {
                    while (sqlite3_step(statement1) == SQLITE_ROW) { //Loop through all the returned rows
                        custId = sqlite3_column_int(statement1, 0);
                    }
                } else {
                    NSLog(@"Error: %s", sqlite3_errmsg(database));
                    [result setObject:@"ERROR" forKey:@"response_code"];
                    [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
                }
                sqlite3_finalize(statement1);
            }
        } else {
            NSLog(@"Error: %s", sqlite3_errmsg(database));
            [result setObject:@"ERROR" forKey:@"response_code"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
        }
        sqlite3_finalize(statement);
    }
    
    if (custId == 0) return result;
    
    if (appId > 0) {
        sql = [NSString stringWithFormat:@"UPDATE d_apps  SET name=?, email=?, phone=?, address=?, quot_number=?, q_date=?, cust_id=?, qitem1=?, qprice1=?, qitem2=?, qprice2=?, qitem3=?, qprice3=?, qitem4=?, qprice4=?, qitem5=?, qprice5=?, qitem6=?, qprice6=?, qitem7=?, qprice7=?, qitem8=?, qprice8=?, qitem9=?, qprice9=?, qitem10=?, qprice10=?, qgtotal=?, tax_percent=?, tax_label=?, qtotal=?, synced='1'  WHERE app_id=%d", appId];
    } else {
        sql = @"INSERT INTO d_apps  (date, start_time, end_time, name, email, phone, address, quot_number, q_date, cust_id, qitem1, qprice1, qitem2, qprice2, qitem3, qprice3, qitem4, qprice4, qitem5, qprice5, qitem6, qprice6, qitem7, qprice7, qitem8, qprice8, qitem9, qprice9, qitem10, qprice10, qgtotal, tax_percent, tax_label, qtotal, synced)  VALUES ('1970-01-01 00:00:00', '1970-01-01 00:00:00', '1970-01-01 00:00:00', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '1')";
    } 
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [email UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [phone UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [address UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [quotNum UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [qDate UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 7, custId);
        sqlite3_bind_text(statement, 8, [qitem1 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 9, qprice1);
        sqlite3_bind_text(statement, 10, [qitem2 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 11, qprice2);
        sqlite3_bind_text(statement, 12, [qitem3 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 13, qprice3);
        sqlite3_bind_text(statement, 14, [qitem4 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 15, qprice4);
        sqlite3_bind_text(statement, 16, [qitem5 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 17, qprice5);
        sqlite3_bind_text(statement, 18, [qitem6 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 19, qprice6);
        sqlite3_bind_text(statement, 20, [qitem7 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 21, qprice7);
        sqlite3_bind_text(statement, 22, [qitem8 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 23, qprice8);
        sqlite3_bind_text(statement, 24, [qitem9 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 25, qprice9);
        sqlite3_bind_text(statement, 26, [qitem10 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 27, qprice10);
        sqlite3_bind_double(statement, 28, qtotal);
        sqlite3_bind_double(statement, 29, taxPercent);
        sqlite3_bind_text(statement, 30, [taxLabel UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 31, qtotal);
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getPayments
{
    if (debugDatabase) NSLog(@"Database getPayments");
    
    NSString *sql = @"pay_id>0";
    int page = 1;
    if ([model.postOpts objectForKey:@"p"] != nil  &&  [[model.postOpts objectForKey:@"p"] intValue] > 0) {
        page = [[model.postOpts objectForKey:@"p"] intValue];
    }
    if ([model.postOpts objectForKey:@"from_date"] != nil  &&  ![[model.postOpts objectForKey:@"from_date"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND pay_date>='%@ 00:00:00'", sql, [model.postOpts objectForKey:@"from_date"]];
    }
    if ([model.postOpts objectForKey:@"till_date"] != nil  &&  ![[model.postOpts objectForKey:@"till_date"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND pay_date<='%@ 23:59:59'", sql, [model.postOpts objectForKey:@"till_date"]];
    }
    if ([model.postOpts objectForKey:@"inv_number"] != nil  &&  ![[model.postOpts objectForKey:@"inv_number"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND inv_number='%@'", sql, [model.postOpts objectForKey:@"inv_number"]];
    }
    if ([model.postOpts objectForKey:@"cust_name"] != nil  &&  ![[model.postOpts objectForKey:@"cust_name"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND name LIKE '%@%%'", sql, [model.postOpts objectForKey:@"cust_name"]];
    }
    if ([model.postOpts objectForKey:@"sort"] == nil  ||  [[model.postOpts objectForKey:@"sort"] isEqualToString:@"1"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY pay_date DESC, pay_id DESC", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"2"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY pay_date", sql];
    }
    int startRow = MAXROWS * (page-1);
    
    sql = [NSString stringWithFormat:@"SELECT *  FROM d_payments  WHERE %@  LIMIT %d,%d", sql, startRow, MAXROWS];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"response_code" forKey:@"OK"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"pay_id"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 3)] forKey:@"inv_number"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)] forKey:@"pay_date"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 9)] forKey:@"cust_name"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 6)] forKey:@"pay_amt"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 7)] forKey:@"txn_ref"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 5)] forKey:@"pay_mode"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 8)] forKey:@"details"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 11)] forKey:@"orig_amt"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 1)] forKey:@"app_id"];
            
            NSMutableDictionary *invoice = [self getInvoiceById:sqlite3_column_int(statement, 1)];
            if (invoice.count > 0) {
                [dic setObject:[invoice objectForKey:@"inv_date"] forKey:@"inv_date"];
                [dic setObject:[invoice objectForKey:@"total"] forKey:@"inv_total"];
            } else {
                [dic setObject:@"" forKey:@"inv_date"];
                [dic setObject:@"" forKey:@"inv_total"];
            }
            
            [arr addObject:dic];
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getPayment
{
    if (debugDatabase) NSLog(@"Database getPayment");
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM d_payments  WHERE pay_id=%d  LIMIT 0,1", [[model.postOpts objectForKey:@"id"] intValue]];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"response_code" forKey:@"OK"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"pay_id"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 1)] forKey:@"event_id"];
            NSString *date = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            if ([date rangeOfString:@"0000-00"].location != NSNotFound) {
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *today = [NSDate date];
                date = [dateFormatter stringFromDate:today];
            } else {
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *today = [dateFormatter dateFromString:date];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                date = [dateFormatter stringFromDate:today];
            }
            [dic setObject:date forKey:@"pay_date"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 3)] forKey:@"inv_number"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 4)] forKey:@"cust_id"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 5)] forKey:@"pay_mode"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 6)] forKey:@"amount"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 7)] forKey:@"txn_ref"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 8)] forKey:@"details"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 9)] forKey:@"cust_name"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 10)] forKey:@"cc_percent"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 11)] forKey:@"orig_amt"];
            
            NSMutableDictionary *invoice = [self getInvoiceById:sqlite3_column_int(statement, 1)];
            if (invoice.count > 0) {
                date = [invoice objectForKey:@"inv_date"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                if ([date rangeOfString:@"0000-00"].location != NSNotFound) {
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate *today = [NSDate date];
                    date = [dateFormatter stringFromDate:today];
                } else {
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *today = [dateFormatter dateFromString:date];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    date = [dateFormatter stringFromDate:today];
                }
                [dic setObject:date forKey:@"inv_date"];
                [dic setObject:[invoice objectForKey:@"total"] forKey:@"inv_total"];
            } else {
                [dic setObject:@"" forKey:@"inv_date"];
                [dic setObject:@"" forKey:@"inv_total"];
            }
            
            [arr addObject:dic];
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    
    return result;
}

- (NSMutableDictionary *)getInvoiceById:(int)invId
{
    if (debugDatabase) NSLog(@"Database getInvoiceById: %d", invId);
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM d_apps  WHERE app_id=%d  LIMIT 0,1", invId];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 11)] forKey:@"inv_date"];
            [result setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 22)] forKey:@"total"];
            [result setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 39)] forKey:@"amt_paid"];
        }
    }
    
    return result;
}

- (NSMutableDictionary *)addPayment
{
    if (debugDatabase) NSLog(@"Database addPayment");
    
    int eventId = [[model.postOpts objectForKey:@"app_id"] intValue];
    NSString *payDate = [NSString stringWithFormat:@"%@ 00:00:00", [model.postOpts objectForKey:@"pay_date"]];
    NSString *invNum = [model.postOpts objectForKey:@"inv_number"];
    int custId = [[model.postOpts objectForKey:@"cust_id"] intValue];
    NSString *payMode = [model.postOpts objectForKey:@"pay_mode"];
    float payAmt = [[model.postOpts objectForKey:@"pay_amt"] floatValue];
    NSString *details = [model.postOpts objectForKey:@"details"];
    NSString *custName = [model.postOpts objectForKey:@"cust_name"];
    
    NSMutableDictionary *temp = [[self getSettings] objectForKey:@"data"];
    float ccPercent = [[temp objectForKey:@"cc_percent"] floatValue];
    
    temp = [self getInvoiceById:eventId];
    float origAmt = [[temp objectForKey:@"total"] floatValue];
    float invPaidAmt = [[temp objectForKey:@"amt_paid"] floatValue];
    invPaidAmt += origAmt;
    
    BOOL eventValid = YES;
    BOOL invValid = YES;
    BOOL custValid = YES;
    if (eventId < 1) eventValid = NO;
    if (invNum == nil  ||  [invNum isEqualToString:@""]) invValid = NO;
    if (custId < 1) custValid = NO;
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    if (eventValid && invValid && custValid) {
        NSString *sql;
        sql = @"INSERT INTO d_payments  (app_id, pay_date, inv_number, cust_id, pay_mode, amount, details, cust_name, cc_percent, orig_amt, synced)  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '1')";
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_int(statement, 1, eventId);
            sqlite3_bind_text(statement, 2, [payDate UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [invNum UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 4, custId);
            sqlite3_bind_text(statement, 5, [payMode UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_double(statement, 6, payAmt);
            sqlite3_bind_text(statement, 7, [details UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 8, [custName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_double(statement, 9, ccPercent);
            sqlite3_bind_double(statement, 10, origAmt);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                [result setObject:@"OK" forKey:@"response_code"];
                sqlite3_stmt *statement1;
                sql = [NSString stringWithFormat:@"UPDATE d_apps  SET amt_paid=?, synced='1'  WHERE app_id=%d", eventId];
                if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement1, NULL) == SQLITE_OK) {
                    sqlite3_bind_double(statement, 1, invPaidAmt);
                    if (sqlite3_step(statement) == SQLITE_DONE) {
                        [result setObject:@"OK" forKey:@"response_code"];
                    }
                }
                sqlite3_finalize(statement1);
            }
        } else {
            NSLog(@"Error: %s", sqlite3_errmsg(database));
            [result setObject:@"ERROR" forKey:@"response_code"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
        }
        sqlite3_finalize(statement);
    } else {
        [result setObject:@"ERROR" forKey:@"response_code"];
        if (!eventValid  ||  !invValid) [result setObject:@"Invoice is not valid" forKey:@"error"];
        if ( !custValid ) [result setObject:@"Customer is not registered" forKey:@"error"];
    }
    
    return result;
}

- (NSMutableDictionary *)delPayment
{
    if (debugDatabase) NSLog(@"Database delPayment");
    
    int appId = 0;
    float origAmt = 0.0f;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    int payId = [[model.postOpts objectForKey:@"id"] intValue];
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM d_payments  WHERE pay_id=%d  LIMIT 0,1", payId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            appId = sqlite3_column_int(statement, 1);
            origAmt = sqlite3_column_double(statement, 11);
        }
        sqlite3_stmt *statement1;
        
        sql = [NSString stringWithFormat:@"DELETE FROM d_payments  WHERE pay_id=%d", payId];
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement1, nil) == SQLITE_OK) {
            if (sqlite3_step(statement1) == SQLITE_DONE) {
                [result setObject:@"OK" forKey:@"response_code"];
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setObject:@"d_payments" forKey:@"table"];
                [dic setObject:[NSString stringWithFormat:@"%d", payId] forKey:@"delId"];
                [result setObject:dic forKey:@"deleted"];
            }
        }
        sqlite3_finalize(statement1);
        
        float invPaidAmt = [[[self getInvoiceById:appId] objectForKey:@"amt_paid"] floatValue];
        invPaidAmt -= origAmt;
        if (invPaidAmt < 0) invPaidAmt = 0.0f;
        sql = [NSString stringWithFormat:@"UPDATE d_apps  SET amt_paid=?, synced='1'  WHERE app_id=%d", appId];
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement1, NULL) == SQLITE_OK) {
            sqlite3_bind_double(statement, 1, invPaidAmt);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                [result setObject:@"OK" forKey:@"response_code"];
            }
        }
        sqlite3_finalize(statement1);
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getCustomersLookup
{
    if (debugDatabase) NSLog(@"Database getCustomersLookup");
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM d_customers  WHERE name LIKE '%@%%'  LIMIT 0, 20", [model.postOpts objectForKey:@"query"]];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"OK" forKey:@"response_code"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            NSString *string = [NSString stringWithFormat:@"%@,%@", [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)], [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)]];
            [dic setObject:string forKey:@"value"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"data"];
            
            [arr addObject:dic];
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getCustomers
{
    if (debugDatabase) NSLog(@"Database getCustomers");
    
    NSString *sql = @"cust_id>0";
    int page = 1;
    if ([model.postOpts objectForKey:@"p"] != nil  &&  [[model.postOpts objectForKey:@"p"] intValue] > 0) {
        page = [[model.postOpts objectForKey:@"p"] intValue];
    }
    if ([model.postOpts objectForKey:@"from_date"] != nil  &&  ![[model.postOpts objectForKey:@"from_date"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND dsignup>='%@ 00:00:00'", sql, [model.postOpts objectForKey:@"from_date"]];
    }
    if ([model.postOpts objectForKey:@"till_date"] != nil  &&  ![[model.postOpts objectForKey:@"till_date"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND dsignup<='%@ 23:59:59'", sql, [model.postOpts objectForKey:@"till_date"]];
    }
    if ([model.postOpts objectForKey:@"cust_name"] != nil  &&  ![[model.postOpts objectForKey:@"cust_name"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND name LIKE '%@%%'", sql, [model.postOpts objectForKey:@"cust_name"]];
    }
    
    if ( [sql isEqualToString:@""] ) {
        sql = @"SELECT *  FROM d_customers ";
    } else {
        sql = [NSString stringWithFormat:@"SELECT *  FROM d_customers  WHERE %@ ", sql];
    }
    
    if ([model.postOpts objectForKey:@"sort"] == nil  ||  [[model.postOpts objectForKey:@"sort"] isEqualToString:@"1"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY name", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"2"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY email", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"3"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY dsignup", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"4"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY dsignup DESC", sql];
    }
    int startRow = MAXROWS * (page-1);
    
    sql = [NSString stringWithFormat:@"%@  LIMIT %d,%d", sql, startRow, MAXROWS];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"response_code" forKey:@"OK"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"cust_id"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)] forKey:@"name"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)] forKey:@"email"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 3)] forKey:@"phone"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 4)] forKey:@"address"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 5)] forKey:@"signup_date"];
            
            [arr addObject:dic];
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getCustomer
{
    if (debugDatabase) NSLog(@"Database getCustomer");
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM d_customers  WHERE cust_id=%d  LIMIT 0, 1", [[model.postOpts objectForKey:@"id"] intValue]];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"OK" forKey:@"response_code"];
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"cust_id"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)] forKey:@"name"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)] forKey:@"email"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 3)] forKey:@"phone"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 4)] forKey:@"address"];
            
            [result setObject:dic forKey:@"data"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getCustomerById:(int)custId
{
    if (debugDatabase) NSLog(@"Database getCustomerById: %d", custId);
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM d_customers  WHERE cust_id=%d  LIMIT 0, 1", custId];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            [result setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"cust_id"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)] forKey:@"name"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)] forKey:@"email"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 3)] forKey:@"phone"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 4)] forKey:@"address"];
        }
    } else {
        result = nil;
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)delCustomer
{
    if (debugDatabase) NSLog(@"Database delCustomer");
    
    int custId = [[model.postOpts objectForKey:@"id"] intValue];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSString *sql = [NSString stringWithFormat:@"UPDATE d_apps  SET cust_id='0', synced='1'  WHERE cust_id=%d", custId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
            sql = [NSString stringWithFormat:@"DELETE FROM d_customers  WHERE cust_id=%d", custId];
            sqlite3_stmt *statement1;
            if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement1, nil) == SQLITE_OK) {
                if (sqlite3_step(statement1) == SQLITE_DONE) {
                    [result setObject:@"OK" forKey:@"response_code"];
                    
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setObject:@"d_customers" forKey:@"table"];
                    [dic setObject:[NSString stringWithFormat:@"%d", custId] forKey:@"delId"];
                    [result setObject:dic forKey:@"deleted"];
                }
            }
            sqlite3_finalize(statement1);
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)updateCustomer
{
    if (debugDatabase) NSLog(@"Database updateCustomer");
    
    int custId = [[model.postOpts objectForKey:@"id"] intValue];
    if (custId < 0) custId = 0;
    NSString *name = [model.postOpts objectForKey:@"name"];
    NSString *email = [model.postOpts objectForKey:@"email"];
    NSString *phone = [model.postOpts objectForKey:@"phone"];
    NSString *address = [model.postOpts objectForKey:@"address"];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSString *sql;
    sqlite3_stmt *statement;
    if (custId == 0) { // if new customer, check that email is already registered
        sql = @"SELECT cust_id  FROM d_customers  WHERE email=?  LIMIT 0,1";
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [email UTF8String], -1, SQLITE_TRANSIENT);
            if (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
                custId = sqlite3_column_int(statement, 0);
            }
        }
        sqlite3_finalize(statement);
    }
    
    if (custId > 0) { // update
        sql = [NSString stringWithFormat:@"UPDATE d_customers  SET name=?, email=?, phone=?, address=?, synced='1'  WHERE cust_id=%d", custId];
    } else { // insert
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *now = [NSDate date];
        NSString *dsignup = [dateFormatter stringFromDate:now];
        
        sql = [NSString stringWithFormat:@"INSERT INTO d_customers  (name, email, phone, address, dsignup, synced)  VALUES (?, ?, ?, ?, '%@', '1')", dsignup];
    }
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [email UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [phone UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [address UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getApps
{
    if (debugDatabase) NSLog(@"Database getApps");
    
    NSDictionary *settings = [[self getSettings] objectForKey:@"data"];
    
    NSString *year = [model.postOpts objectForKey:@"y"];
    NSString *month = [model.postOpts objectForKey:@"m"];
    NSString *day = [model.postOpts objectForKey:@"d"];
    NSString *date1 = [NSString stringWithFormat:@"%@-%@-%@", year, month, day];
    NSString *year2 = [model.postOpts objectForKey:@"y2"];
    NSString *month2 = [model.postOpts objectForKey:@"m2"];
    NSString *day2 = [model.postOpts objectForKey:@"d2"];
    NSString *date2 = [NSString stringWithFormat:@"%@-%@-%@", year2, month2, day2];
    int completed = [[model.postOpts objectForKey:@"comp"] intValue];
    
    NSString *sql = @"SELECT *  FROM d_apps  WHERE app_id>0";
    if (completed) sql = [NSString stringWithFormat:@"%@ AND app_completed=1", sql];
    else sql = [NSString stringWithFormat:@"%@ AND app_completed<>1", sql];
    sql = [NSString stringWithFormat:@"%@ AND (start_time BETWEEN '%@' AND '%@')  ORDER BY start_time, app_id", sql, date1, date2];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"OK" forKey:@"response_code"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"event_id"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)] forKey:@"date"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)] forKey:@"start_time"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 3)] forKey:@"end_time"];
            if ([[dic objectForKey:@"end_time"] rangeOfString:@"0000-00"].location != NSNotFound) {
                [dic setObject:[dic objectForKey:@"start_time"] forKey:@"end_time"];
            }
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 4)] forKey:@"name"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 5)] forKey:@"email"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 6)] forKey:@"phone"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 7)] forKey:@"notes"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 8)] forKey:@"address"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 9)] forKey:@"app_completed"];
            
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 10)] forKey:@"inv_number"];
            if ([[dic valueForKey:@"inv_number"] isEqualToString:@""]) {
                NSString *invNum = [[self getLatestInvoiceId] objectForKey:@"data"];
                [dic setObject:invNum forKey:@"inv_number"];
            }
            NSString *date = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 11)]; 
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            if ([date rangeOfString:@"0000-00"].location != NSNotFound) {
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *today = [NSDate date];
                date = [dateFormatter stringFromDate:today];
            } else {
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *today = [dateFormatter dateFromString:date];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                date = [dateFormatter stringFromDate:today];
            }
            [dic setObject:date forKey:@"inv_date"];
            if ([date rangeOfString:@"1970"].location != NSNotFound) {
                [dic setObject:@"" forKey:@"inv_date"];
            }
            
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 12)] forKey:@"item1"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 13)] forKey:@"price1"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 14)] forKey:@"item2"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 15)] forKey:@"price2"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 16)] forKey:@"item3"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 17)] forKey:@"price3"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 18)] forKey:@"item4"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 19)] forKey:@"price4"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 20)] forKey:@"item5"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 21)] forKey:@"price5"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 44)] forKey:@"item6"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 45)] forKey:@"price6"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 46)] forKey:@"item7"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 47)] forKey:@"price7"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 48)] forKey:@"item8"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 49)] forKey:@"price8"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 50)] forKey:@"item9"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 51)] forKey:@"price9"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 52)] forKey:@"item10"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 53)] forKey:@"price10"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 22)] forKey:@"total"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 41)] forKey:@"gtotal"];

            [dic setObject:[settings objectForKey:@"tax_label"] forKey:@"tax_label"];
            [dic setObject:[settings objectForKey:@"tax_percent"] forKey:@"tax_percent"];
            
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 38)] forKey:@"cust_id"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 65)] forKey:@"inv_notes"];
            
            [arr addObject:dic];
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)delApp
{
    if (debugDatabase) NSLog(@"Database delApp");
    
    int appId = [[model.postOpts objectForKey:@"id"] intValue];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM d_apps  WHERE app_id=%d", appId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:@"d_apps" forKey:@"table"];
            [dic setObject:[NSString stringWithFormat:@"%d", appId] forKey:@"delId"];
            [result setObject:dic forKey:@"deleted"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getAppById:(int)appId
{
    if (debugDatabase) NSLog(@"Database getAppById: %d", appId);
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM d_apps  WHERE app_id=%d  LIMIT 0, 1", appId];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)] forKey:@"start_time"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 3)] forKey:@"end_time"];
        }
    } else {
        result = nil;
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)updateApp
{
    if (debugDatabase) NSLog(@"Database updateApp");
    
    int appId = [[model.postOpts valueForKey:@"id"] intValue];
    if (appId <= 0) appId = 0;
    
    NSString *sql;
    sqlite3_stmt *statement;
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    NSString *name = [model.postOpts objectForKey:@"name"];
    NSString *email = [model.postOpts objectForKey:@"email"];
    NSString *phone = [model.postOpts objectForKey:@"phone"];
    NSString *address = [model.postOpts objectForKey:@"add"];
    int custId = [[model.postOpts objectForKey:@"cust_id"] intValue];
    if (custId == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *now = [NSDate date];
        NSString *dsignup = [dateFormatter stringFromDate:now];
        
        sql = @"INSERT INTO d_customers  VALUES(?, ?, ?, ?, ?, '1')";
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [email UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [phone UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4, [address UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5, [dsignup UTF8String], -1, SQLITE_TRANSIENT);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                sql = [NSString stringWithFormat:@"SELECT cust_id  FROM d_customers  WHERE name='%@' AND email='%@' AND phone='%@'", name, email, phone];
                sqlite3_stmt *statement1;
                if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement1, nil) == SQLITE_OK) {
                    while (sqlite3_step(statement1) == SQLITE_ROW) { //Loop through all the returned rows
                        custId = sqlite3_column_int(statement1, 0);
                    }
                } else {
                    NSLog(@"Error: %s", sqlite3_errmsg(database));
                    [result setObject:@"ERROR" forKey:@"response_code"];
                    [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
                }
                sqlite3_finalize(statement1);
            }
        } else {
            NSLog(@"Error: %s", sqlite3_errmsg(database));
            [result setObject:@"ERROR" forKey:@"response_code"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
        }
        sqlite3_finalize(statement);
    }
    if (custId == 0) return result;
    
    NSString *date = [model.postOpts objectForKey:@"dt"];
    NSString *startDate = [model.postOpts objectForKey:@"start"];
    NSString *endDate = [model.postOpts objectForKey:@"end"];
    NSString *notes = [model.postOpts objectForKey:@"notes"];
    int completed = [[model.postOpts objectForKey:@"complete"] intValue];
    
    NSString *invNum = [model.postOpts objectForKey:@"inv_number"];
    NSString *invDate = [NSString stringWithFormat:@"%@", [model.postOpts objectForKey:@"inv_date"]];
    NSString *invNotes = [model.postOpts objectForKey:@"inv_notes"];
    NSString *item1 = [model.postOpts objectForKey:@"i1"];
    float price1 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p1"] isEqualToString:@""] ) {
        price1 = [[model.postOpts objectForKey:@"p1"] floatValue];
    }
    NSString *item2 = [model.postOpts objectForKey:@"i2"];
    float price2 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p2"] isEqualToString:@""] ) {
        price2 = [[model.postOpts objectForKey:@"p2"] floatValue];
    }
    NSString *item3 = [model.postOpts objectForKey:@"i3"];
    float price3 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p3"] isEqualToString:@""] ) {
        price3 = [[model.postOpts objectForKey:@"p3"] floatValue];
    }
    NSString *item4 = [model.postOpts objectForKey:@"i4"];
    float price4 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p4"] isEqualToString:@""] ) {
        price4 = [[model.postOpts objectForKey:@"p4"] floatValue];
    }
    NSString *item5 = [model.postOpts objectForKey:@"i5"];
    float price5 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p5"] isEqualToString:@""] ) {
        price5 = [[model.postOpts objectForKey:@"p5"] floatValue];
    }
    NSString *item6 = [model.postOpts objectForKey:@"i6"];
    float price6 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p6"] isEqualToString:@""] ) {
        price6 = [[model.postOpts objectForKey:@"p6"] floatValue];
    }
    NSString *item7 = [model.postOpts objectForKey:@"i7"];
    float price7 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p7"] isEqualToString:@""] ) {
        price7 = [[model.postOpts objectForKey:@"p7"] floatValue];
    }
    NSString *item8 = [model.postOpts objectForKey:@"i8"];
    float price8 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p8"] isEqualToString:@""] ) {
        price8 = [[model.postOpts objectForKey:@"p8"] floatValue];
    }
    NSString *item9 = [model.postOpts objectForKey:@"i9"];
    float price9 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p9"] isEqualToString:@""] ) {
        price9 = [[model.postOpts objectForKey:@"p9"] floatValue];
    }
    NSString *item10 = [model.postOpts objectForKey:@"i10"];
    float price10 = 0.0f;
    if ( ![[model.postOpts objectForKey:@"p10"] isEqualToString:@""] ) {
        price10 = [[model.postOpts objectForKey:@"p10"] floatValue];
    }
    float total = 0.0f;
    if ( ![[model.postOpts objectForKey:@"total"] isEqualToString:@""] ) {
        total = [[model.postOpts objectForKey:@"total"] floatValue];
    }
    float gtotal = 0.0f;
    if ( ![[model.postOpts objectForKey:@"gtotal"] isEqualToString:@""] ) {
        gtotal = [[model.postOpts objectForKey:@"gtotal"] floatValue];
    }
    NSString *taxLabel = [model.postOpts objectForKey:@"tax_label"];
    float taxPercent = 0.0f;
    if ( ![[model.postOpts objectForKey:@"tax_percent"] isEqualToString:@""] ) {
        taxPercent = [[model.postOpts objectForKey:@"tax_percent"] floatValue];
    }
    
    if (appId > 0) {
        sql = [NSString stringWithFormat:@"UPDATE d_apps  SET date=?, start_time=?, end_time=?, name=?, email=?, phone=?, notes=?, address=?, app_completed=?, inv_number=?, inv_date=?, item1=?, price1=?, item2=?, price2=?, item3=?, price3=?, item4=?, price4=?, item5=?, price5=?, total=?, cust_id=?, gtotal=?, tax_label=?, tax_percent=?, item6=?, price6=?, item7=?, price7=?, item8=?, price8=?, item9=?, price9=?, item10=?, price10=?, inv_notes=?, synced='1'  WHERE app_id=%d", appId];
    } else {
        sql = @"INSERT INTO d_apps  (date, start_time, end_time, name, email, phone, notes, address, app_completed, inv_number, inv_date, item1, price1, item2, price2, item3, price3, item4, price4, item5, price5, total, cust_id, gtotal, tax_label, tax_percent, item6, price6, item7, price7, item8, price8, item9, price9, item10, price10, inv_notes, synced)  VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '1')";
    }
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [date UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [startDate UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [endDate UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [email UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 6, [phone UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 7, [notes UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 8, [address UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 9, completed);
        sqlite3_bind_text(statement, 10, [invNum UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 11, [invDate UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 12, [item1 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 13, price1);
        sqlite3_bind_text(statement, 14, [item2 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 15, price2);
        sqlite3_bind_text(statement, 16, [item3 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 17, price3);
        sqlite3_bind_text(statement, 18, [item4 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 19, price4);
        sqlite3_bind_text(statement, 20, [item5 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 21, price5);
        
        sqlite3_bind_double(statement, 22, total);
        sqlite3_bind_int(statement, 23, custId);
        sqlite3_bind_double(statement, 24, gtotal);
        sqlite3_bind_text(statement, 25, [taxLabel UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 26, taxPercent);
        
        sqlite3_bind_text(statement, 27, [item6 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 28, price6);
        sqlite3_bind_text(statement, 29, [item7 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 30, price7);
        sqlite3_bind_text(statement, 31, [item8 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 32, price8);
        sqlite3_bind_text(statement, 33, [item9 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 34, price9);
        sqlite3_bind_text(statement, 35, [item10 UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(statement, 36, price10);
        sqlite3_bind_text(statement, 37, [invNotes UTF8String], -1, SQLITE_TRANSIENT);
       
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    if (appId == 0) {
        sql = @"SELECT MAX(app_id)  FROM d_apps";
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            [result setObject:@"OK" forKey:@"response_code"];
            while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
                appId = sqlite3_column_int(statement, 0);
            }
        } else {
            NSLog(@"Error: %s", sqlite3_errmsg(database));
            [result setObject:@"ERROR" forKey:@"response_code"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
        }
        sqlite3_finalize(statement);
    }
    
    if ([[result valueForKey:@"response_code"] isEqualToString:@"OK"]) {
        int recurFlag = [[model.postOpts valueForKey:@"recur_flag"] intValue];
        if (recurFlag == 1) {
            sql = [NSString stringWithFormat:@"INSERT INTO d_recur  (cust_id, start_time, end_time, mon, tue, wed, thu, fri, sat, sun, same_date, app_id, every_week, synced)  VALUES ('%d', '%@', '%@', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '1') ", custId, startDate, endDate, [[model.postOpts valueForKey:@"mon"] intValue], [[model.postOpts valueForKey:@"tue"] intValue], [[model.postOpts valueForKey:@"wed"] intValue], [[model.postOpts valueForKey:@"thu"] intValue], [[model.postOpts valueForKey:@"fri"] intValue], [[model.postOpts valueForKey:@"sat"] intValue], [[model.postOpts valueForKey:@"sun"] intValue], [[model.postOpts valueForKey:@"same_date"] intValue], appId, [[model.postOpts valueForKey:@"every_week"] intValue]];
        } else {
            sql = [NSString stringWithFormat:@"DELETE FROM d_recur  WHERE app_id=%d", appId];
            
            int rId = [self getDeletedIdWithSql:[NSString stringWithFormat:@"SELECT r_id  FROM d_recur  WHERE app_id=%d", appId]];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:@"d_recur" forKey:@"table"];
            [dic setObject:[NSString stringWithFormat:@"%d", rId] forKey:@"delId"];
            [result setObject:dic forKey:@"deleted"];
        }
        
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_DONE) {
                [result setObject:@"OK" forKey:@"response_code"];
            }
        } else {
            NSLog(@"Error: %s", sqlite3_errmsg(database));
            [result setObject:@"ERROR" forKey:@"response_code"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
        }
        sqlite3_finalize(statement);
    }

    return result;
}

- (NSMutableDictionary *)getRecurApps
{
    if (debugDatabase) NSLog(@"Database getRecurApps");
    
    int page = 0;
    if ([model.postOpts objectForKey:@"p"] != nil  &&  [[model.postOpts objectForKey:@"p"] intValue] > 0) {
        page = [[model.postOpts objectForKey:@"p"] intValue];
    }
    NSString *sql = @"r_id>0  ORDER BY r_id";
    int startRow = MAXROWS * (page-1);
    
    sql = [NSString stringWithFormat:@"SELECT *  FROM d_recur  WHERE %@  LIMIT %d,%d", sql, startRow, MAXROWS];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"response_code" forKey:@"OK"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSDictionary *customer = [self getCustomerById:sqlite3_column_int(statement, 1)];
            NSDictionary *app = [self getAppById:sqlite3_column_int(statement, 13)];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"recur_id"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 1)] forKey:@"cust_id"];
            if (customer != nil) {
                [dic setObject:[customer objectForKey:@"name"] forKey:@"cust_name"];
            } else {
                [dic setObject:@"" forKey:@"cust_name"];
            }
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 13)] forKey:@"app_id"];
            
            if ([app objectForKey:@"start_time"] != nil) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *date = [dateFormatter dateFromString:[app objectForKey:@"start_time"]];
                [dateFormatter setDateFormat:@"EEE dd MMM, yyyy HH:mm"];
                [dic setObject:[dateFormatter stringFromDate:date] forKey:@"start_time"];
            } else {
                [dic setObject:@"" forKey:@"start_time"];
            }
            if ([app objectForKey:@"end_time"] != nil) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *date = [dateFormatter dateFromString:[app objectForKey:@"end_time"]];
                [dateFormatter setDateFormat:@"EEE dd MMM, yyyy HH:mm"];
                [dic setObject:[dateFormatter stringFromDate:date] forKey:@"end_time"];
            } else {
                [dic setObject:@"" forKey:@"end_time"];
            }
            
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 5)] forKey:@"mon"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 6)] forKey:@"tue"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 7)] forKey:@"wed"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 8)] forKey:@"thu"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 9)] forKey:@"fri"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 10)] forKey:@"sat"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 11)] forKey:@"sun"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 14)] forKey:@"every_week"];
            
            [arr addObject:dic]; 
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)delRecurApp
{
    if (debugDatabase) NSLog(@"Database delRecurApp");
    
    int recurId = [[model.postOpts objectForKey:@"id"] intValue];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM d_recur  WHERE r_id=%d", recurId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:@"d_recur" forKey:@"table"];
            [dic setObject:[NSString stringWithFormat:@"%d", recurId] forKey:@"delId"];
            [result setObject:dic forKey:@"deleted"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getCosts
{
    if (debugDatabase) NSLog(@"Database getCosts");
    
    NSString *sql = @"c_id>0";
    int page = 1;
    if ([model.postOpts objectForKey:@"p"] != nil  &&  [[model.postOpts objectForKey:@"p"] intValue] > 0) {
        page = [[model.postOpts objectForKey:@"p"] intValue];
    }
    if ([model.postOpts objectForKey:@"from_date"] != nil  &&  ![[model.postOpts objectForKey:@"from_date"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND date>='%@ 00:00:00'", sql, [model.postOpts objectForKey:@"from_date"]];
    }
    if ([model.postOpts objectForKey:@"till_date"] != nil  &&  ![[model.postOpts objectForKey:@"till_date"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND date<='%@ 23:59:59'", sql, [model.postOpts objectForKey:@"till_date"]];
    }
    if ([model.postOpts objectForKey:@"cost_head"] != nil  &&  ![[model.postOpts objectForKey:@"cost_head"] isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"%@ AND head LIKE '%@%%'", sql, [model.postOpts objectForKey:@"cost_head"]];
    }
    
    if ( [sql isEqualToString:@""] ) {
        sql = @"SELECT *  FROM d_costs ";
    } else {
        sql = [NSString stringWithFormat:@"SELECT *  FROM d_costs  WHERE %@ ", sql];
    }
    
    if ([model.postOpts objectForKey:@"sort"] == nil  ||  [[model.postOpts objectForKey:@"sort"] isEqualToString:@"4"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY date DESC", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"2"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY amt", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"3"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY date", sql];
    } else if ([[model.postOpts objectForKey:@"sort"] isEqualToString:@"1"]) {
        sql = [NSString stringWithFormat:@"%@ ORDER BY head", sql];
    }
    int startRow = MAXROWS * (page-1);
    
    sql = [NSString stringWithFormat:@"%@  LIMIT %d,%d", sql, startRow, MAXROWS];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"response_code" forKey:@"OK"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"c_id"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)] forKey:@"date"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)] forKey:@"head"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 3)] forKey:@"amt"];
            
            [arr addObject:dic];
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)delCost
{
    if (debugDatabase) NSLog(@"Database delCost");
    
    int costId = [[model.postOpts objectForKey:@"id"] intValue];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM d_costs  WHERE c_id=%d", costId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:@"d_costs" forKey:@"table"];
            [dic setObject:[NSString stringWithFormat:@"%d", costId] forKey:@"delId"];
            [result setObject:dic forKey:@"deleted"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getCost
{
    if (debugDatabase) NSLog(@"Database getCost");
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM d_costs  WHERE c_id=%d  LIMIT 0, 1", [[model.postOpts objectForKey:@"id"] intValue]];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"OK" forKey:@"response_code"];
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"c_id"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)] forKey:@"date"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)] forKey:@"head"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 3)] forKey:@"amt"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 4)] forKey:@"tax_incl"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 5)] forKey:@"image"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 6)] forKey:@"head_id"];
            
            [result setObject:dic forKey:@"data"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)updateCost
{
    if (debugDatabase) NSLog(@"Database updateCost");
    
    int costId = [[model.postOpts objectForKey:@"id"] intValue];
    NSString *date = [model.postOpts valueForKey:@"date"];
    NSString *head = [model.postOpts valueForKey:@"head"];
    float amount = [[model.postOpts valueForKey:@"amount"] floatValue];
    int taxIncl = [[model.postOpts valueForKey:@"tax_incl"] intValue];
    NSString *image = [model.postOpts valueForKey:@"image"];
    int headId = [[model.postOpts valueForKey:@"head_id"] intValue];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSString *sql;
    
    if (costId > 0) {
        sql = [NSString stringWithFormat:@"UPDATE d_costs  SET date='%@', head=?, amt='%.02f', tax_incl='%d', image=?, head_id='%d', synced='1'  WHERE c_id=%d", date, amount, taxIncl, headId, costId];
    } else {
        sql = [NSString stringWithFormat:@"INSERT INTO d_costs  (date, head, amt, tax_incl, image, head_id, synced)  VALUES ('%@', ?, '%.02f', '%d', ?, '%d', '1')", date, amount, taxIncl, headId];
    } 
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [head UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [image UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getHeads
{
    if (debugDatabase) NSLog(@"Database getHeads");
    
    int page = 1;
    if ([model.postOpts objectForKey:@"p"] != nil  &&  [[model.postOpts objectForKey:@"p"] intValue] > 0) {
        page = [[model.postOpts objectForKey:@"p"] intValue];
    }

    int startRow = MAXROWS * (page-1) * 2;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT *  FROM d_heads  ORDER BY head_id  LIMIT %d,%d", startRow, MAXROWS * 2];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"response_code" forKey:@"OK"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"head_id"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)] forKey:@"head"];
            
            [arr addObject:dic];
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getAllHeads
{
    if (debugDatabase) NSLog(@"Database getAllHeads");
    
    NSString *sql = @"SELECT *  FROM d_heads  ORDER BY head_id";
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        [result setObject:@"response_code" forKey:@"OK"];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 0)] forKey:@"head_id"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)] forKey:@"head"];
            
            [arr addObject:dic];
        }
        [result setObject:arr forKey:@"data"];
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)delHead
{
    if (debugDatabase) NSLog(@"Database delHead");
    
    int headId = [[model.postOpts objectForKey:@"id"] intValue];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM d_heads  WHERE head_id=%d", headId];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:@"d_heads" forKey:@"table"];
            [dic setObject:[NSString stringWithFormat:@"%d", headId] forKey:@"delId"];
            [result setObject:dic forKey:@"deleted"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)updateHead
{
    if (debugDatabase) NSLog(@"Database updateHead");
    
    int headId = [[model.postOpts objectForKey:@"id"] intValue];
    NSString *head = [model.postOpts valueForKey:@"head"];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSString *sql;
    
    if (headId > 0) {
        sql = [NSString stringWithFormat:@"UPDATE d_heads  SET head=?, synced='1'  WHERE head_id=%d", headId];
    } else {
        sql = [NSString stringWithFormat:@"INSERT INTO d_heads  (head, synced)  VALUES (?, '1')"];
    } 
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [head UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [result setObject:@"OK" forKey:@"response_code"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (NSMutableDictionary *)getSettings
{
    if (debugDatabase) NSLog(@"Database getSettings");
    
    NSString *sql = @"SELECT *  FROM d_settings  WHERE nid>0  LIMIT 0, 1";
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            [result setObject:@"OK" forKey:@"response_code"];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 5)] forKey:@"business_name"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 7)] forKey:@"address"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 19)] forKey:@"address_area"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 18)] forKey:@"postcode"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 8)] forKey:@"abn"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 9)] forKey:@"bank_details"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 20)] forKey:@"invoice_mail"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 10)] forKey:@"invoice_notes"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 21)] forKey:@"quot_mail"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 11)] forKey:@"quot_notes"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 6)] forKey:@"logo_file"];
            
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 12)] forKey:@"app_default_amt"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 13)] forKey:@"tax_label"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 14)] forKey:@"tax_percent"];
            [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, 15)] forKey:@"cc_percent"];
            [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 16)] forKey:@"app_default_label"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 22)] forKey:@"sms_allowed"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 23)] forKey:@"sms_time"];
            [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 24)] forKey:@"sms_email"];
            
            [result setObject:dic forKey:@"data"];
        }
    } else {
        NSLog(@"Error: %s", sqlite3_errmsg(database));
        [result setObject:@"ERROR" forKey:@"response_code"];
        [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
    }
    sqlite3_finalize(statement);
    
    return result;
}

- (int)getDeletedIdWithSql:(NSString *)sql
{
    if (debugDatabase) NSLog(@"Database getDeletedIdWithSql: %@", sql);
    
    int delId = -1;
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
            delId = sqlite3_column_int(statement, 0);
        }
    }
    sqlite3_finalize(statement);
    
    return delId;
}

- (BOOL)refreshData
{
    if (debugDatabase) NSLog(@"Database refreshData");

    BOOL flag;
    NSString *sql = @"";
    NSString *baseSql = @"";
    NSString *valuesSql = @"";
    sqlite3_stmt *statement;
    NSArray *tableNames = [model.data allKeys];
    for (NSString *tableName in tableNames) {
        if ( ![self truncateTable:tableName] ) {
            NSLog(@"Error: %s", sqlite3_errmsg(database));
            return NO;
        }
        flag = YES;
        sql = [NSString stringWithFormat:@"PRAGMA table_info('%@')", tableName]; // getting all column names of table
        NSMutableArray *cols = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            baseSql = [NSString stringWithFormat:@"INSERT INTO %@  (", tableName];
            valuesSql = @"  VALUES (";
            while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)] forKey:@"col_name"];
                [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)] forKey:@"col_type"];
                [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 5)] forKey:@"pk"];
                
                if (flag) { // first column
                    baseSql = [NSString stringWithFormat:@"%@%@", baseSql, [dic valueForKey:@"col_name"]];
                    valuesSql = [NSString stringWithFormat:@"%@?", valuesSql];
                    flag = NO;
                } else {
                    baseSql = [NSString stringWithFormat:@"%@, %@", baseSql, [dic valueForKey:@"col_name"]];
                    valuesSql = [NSString stringWithFormat:@"%@, ?", valuesSql];
                }
                [cols addObject:dic];
            }
            baseSql = [NSString stringWithFormat:@"%@)", baseSql];
            valuesSql = [NSString stringWithFormat:@"%@)", valuesSql];
        } else {
            NSLog(@"Error: %s", sqlite3_errmsg(database));
            return NO;
        }
        sqlite3_finalize(statement);
        
        sql = [NSString stringWithFormat:@"%@%@", baseSql, valuesSql];
        for (NSDictionary *data in [model.data objectForKey:tableName]) {
            if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
                int i = 1;
                for (NSDictionary *col in cols) {
                    NSString *colType = [[col valueForKey:@"col_type"] lowercaseString];
                    NSString *value = [data valueForKey:[col valueForKey:@"col_name"]];
                    
                    if ([[col valueForKey:@"col_name"] isEqualToString:@"synced"]) {
                        sqlite3_bind_int(statement, i, 0);
                    } else if ([colType rangeOfString:@"varchar"].location!=NSNotFound  ||  [colType rangeOfString:@"date"].location!=NSNotFound  ||  [colType rangeOfString:@"text"].location!=NSNotFound) {
                        sqlite3_bind_text(statement, i, [value UTF8String], -1, SQLITE_TRANSIENT);
                    } else if ([colType rangeOfString:@"int"].location != NSNotFound) {
                        sqlite3_bind_int(statement, i, [value intValue]);
                    } else if ([colType rangeOfString:@"float"].location!=NSNotFound) {
                        sqlite3_bind_double(statement, i, [value floatValue]);
                    }
                    i++;
                }
                if (sqlite3_step(statement) != SQLITE_DONE) {
                    sqlite3_finalize(statement);
                    return NO;
                }
            } else {
                NSLog(@"Error: %s", sqlite3_errmsg(database));
                sqlite3_finalize(statement);
                return NO;
            }
            sqlite3_finalize(statement);
        }
    }
    
    return YES;
}

- (NSMutableDictionary *)getAllUpdatedData
{
    if (debugDatabase) NSLog(@"Database getAllUpdatedData");
    NSArray *tableNames = [[NSArray alloc] initWithObjects:@"d_apps", @"d_costs", @"d_customers", @"d_heads", @"d_payments", @"d_recur", @"d_settings", nil];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *tableData = [[NSMutableDictionary alloc] init];
    NSString *sql = @"";
    sqlite3_stmt *statement;
    
    for (NSString *tableName in tableNames) {
        sql = [NSString stringWithFormat:@"PRAGMA table_info('%@')", tableName]; // getting all column names of table
        NSMutableArray *cols = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            [result setObject:@"OK" forKey:@"response_code"];
            while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)] forKey:@"col_name"];
                [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)] forKey:@"col_type"];
                [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 5)] forKey:@"pk"];
                
                [cols addObject:dic];
            }
        } else {
            NSLog(@"Error: %s", sqlite3_errmsg(database));
            [result setObject:@"ERROR" forKey:@"response_code"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
            break;
        }
        sqlite3_finalize(statement);
        
        sql = [NSString stringWithFormat:@"SELECT *  FROM %@  WHERE synced=1", tableName];
                
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            [result setObject:@"OK" forKey:@"response_code"];
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            
            while (sqlite3_step(statement) == SQLITE_ROW) { //Loop through all the returned rows
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                int i = 0; 
                for (NSDictionary *col in cols) {
                    NSString *colType = [[col valueForKey:@"col_type"] lowercaseString];
                    NSString *colName = [col valueForKey:@"col_name"];

                    if ([[col valueForKey:@"col_name"] isEqualToString:@"synced"]) {
                        
                    } else if ([colType rangeOfString:@"varchar"].location!=NSNotFound  ||  [colType rangeOfString:@"date"].location!=NSNotFound  ||  [colType rangeOfString:@"text"].location!=NSNotFound) {
                        [dic setObject:[NSString stringWithFormat:@"%s", sqlite3_column_text(statement, i)] forKey:colName];
                    } else if ([colType rangeOfString:@"int"].location != NSNotFound) {
                        [dic setObject:[NSString stringWithFormat:@"%d", sqlite3_column_int(statement, i)] forKey:colName];
                    } else if ([colType rangeOfString:@"float"].location!=NSNotFound) {
                        [dic setObject:[NSString stringWithFormat:@"%.02f", sqlite3_column_double(statement, i)] forKey:colName];
                    }
                    i++;
                }
                [arr addObject:dic];
            }
            if ([arr count] > 0) [tableData setObject:arr forKey:tableName];
        } else {
            NSLog(@"Error: %s", sqlite3_errmsg(database));
            [result setObject:@"ERROR" forKey:@"response_code"];
            [result setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(database)] forKey:@"error"];
            break;
        }
        sqlite3_finalize(statement);
    }
    
    if ([tableData count] > 0) [result setObject:tableData forKey:@"updated"];
    
    return result;
}

- (BOOL)didSyncData
{
    if (debugDatabase) NSLog(@"Database didSyncData");
    
    NSArray *tableNames = [[NSArray alloc] initWithObjects:@"d_apps", @"d_costs", @"d_customers", @"d_heads", @"d_payments", @"d_recur", @"d_settings", nil];
    
    for (NSString *tableName in tableNames) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@  SET synced='0'  WHERE synced=1", tableName];
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            if (sqlite3_step(statement) != SQLITE_DONE) {
                return NO;
            }
        } else {
            return NO;
        }
        sqlite3_finalize(statement);
    }
    
    return YES;
}
@end
