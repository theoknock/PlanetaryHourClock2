//
//  TableInterfaceController.m
//  PlanetaryHour Extension
//
//  Created by Xcode Developer on 10/18/18.
//  Copyright © 2018 Xcode Developer. All rights reserved.
//

#import "TableInterfaceController.h"
#import "ExtensionDelegate.h"
#import "PlanetaryHourDataSource.h"
#import "PlanetaryHourRowController.h"
#import "NotificationController.h"

@interface TableInterfaceController ()

@property (strong, nonatomic) NSDateFormatter *timeFormatter;

@end

@implementation TableInterfaceController

- (IBAction)displayMap
{
    [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] switchControllers];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    self->_timeFormatter = [[NSDateFormatter alloc] init];
    self->_timeFormatter.dateStyle = NSDateFormatterNoStyle;
    self->_timeFormatter.timeStyle = NSDateFormatterShortStyle;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PlanetaryHoursDataSourceUpdatedNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self.planetaryHoursTable setNumberOfRows:24 withRowType:@"PlanetaryHoursTableRow"];
        PlanetaryHourDataSource.sharedDataSource.planetaryHours((CLLocation *)note.object, [NSDate date], ^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSString * _Nonnull abbr, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, UIColor * _Nonnull color, CLLocation * _Nonnull location, CLLocationDistance distance, BOOL current) {
            PlanetaryHourRowController* row = (PlanetaryHourRowController *)[self.planetaryHoursTable rowControllerAtIndex:hour];
            [row.symbolLabel setAttributedText:symbol];
            [row.planetLabel setText:name];
            [row.hourLabel setText:[NSString stringWithFormat:@"Hour %ld", (long)hour + 1]];
            
            NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
            startDateFormatter.timeStyle        = NSDateFormatterShortStyle;
            NSString *startDateString           = [startDateFormatter stringFromDate:startDate];
            [row.startDateLabel setText:startDateString];
            
            NSDateFormatter *endDateFormatter   = [[NSDateFormatter alloc] init];
            endDateFormatter.timeStyle          = NSDateFormatterShortStyle;
            NSString *endDateString             = [endDateFormatter stringFromDate:endDate];
            [row.endDateLabel setText:endDateString];
            
            if (current)
                [self.planetaryHoursTable scrollToRowAtIndex:hour];
            
            if (hour < 12)
                [row.rowGroup setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.25]];
            else
                [row.rowGroup setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.15]];
            
            if (!current)
            {
                [row.rowGroup setAlpha:0.5];
            }
        });
        
        [[[CLKComplicationServer sharedInstance] activeComplications] enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:obj];
        }];
    }];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

void (^addNotification)(NSDate *, NSString *, NSString *) = ^(NSDate *startTime, NSString *symbol, NSString *name)
{
    // User (local) notification
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title                         = symbol;
    content.subtitle                      = name;
    content.body                          = [NSString stringWithFormat:@"%@", startTime.description];
    content.categoryIdentifier            = [startTime description];
    
    NSDateComponents *dateComponents       = [[NSDateComponents alloc] init];
    dateComponents.calendar                = [NSCalendar currentCalendar];
    dateComponents.hour                    = [dateComponents.calendar component:NSCalendarUnitHour   fromDate:startTime];
    dateComponents.minute                  = [dateComponents.calendar component:NSCalendarUnitMinute fromDate:startTime];
    dateComponents.second                  = [dateComponents.calendar component:NSCalendarUnitSecond fromDate:startTime];
    dateComponents.month                   = [dateComponents.calendar component:NSCalendarUnitMonth  fromDate:startTime];
    dateComponents.day                     = [dateComponents.calendar component:NSCalendarUnitDay    fromDate:startTime];
    dateComponents.year                    = [dateComponents.calendar component:NSCalendarUnitYear   fromDate:startTime];
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:FALSE];
    
    NSString *uuidString = [startTime description];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:uuidString content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Notification added for %@", content.body);
        } else {
            NSLog(@"Error adding notification request to notification center:\t%@", error.description);
        }
    }];
    
};

