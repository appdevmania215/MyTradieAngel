//
//  AppUtils.m
//  AutoDiler
//
//  Created by RenZhe Ahn on 1/28/14.
//  Copyright (c) 2014 MRDzA. All rights reserved.
//

#import "AppUtils.h"
#import "AppConst.h"

#import "NSDate+DP.h"
#import "Reachability.h"

@implementation AppUtils

+(BOOL)isPad
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

+ (NSString *)getDateStringFromDate:(NSDate *)date
{
    if (debugUtils) NSLog(@"AppUtils getConvertedDateWithOption: %@", date);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

+ (NSString *)getDateStringWithHourFromDate:(NSDate *)date
{
    if (debugUtils) NSLog(@"AppUtils getDateStringWithHourFromDate: %@", date);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

+ (NSDate *)getDateTimeFromString:(NSString *)dateString
{
    if (debugUtils) NSLog(@"AppUtis getDateTimeFromString: %@", dateString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    return date;
}

+ (NSString *)getTitleTimeFromDate:(NSDate *)date
{
    if (debugUtils) NSLog(@"AppUtis getTitleTimeFromDate: %@", date);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:date];
    int hour = comps.hour;
    int min = comps.minute;
    NSString *result = @"";
    if (hour < 12) {
        if (min <= 0) {
            result = [NSString stringWithFormat:@"%da", hour];
        } else {
            result = [NSString stringWithFormat:@"%d:%da", hour, min];
        }
    } else {
        hour = hour % 12;
        if (min <= 0) {
            result = [NSString stringWithFormat:@"%dp", hour];
        } else {
            result = [NSString stringWithFormat:@"%d:%dp", hour, min];
        }
    }
    
    return result;
}

+ (NSString *)getConvertedDate:(NSString *)dateString
{
    if (debugUtils) NSLog(@"AppUtis getConvertedDateWithOption: %@", dateString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"d MMM, yyyy"];
    NSString *convertedDateString = [dateFormatter stringFromDate:date];
    return convertedDateString;
}

+ (NSString *)getDiffDatesFromDate:(NSString *)fromDateString
{
    if (debugUtils) NSLog(@"AppUtis getDiffDatesFromDate: %@", fromDateString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fromDate = [dateFormatter dateFromString:fromDateString];
    NSDate *toDate = [NSDate date];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
    NSString *diffDatesString = [NSString stringWithFormat:@"%d", components.day];
    return diffDatesString;
}

+ (BOOL)isDeviceOnline
{
    if (debugUtils) NSLog(@"AppUtils isDeviceOnline");
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        if (debugUtils) NSLog(@"AppUtils isDeviceOnline Result: offline");
        return NO;
    } else {
        if (debugUtils) NSLog(@"AppUtils isDeviceOnline Result: online");
        return YES;
    }
}

+ (NSDate *)getStartDateOfMonthCalendar:(NSDate *)date
{
    if (debugUtils) NSLog(@"AppUtils getStartDateOfMonthCalendar: %@", date);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    date = [date dp_firstDateOfMonth:calendar];
    NSDateComponents *comps =
    [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                fromDate:date];
    int daysDifference = -1 * ((comps.weekday - 1) % 7);
    
    return [[date dp_dateWithDay:(daysDifference> 0) ? (daysDifference - 7) : daysDifference calendar:calendar] dateByAddingTimeInterval:DP_DAY];
}

+ (NSDate *)getLastDateOfMonthCalendar:(NSDate *)date
{
    if (debugUtils) NSLog(@"AppUtils getLastDateOfMonthCalendar: %@", date);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    date = [date dp_lastDateOfMonth:calendar];
    NSDateComponents *comps =
    [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                fromDate:date];
    int daysRmain = 6 - ((comps.weekday - 1) % 7);
    daysRmain = daysRmain == 7 ? 0 : daysRmain;

    return [date dp_dateWithDay:comps.day+daysRmain calendar:calendar];
}

+ (NSDate *)convertGMTtoLocal:(NSDate *)date
{
    if (debugUtils) NSLog(@"AppUtils convertGMTtoLocal: %@", date);
    
    NSTimeZone *curTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger curGMTOffset = [curTimeZone secondsFromGMTForDate:date];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:date];
    NSTimeInterval gmtInterval = curGMTOffset - gmtOffset;
    
    NSDate *destDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:date];
    
    return destDate;
}

+ (NSDate *)convertLocaltoGMT:(NSDate *)date
{
    if (debugUtils) NSLog(@"AppUtils convertLocaltoGMT: %@", date);
    
    NSTimeZone *curTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger curGMTOffset = [curTimeZone secondsFromGMTForDate:date];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:date];
    NSTimeInterval gmtInterval = gmtOffset - curGMTOffset;
    
    NSDate *destDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:date];
    
    return destDate;
}

+ (BOOL)removeAllFilesInDirectory:(NSString *)path Extension:(NSString *)ext
{
    if (debugUtils) NSLog(@"AppUtils removeAllPngFilesInDirectory: %@, %@", path, ext);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:path error:&error]) {
        if ([[[file pathExtension] lowercaseString] isEqualToString:ext]) {
            if ([fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error]) {
                continue;
            } else {
                NSLog(@"%@", error);
                return NO;
            }
        }
    } 
    return YES;
}

+ (UIImage *)resizeImageWithImage:(UIImage*)image
{
    float sWidth = 480.f;
    float sHeight = 640.f;
    
    CGSize size = image.size;
    float widthRatio = size.width / sWidth;
    float heightRatio = size.height / sHeight;
    float maxRatio = MAX(widthRatio, heightRatio);
    size.width = size.width / maxRatio;
    size.height = size.height / maxRatio;
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}

+ (BOOL)checkValidation
{
    if (debugUtils) NSLog(@"checkValidation");
    /*
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    NSDate *expiredDate = [dateFormatter dateFromString:EXPIRED_DATE];
    
    if ([today compare:expiredDate] == NSOrderedSame  ||  [today compare:expiredDate] == NSOrderedDescending) return NO;
    */
    return YES;
}

@end
