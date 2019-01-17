//
//  ComplicationController.m
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/17/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "ComplicationController.h"
#import "PlanetaryHourDataSource.h"


@interface ComplicationController () {
    NSMutableDictionary<NSNumber *, CLKComplicationTemplate *> *templates ;
}

@end

@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionForward|CLKComplicationTimeTravelDirectionBackward);
}

- (NSDate *)toLocalTime:(NSDate *)date
{
    NSCalendar *calendar             = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [calendar componentsInTimeZone:[NSTimeZone systemTimeZone] fromDate:date];
    dateComponents.timeZone          = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    dateComponents.calendar          = calendar;
    NSDate *currentTime              = [calendar dateFromComponents:dateComponents];

    return currentTime;
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    // The sunrise/sunset dates may not have the time zone information in them
    NSDate *startDate = [self toLocalTime:[PlanetaryHourDataSource.sharedDataSource solarCalculationForDate:nil location:nil].sunrise];
    
    handler(startDate);
    NSLog(@"Timeline start date\t%@", [startDate description]);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    NSDate *endDate = [self toLocalTime:[PlanetaryHourDataSource.sharedDataSource solarCalculationForDate:nil location:nil].sunset];
    handler(endDate);
    NSLog(@"Timeline end date\t%@", [endDate description]);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
//    dispatch_block_t locate;
//    __block dispatch_block_t validateLocation = ^(void) {
//        if (!CLLocationCoordinate2DIsValid([[[[PlanetaryHourDataSource sharedDataSource] locationManager] location] coordinate]))
//        {
//            locate();
//        }
//    };
//    
//    locate = ^(void) {
//        [[[PlanetaryHourDataSource sharedDataSource] locationManager] requestLocation];
//        validateLocation();
//    };
//    
//    locate();
//    
    
    CLKComplicationTemplate *template = [self templateForeComplication:complication] ;
    if (template) {
        [PlanetaryHourDataSource.sharedDataSource planetaryHour:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, BOOL current) {
            NSLog(@"Timeline dates for current complication\t%@ - \t\t%@ (%@)", [[self toLocalTime:startDate] description], [[self toLocalTime:endDate] description], [[self toLocalTime:[NSDate date]] description]);
            switch (complication.family) {
                case CLKComplicationFamilyModularLarge:
                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).headerTextProvider).text = name;
                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).bodyTextProvider).text = [symbol string];
                    break ;
                case CLKComplicationFamilyModularSmall:
                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularSmallSimpleText *)template).textProvider).text = [symbol string];
                    break ;
                case CLKComplicationFamilyUtilitarianLarge:
                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateUtilitarianLargeFlat *)template).textProvider).text = [symbol string];
                    break ;
                case CLKComplicationFamilyUtilitarianSmall:
                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateUtilitarianSmallFlat *)template).textProvider).text = [symbol string];
                    break ;
                case CLKComplicationFamilyExtraLarge:
                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateExtraLargeSimpleText *)template).textProvider).text = [symbol string];
                    break;
                case CLKComplicationFamilyCircularSmall:
                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateCircularSmallRingText *)template).textProvider).text = [symbol string];
                    break;
                default:
                    break ;
            }
            CLKComplicationTimelineEntry *tle = [CLKComplicationTimelineEntry entryWithDate:[self toLocalTime:startDate] complicationTemplate:template] ;
            handler(tle);
        }];
    }
}

//- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
//    [PlanetaryHourDataSource.sharedDataSource planetaryHours:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, BOOL current) {
////        if (complication.family == CLKComplicationFamilyModularLarge)
////        {
////            CLKComplicationTemplateModularLargeTallBody *tallBody = [CLKComplicationTemplateModularLargeTallBody new];
////            tallBody.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:name];
////            tallBody.bodyTextProvider = [CLKSimpleTextProvider textProviderWithText:[symbol string]];
////            CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:tallBody];
////            handler(entry);
////        } else
//        if (complication.family == CLKComplicationFamilyExtraLarge)
//        {
//            CLKComplicationTemplateModularLargeStandardBody *standardBody = [CLKComplicationTemplateModularLargeStandardBody new];
//            standardBody.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:name];
//            standardBody.body1TextProvider = [CLKSimpleTextProvider textProviderWithText:[symbol string]];
//            standardBody.body2TextProvider = [CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:@"Hour %ld", (long)hour]];
//            CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:standardBody];
//            handler(entry);
//        }
//    }];
//    // Call the handler with the current timeline entry
//    //    [PlanetaryHourDataSource.sharedDataSource planetaryHours:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, BOOL current) {
//    //    CLKSimpleTextProvider *planetaryHourTextProvider;
//    //        [planetaryHourTextProvider setText:name];
//    //        [planetaryHourTextProvider setShortText:[symbol string]];
//    //        [self getLocalizableSampleTemplateForComplication:complication withHandler:^(CLKComplicationTemplate * _Nullable complicationTemplate) {
//    //            [(CLKComplicationTemplateModularLargeStandardBody *)complicationTemplate setHeaderTextProvider:[CLKSimpleTextProvider textProviderWithText:@"S"]];
//    //            CLKComplicationTimelineEntry *currentPlanetaryHourTimelineEntry = [CLKComplicationTimelineEntry entryWithDate:startDate complicationTemplate:complicationTemplate];
//    //            handler(currentPlanetaryHourTimelineEntry);
//    //            NSLog(@"Symbol\t%@", [symbol string]);
//    //        }];
//    //    }];
//}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries prior to the given date
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after the given date
//    NSMutableArray *entries = [NSMutableArray arrayWithCapacity:limit];
//    [PlanetaryHourDataSource.sharedDataSource planetaryHours:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, BOOL current) {
//        if (!current && entries.count < limit)
//        {
//            NSLog(@"Not current; entries == %lu", (unsigned long)entries.count);
//            CLKComplicationTemplate *template = [self templateForeComplication:complication] ;
//            if (template) {
//                switch (complication.family) {
//                    case CLKComplicationFamilyModularLarge:
//                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).headerTextProvider).text = name;
//                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).bodyTextProvider).text = [symbol string];
//                        break ;
//                    case CLKComplicationFamilyModularSmall:
//                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularSmallSimpleText *)template).textProvider).text = [symbol string];
//                        break ;
//                    case CLKComplicationFamilyUtilitarianLarge:
//                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateUtilitarianLargeFlat *)template).textProvider).text = [symbol string];
//                        break ;
//                    case CLKComplicationFamilyUtilitarianSmall:
//                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateUtilitarianSmallFlat *)template).textProvider).text = [symbol string];
//                        break ;
//                    case CLKComplicationFamilyExtraLarge:
//                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateExtraLargeSimpleText *)template).textProvider).text = [symbol string];
//                        break;
//                    case CLKComplicationFamilyCircularSmall:
//                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateCircularSmallRingText *)template).textProvider).text = [symbol string];
//                        break;
//                    default:
//                        break ;
//                }
//                CLKComplicationTimelineEntry *tle = [CLKComplicationTimelineEntry entryWithDate:startDate complicationTemplate:template] ;
//                [entries addObject:tle];
//            }
//        } else if (entries.count == (limit - 1))
//        {
//            NSLog(@"Reached limit");
//            handler(entries);
//        }
//        
//        
//    }];
    handler(nil);
}

#pragma mark - Placeholder Templates

- (CLKComplicationTemplateModularLargeTallBody *)complicationTemplateModularLargeTallBody {
    CLKComplicationTemplateModularLargeTallBody *template = [[CLKComplicationTemplateModularLargeTallBody alloc] init] ;
    template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.bodyTextProvider = [CLKSimpleTextProvider textProviderWithText:@"Earth"] ;
    template.tintColor = [UIColor yellowColor] ;
    return template ;
}

- (CLKComplicationTemplateModularSmallSimpleText *)complicationTemplateModularSmallSimpleText {
    CLKComplicationTemplateModularSmallSimpleText *template = [[CLKComplicationTemplateModularSmallSimpleText alloc] init] ;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor] ;
    return template ;
}


- (CLKComplicationTemplateUtilitarianLargeFlat *)complicationTemplateUtilitarianLargeFlat {
    CLKComplicationTemplateUtilitarianLargeFlat *template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init] ;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor] ;
    return template ;
}

- (CLKComplicationTemplateUtilitarianSmallFlat *)complicationTemplateUtilitarianSmallFlat {
    CLKComplicationTemplateUtilitarianSmallFlat *template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor] ;
    return template ;
}

- (CLKComplicationTemplateExtraLargeSimpleText *)complicationTemplateModularLargeSimpleText {
    CLKComplicationTemplateExtraLargeSimpleText *template = [[CLKComplicationTemplateExtraLargeSimpleText alloc] init] ;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor] ;
    return template ;
}

