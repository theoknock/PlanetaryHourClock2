//
//  ComplicationController.m
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/17/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "ComplicationController.h"
#import "PlanetaryHourDataSource.h"


@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionForward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    NSDate *date = [NSDate date];
    NSArray<NSDate *> *solarTransits = [PlanetaryHourDataSource.sharedDataSource solarCalculationForDate:date location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
    NSLog(@"Timeline start date\t%@", [solarTransits[Sunrise] description]);
    
    handler(solarTransits[Sunrise]);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    NSDate *tomorrow = [calendar dateByAddingComponents:components toDate:date options:NSCalendarMatchNextTimePreservingSmallerUnits];
    NSArray<NSDate *> *nextSolarTransits = [PlanetaryHourDataSource.sharedDataSource solarCalculationForDate:tomorrow location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
    NSLog(@"Timeline end date\t%@", [nextSolarTransits[Sunrise] description]);
    
    handler(nextSolarTransits[Sunrise]);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Placeholder Templates

- (CLKComplicationTemplateModularLargeTallBody *)complicationTemplateModularLargeTallBody {
    CLKComplicationTemplateModularLargeTallBody *template = [[CLKComplicationTemplateModularLargeTallBody alloc] init] ;
    template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
    template.bodyTextProvider = [CLKSimpleTextProvider textProviderWithText:@"Earth"];
    template.tintColor = [UIColor yellowColor];
    return template ;
}

- (CLKComplicationTemplateModularSmallSimpleText *)complicationTemplateModularSmallSimpleText {
    CLKComplicationTemplateModularSmallSimpleText *template = [[CLKComplicationTemplateModularSmallSimpleText alloc] init] ;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor];
    return template ;
}


- (CLKComplicationTemplateUtilitarianLargeFlat *)complicationTemplateUtilitarianLargeFlat {
    CLKComplicationTemplateUtilitarianLargeFlat *template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init] ;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor];
    return template ;
}

- (CLKComplicationTemplateUtilitarianSmallFlat *)complicationTemplateUtilitarianSmallFlat {
    CLKComplicationTemplateUtilitarianSmallFlat *template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor];
    return template ;
}

- (CLKComplicationTemplateExtraLargeSimpleText *)complicationTemplateModularLargeSimpleText {
    CLKComplicationTemplateExtraLargeSimpleText *template = [[CLKComplicationTemplateExtraLargeSimpleText alloc] init] ;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor];
    return template ;
}

- (CLKComplicationTemplateCircularSmallSimpleText *)complicationTemplateCircularSmallSimpleText {
    CLKComplicationTemplateCircularSmallSimpleText *template = [[CLKComplicationTemplateCircularSmallSimpleText alloc] init] ;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor];
    return template ;
}

- (CLKComplicationTemplate *)templateForComplication:(CLKComplication *)complication {
    CLKComplicationTemplate *template = nil;
    
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
            template = [self complicationTemplateModularLargeTallBody];
            break ;
        case CLKComplicationFamilyModularSmall:
            template = [self complicationTemplateModularSmallSimpleText];
            break ;
        case CLKComplicationFamilyUtilitarianLarge:
            template = [self complicationTemplateUtilitarianLargeFlat];
            break ;
        case CLKComplicationFamilyUtilitarianSmall:
            template = [self complicationTemplateUtilitarianSmallFlat];
            break;
        case CLKComplicationFamilyExtraLarge:
            template = [self complicationTemplateModularLargeSimpleText];
            break;
        case CLKComplicationFamilyCircularSmall:
            template = [self complicationTemplateCircularSmallSimpleText];
            break;
        default:
            break;
    }
    
    return template;
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    CLKComplicationTemplate *template = [self templateForComplication:complication];
    if (template) {
        [PlanetaryHourDataSource.sharedDataSource currentPlanetaryHoursForLocation:PlanetaryHourDataSource.sharedDataSource.locationManager.location forDate:[NSDate date] completionBlock:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, UIColor *color, BOOL current) {
            NSDateInterval *dateInterval = [[NSDateInterval alloc] initWithStartDate:startDate endDate:endDate];
            if ([dateInterval containsDate:[NSDate date]])
            {
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
                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateCircularSmallSimpleText *)template).textProvider).text = [symbol string];
                        break;
                    default:
                        break ;
                }
                template.tintColor = color;
                
                CLKComplicationTimelineEntry *tle = [CLKComplicationTimelineEntry entryWithDate:startDate complicationTemplate:template] ;
                handler(tle);
                NSLog(@"Current planetary hour: %ld", (long)hour);
            }
        }];
    } else {
        handler(nil);
    }
}


- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    __block NSMutableArray *entries = [NSMutableArray arrayWithCapacity:limit];
    CLKComplicationTemplate *template = [self templateForComplication:complication];
    if (template) {
        NSLog(@"Template returned...");
        [self getTimelineEndDateForComplication:complication withHandler:^(NSDate * _Nullable timelineEndDate) {
            NSDateInterval *dateInterval = [[NSDateInterval alloc] initWithStartDate:date endDate:timelineEndDate];
            [PlanetaryHourDataSource.sharedDataSource currentPlanetaryHoursForLocation:PlanetaryHourDataSource.sharedDataSource.locationManager.location forDate:date completionBlock:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, UIColor *color, BOOL current) {
                NSLog(@"Getting planetary hour data %ld", (long)hour);
                if ([dateInterval containsDate:startDate] && entries.count < limit)
                {
                    NSLog(@"Adding as an entry %lu (count %lu of limit %lu)", (long)hour, (long)entries.count, (long)limit);
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
                            ((CLKSimpleTextProvider *)((CLKComplicationTemplateCircularSmallSimpleText *)template).textProvider).text = [symbol string];
                            break;
                        default:
                            break;
                    }
                    template.tintColor = color;
                    
                    CLKComplicationTimelineEntry *tle = [CLKComplicationTimelineEntry entryWithDate:startDate complicationTemplate:template] ;
                    [entries addObject:tle];
                    NSLog(@"Hour: %ld", (long)hour);
                    if (hour == 23) {
                        NSLog(@"Submitting %lu entries", (long)entries.count);
                        handler(entries);
                    }
                } else {
                    NSLog(@"Date %@ is not within date interval of %@ to %@", startDate.description, date.description, timelineEndDate.description);
                }
            }];
        }];
    } else {
        handler(nil);
    }
}

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler
{
    CLKComplicationTemplate *template = nil;
    
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
            template = [[CLKComplicationTemplateModularLargeTallBody alloc] init];
            ((CLKComplicationTemplateModularLargeTallBody *)template).headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            ((CLKComplicationTemplateModularLargeTallBody *)template).bodyTextProvider   = [CLKSimpleTextProvider textProviderWithText:@"Earth"];
            break;
        case CLKComplicationFamilyModularSmall:
            template = [[CLKComplicationTemplateModularSmallSimpleText alloc] init];
            ((CLKComplicationTemplateModularSmallSimpleText *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break;
        case CLKComplicationFamilyUtilitarianLarge:
            template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init] ;
            ((CLKComplicationTemplateUtilitarianLargeFlat *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break;
        case CLKComplicationFamilyUtilitarianSmall:
            template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
            ((CLKComplicationTemplateUtilitarianSmallFlat *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break;
        case CLKComplicationFamilyExtraLarge:
            template = [[CLKComplicationTemplateExtraLargeSimpleText alloc] init] ;
            ((CLKComplicationTemplateExtraLargeSimpleText *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break;
        case CLKComplicationFamilyCircularSmall:
            template = [[CLKComplicationTemplateCircularSmallSimpleText alloc] init] ;
            ((CLKComplicationTemplateCircularSmallSimpleText *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break;
        default:
            break;
    }
    
    if (template)
    {
        template.tintColor = [UIColor whiteColor];
        handler(template);
    } else {
        handler(nil);
    }
}

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler
{
    CLKComplicationTemplate *template = nil;
    
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
            template = [[CLKComplicationTemplateModularLargeTallBody alloc] init];
            ((CLKComplicationTemplateModularLargeTallBody *)template).headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            ((CLKComplicationTemplateModularLargeTallBody *)template).bodyTextProvider   = [CLKSimpleTextProvider textProviderWithText:@"Earth"];
            break ;
        case CLKComplicationFamilyModularSmall:
            template = [[CLKComplicationTemplateModularSmallSimpleText alloc] init];
            ((CLKComplicationTemplateModularSmallSimpleText *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break ;
        case CLKComplicationFamilyUtilitarianLarge:
            template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init] ;
            ((CLKComplicationTemplateUtilitarianLargeFlat *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break ;
        case CLKComplicationFamilyUtilitarianSmall:
            template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
            ((CLKComplicationTemplateUtilitarianSmallFlat *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break;
        case CLKComplicationFamilyExtraLarge:
            template = [[CLKComplicationTemplateExtraLargeSimpleText alloc] init] ;
            ((CLKComplicationTemplateExtraLargeSimpleText *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break;
        case CLKComplicationFamilyCircularSmall:
            template = [[CLKComplicationTemplateCircularSmallSimpleText alloc] init] ;
            ((CLKComplicationTemplateCircularSmallSimpleText *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break;
        default:
            break;
    }
    
    if (template)
    {
        template.tintColor = [UIColor whiteColor];
        handler(template);
    } else {
        handler(nil);
    }
}

@end




