//
//  TimeUtils.m
//  Time
//
//  Created by 余坚 on 15/12/7.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import "TimeUtils.h"

@implementation TimeUtils

/**
 *  @author yj, 15-12-07 15:12:45
 *
 *  判断是否是白天
 *
 *  @return <#return value description#>
 */
+(BOOL) isDayTime
{
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    int hour = (int)[dateComponent hour];
    if (hour >= 6 && hour < 18) {
        return  TRUE;
    }
    else{
        return  FALSE;
    }

    return TRUE;
}
@end
