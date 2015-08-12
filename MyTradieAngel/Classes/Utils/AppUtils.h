//
//  AppUtils.h
//  AutoDiler
//
//  Created by RenZhe Ahn on 1/28/14.
//  Copyright (c) 2014 MRDzA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtils : NSObject

+ (BOOL)isPad;
+ (NSString *)getDateStringFromDate:(NSDate *)date;
+ (NSString *)getDateStringWithHourFromDate:(NSDate *)date;
+ (NSString *)getConvertedDate:(NSString *)dateString;
+ (NSString *)getDiffDatesFromDate:(NSString *)fromDateString;
+ (NSDate *)getDateTimeFromString:(NSString *)dateString;
+ (NSString *)getTitleTimeFromDate:(NSDate *)date;
+ (NSDate *)getStartDateOfMonthCalendar:(NSDate *)date;
+ (NSDate *)getLastDateOfMonthCalendar:(NSDate *)date;
+ (NSDate *)convertGMTtoLocal:(NSDate *)date;
+ (NSDate *)convertLocaltoGMT:(NSDate *)date;
+ (BOOL)removeAllFilesInDirectory:(NSString *)path Extension:(NSString *)ext;

+ (BOOL)isDeviceOnline;

+ (UIImage *)resizeImageWithImage:(UIImage*)image;
+ (BOOL)checkValidation;

@end
