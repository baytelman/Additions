//
//  NSDate+Additions.m
//
//  Created by Wess Cope on 6/1/11.
//  Copyright 2012. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate(Additions)


NSCalendar * gregorianCalendar()
{
    static NSCalendar *gregorian = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    });
    return gregorian;
}

+(int) unixTimestampFromDate:(NSDate *)aDate
{
    time_t unixDate = (time_t)[aDate timeIntervalSince1970];
    return (int)unixDate;
}

+(int) unixTimestampNow
{
    return [NSDate unixTimestampFromDate:[NSDate date]];
}

- (int)datestamp
{
    DateInformation info = self.dateInformation;
    return info.year * 10000 + info.month * 100 + info.day;
}

+ (NSDate *)date:(NSDate *)aDate add:(NSUInteger)increment of:(NSDateTimeType)type
{
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];

    switch (type) 
    {
        case NSDateSecondsType:
            [components setSecond:increment];
            break;
        case NSDateMinutesType:
            [components setMinute:increment];
            break;
            
        case NSDateHoursType:
            [components setHour:increment];
            break;
            
        case NSDateDaysType:
            [components setDay:increment];
            break;
            
        case NSDateWeekType:
            [components setWeek:increment];
            break;
            
        case NSDateMonthsType:
            [components setMonth:increment];
            break;
            
        case NSDateYearType:
            [components setYear:increment];
            break;
            
        default:
            break;
    }

    return [gregorianCalendar() dateByAddingComponents:components toDate:aDate options:0];
}

+ (NSDate*) yesterday{
	DateInformation inf = [[NSDate date] dateInformation];
	inf.day--;
	return [NSDate dateFromDateInformation:inf];
}
+ (NSDate*) month{
    return [[NSDate date] monthDate];
}


- (NSDate*) monthDate {
	NSDateComponents *comp = [gregorianCalendar() components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self];
	[comp setDay:1];
	NSDate *date = [gregorianCalendar() dateFromComponents:comp];
    return date;
}
- (NSDate*) yearDate {
	NSDateComponents *comp = [gregorianCalendar() components:(NSYearCalendarUnit) fromDate:self];
	[comp setDay:1];
	[comp setMonth:1];
	NSDate *date = [gregorianCalendar() dateFromComponents:comp];
    return date;
}



- (int) weekday{
	NSDateComponents *comps = [gregorianCalendar() components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:self];
	int weekday = [comps weekday];
	return weekday;
}
- (NSDate*) timelessDate {
	NSDate *day = self;
	NSDateComponents *comp = [gregorianCalendar() components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:day];
	return [gregorianCalendar() dateFromComponents:comp];
}

- (BOOL) isSameDay:(NSDate*)anotherDate{
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:anotherDate];
	return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
} 

- (int) monthsBetweenDate:(NSDate *)toDate{
    NSDateComponents *components = [gregorianCalendar() components:NSMonthCalendarUnit
                                                fromDate:[self monthDate]
                                                  toDate:[toDate monthDate]
                                                 options:0];
    NSInteger months = [components month];
    return abs(months);
}
- (NSInteger) daysBetweenDate:(NSDate*)d{
	
	NSTimeInterval time = [self timeIntervalSinceDate:d];
	return abs(time / 60 / 60/ 24);
	
}
- (BOOL) isToday{
	return [self isSameDay:[NSDate date]];
} 


- (NSDate *) dateByAddingDays:(NSUInteger)days {
	NSDateComponents *c = [[NSDateComponents alloc] init];
	c.day = days;
	return [[NSCalendar currentCalendar] dateByAddingComponents:c toDate:self options:0];
}
+ (NSDate *) dateWithDatePart:(NSDate *)aDate andTimePart:(NSDate *)aTime {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd/MM/yyyy"];
	NSString *datePortion = [dateFormatter stringFromDate:aDate];
	
	[dateFormatter setDateFormat:@"HH:mm"];
	NSString *timePortion = [dateFormatter stringFromDate:aTime];
	
	[dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
	NSString *dateTime = [NSString stringWithFormat:@"%@ %@",datePortion,timePortion];
	return [dateFormatter dateFromString:dateTime];
}

- (NSString*) monthString
{
	static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM"];
    }
	return [dateFormatter stringFromDate:self];
}
- (NSString*) yearString{
	static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy"];
    }
	return [dateFormatter stringFromDate:self];
}


- (DateInformation) dateInformationWithTimeZone:(NSTimeZone*)tz{
	
	DateInformation info;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone:tz];
	NSDateComponents *comp = [gregorian components:(NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit | 
													NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit) 
										  fromDate:self];
	info.day = [comp day];
	info.month = [comp month];
	info.year = [comp year];
	
	info.hour = [comp hour];
	info.minute = [comp minute];
	info.second = [comp second];
	
	info.weekday = [comp weekday];
	
	return info;
}
- (DateInformation) dateInformation{
	
	DateInformation info;
		NSDateComponents *comp = [gregorianCalendar() components:(NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit |
													NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit) 
										  fromDate:self];
	info.day = [comp day];
	info.month = [comp month];
	info.year = [comp year];
	
	info.hour = [comp hour];
	info.minute = [comp minute];
	info.second = [comp second];
	
	info.weekday = [comp weekday];
	
    
	return info;
}
+ (NSDate*) dateFromDateInformation:(DateInformation)info timeZone:(NSTimeZone*)tz{
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone:tz];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
	
	[comp setDay:info.day];
	[comp setMonth:info.month];
	[comp setYear:info.year];
	[comp setHour:info.hour];
	[comp setMinute:info.minute];
	[comp setSecond:info.second];
	[comp setTimeZone:tz];
	
	return [gregorian dateFromComponents:comp];
}
+ (NSDate*) dateFromDateInformation:(DateInformation)info{
	
	NSDateComponents *comp = [gregorianCalendar() components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
	
	[comp setDay:info.day];
	[comp setMonth:info.month];
	[comp setYear:info.year];
	[comp setHour:info.hour];
	[comp setMinute:info.minute];
	[comp setSecond:info.second];
	//[comp setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	return [gregorianCalendar() dateFromComponents:comp];
}

+ (NSString*) dateInformationDescriptionWithInformation:(DateInformation)info{
	return [NSString stringWithFormat:@"%d %d %d %d:%d:%d",info.month,info.day,info.year,info.hour,info.minute,info.second];
}

@end