- (CLKComplicationTemplateCircularSmallRingText *)complicationTemplateCircularSmallRingText {
    CLKComplicationTemplateCircularSmallRingText *template = [[CLKComplicationTemplateCircularSmallRingText alloc] init] ;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor] ;
    return template ;
}


- (CLKComplicationTemplate *)templateForeComplication:(CLKComplication *)complication {
    CLKComplicationTemplate *template = nil ;
    
    if (!templates) {
        templates = [NSMutableDictionary dictionary] ;
    }
    
    NSNumber *family = [NSNumber numberWithInt:complication.family] ;
    if (family) {
        template = [templates objectForKey:family] ;
    } else {
        return nil ;
    }
    
    if (template) {
        return template ;
    }
    
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
            template = [self complicationTemplateModularLargeTallBody] ;
            break ;
        case CLKComplicationFamilyModularSmall:
            template = [self complicationTemplateModularSmallSimpleText] ;
            break ;
        case CLKComplicationFamilyUtilitarianLarge:
            template = [self complicationTemplateUtilitarianLargeFlat] ;
            break ;
        case CLKComplicationFamilyUtilitarianSmall:
            template = [self complicationTemplateUtilitarianSmallFlat];
            break;
        case CLKComplicationFamilyExtraLarge:
            template = [self complicationTemplateModularLargeSimpleText];
            break;
        case CLKComplicationFamilyCircularSmall:
            template = [self complicationTemplateCircularSmallRingText];
            break;
        default:
            break ;
    }
    
    if (template) {
        [templates setObject:template forKey:family] ;
    }
    
    return template ;
}

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler
{
    [PlanetaryHourDataSource.sharedDataSource setDelegate:(id<PlanetaryHourDataSourceDelegate> _Nullable)self];
    
    CLKComplicationTemplate *template = [self templateForeComplication:complication] ;
    handler(template) ;
}

- (void)updateComplicationTimelines
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[CLKComplicationServer sharedInstance] activeComplications] enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:obj];
        }];
    });
}

//- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler
//{
//    if (complication.family == CLKComplicationFamilyModularLarge)
//    {
//        CLKComplicationTemplateModularLargeTallBody *tallBody = [CLKComplicationTemplateModularLargeTallBody new];
//        tallBody.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"S"];
//        tallBody.bodyTextProvider = [CLKSimpleTextProvider textProviderWithText:@"Symbol"];
//        handler(tallBody);
//    } else if (complication.family == CLKComplicationFamilyExtraLarge)
//    {
//        CLKComplicationTemplateModularLargeStandardBody *standardBody = [CLKComplicationTemplateModularLargeStandardBody new];
//        standardBody.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"S"];
//        standardBody.body1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Symbol"];
//        standardBody.body2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Hour"];
//        handler(standardBody);
//    }
//}
//
//- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
//    // This method will be called once per supported complication, and the results will be cached
//    //    switch (complication.family) {
//    //        case CLKComplicationFamilyModularSmall:
//    //        {
//    //            CLKSimpleTextProvider *textProvider = [CLKSimpleTextProvider localizableTextProviderWithStringsFileTextKey:@"headerTextProvider"];
//    //            CLKComplicationTemplateModularSmallSimpleText *template = [[CLKComplicationTemplateModularSmallSimpleText alloc] init];
//    //            [template setTextProvider:textProvider];
//    //            handler(template);
//    //            break;
//    //        }
//    //        case CLKComplicationFamilyModularLarge:
//    //        {
//    //            CLKSimpleTextProvider *headerTextProvider = [CLKSimpleTextProvider localizableTextProviderWithStringsFileTextKey:@"headerTextProvider"];
//    //            CLKSimpleTextProvider *body1TextProvider = [CLKSimpleTextProvider localizableTextProviderWithStringsFileTextKey:@"body1TextProvider"];
//    //            CLKSimpleTextProvider *body2TextProvider = [CLKSimpleTextProvider localizableTextProviderWithStringsFileTextKey:@"body2TextProvider"];
//    //            CLKComplicationTemplateModularLargeStandardBody *template = [[CLKComplicationTemplateModularLargeStandardBody alloc] init];
//    //            [template setHeaderTextProvider:headerTextProvider];
//    //            [template setBody1TextProvider:body1TextProvider];
//    //            [template setBody2TextProvider:body2TextProvider];
//    //            handler(template);
//    //            break;
//    //        }
//    //        default:
//    //        {
//    //            CLKComplicationTemplate *template = [CLKComplicationTemplate new];
//    //            handler(template);
//    //        }
//    //            break;
//    //    }
//
//    handler(nil);
//}

@end