//- (void)updateInterface
//{
////    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
////    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
////                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
////                              // Enable or disable features based on authorization.
////                              if (granted)
////                              {
//                                  [self.planetaryHoursTable setNumberOfRows:24 withRowType:@"PlanetaryHoursTableRow"];
//                                  [PlanetaryHourDataSource.sharedDataSource planetaryHours:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, BOOL current) {
//                                      PlanetaryHourRowController* row = (PlanetaryHourRowController *)[self.planetaryHoursTable rowControllerAtIndex:hour];
//                                      [row.symbolLabel setAttributedText:symbol];
//                                      [row.planetLabel setText:name];
//                                      [row.hourLabel setText:[NSString stringWithFormat:@"Hour %ld", (long)hour + 1]];
//                                      NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
//                                      startDateFormatter.dateFormat = @"HH:mm";
//                                      NSString *startDateString = [startDateFormatter stringFromDate:startDate];
//                                      [row.startDateLabel setText:startDateString];
//                                      NSDateFormatter *endDateFormatter = [[NSDateFormatter alloc] init];
//                                      endDateFormatter.dateFormat = @"HH:mm";
//                                      NSString *endDateString = [endDateFormatter stringFromDate:endDate];
//                                      [row.endDateLabel setText:endDateString];
//                                      if (current)
//                                          [self.planetaryHoursTable scrollToRowAtIndex:hour];
//
//                                      if (hour < 12)
//                                          [row.rowGroup setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.25]];
//                                      else
//                                          [row.rowGroup setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.15]];
//
//                                      if (!current)
//                                      {
//                                          [row.rowGroup setAlpha:0.5];
//                                      }
//
//                                      dispatch_async(PlanetaryHourDataSource.sharedDataSource.planetaryHourDataRequestQueue, ^{
//                                          addNotification(startDate, [symbol string], name);
//                                      });
//
////                                      UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
////                                      content.title                         = [symbol string];
////                                      content.subtitle                      = name;
////                                      content.body                          = [NSString stringWithFormat:@"%@\n%@", startDate.description, endDate.description];
////                                      content.categoryIdentifier            = @"PlanetaryHourNotification";
////
////                                      NSDateComponents *dateComponents       = [[NSDateComponents alloc] init];
////                                      dateComponents.calendar                = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
////                                      dateComponents.hour                    = [dateComponents.calendar component:NSCalendarUnitHour   fromDate:startDate];
////                                      dateComponents.minute                  = [dateComponents.calendar component:NSCalendarUnitMinute fromDate:startDate];
////                                      dateComponents.second                  = [dateComponents.calendar component:NSCalendarUnitSecond fromDate:startDate];
////                                      dateComponents.month                   = [dateComponents.calendar component:NSCalendarUnitMonth  fromDate:startDate];
////                                      dateComponents.day                     = [dateComponents.calendar component:NSCalendarUnitDay    fromDate:startDate];
////                                      dateComponents.year                    = [dateComponents.calendar component:NSCalendarUnitYear   fromDate:startDate];
////                                      UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:FALSE];
////
////                                      NSString *uuidString = [[NSDate date] description];
////
////                                      UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:uuidString content:content trigger:trigger];
////
////                                      [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
////                                          if (!error) {
//////                                              NSLog(@"Added notification request %ld to notification center for date %@", (long)hour, dateComponents.date);
////                                          } else {
////                                              NSLog(@"Error adding notification request to notification center:\t%@", error.description);
////                                          }
////                                      }];
//                                  }];
////                              }
////                          }];
////
////    NotificationController *nc = [[NotificationController alloc] init];
//
////            NSDate *nowDate   = [NSDate date];
////            [row.planetaryHourBeginLabel  setText:[self->_timeFormatter stringFromDate:startDate]];
////            [row.planetaryHourEndLabel    setText:[self->_timeFormatter stringFromDate:endDate]];
////            if ([[startDate earlierDate:nowDate] isEqualToDate:startDate])
////            {
////                [row.planetaryHourBeginLabel setTextColor:[UIColor redColor]];
////            } else {
////                [row.planetaryHourBeginLabel setTextColor:[UIColor greenColor]];
////            }
////
////            if (![[endDate earlierDate:nowDate] isEqualToDate:endDate])
////            {
////                [row.planetaryHourEndLabel setTextColor:[UIColor greenColor]];
////            } else {
////                [row.planetaryHourEndLabel setTextColor:[UIColor redColor]];
////            }
//
//            //            NSDateInterval *dateInterval = [[NSDateInterval alloc] initWithStartDate:(NSDate *)[(NSDictionary *)planetaryHours[i] objectForKeyedSubscript:@"PlanetaryHourBeginDataKey"] endDate:(NSDate *)[(NSDictionary *)planetaryHours[i] objectForKeyedSubscript:@"PlanetaryHourEndDataKey"]];
//            //            if ([dateInterval containsDate:[NSDate date]])
//            //            {
//            //                [row.rowGroup setBackgroundColor:[UIColor darkGrayColor]];
//            //            } else {
//            //                [row.rowGroup setBackgroundColor:[UIColor clearColor]];
//            //            }
//}

@end



