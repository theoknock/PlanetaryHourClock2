//
//  ComplicationController.m
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/17/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "ComplicationController.h"
#import "ExtensionDelegate.h"
#import "PlanetaryHourDataSource.h"


@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionNone);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
//    handler([PlanetaryHourDataSource.sharedDataSource solarTransits]([NSDate date], PlanetaryHourDataSource.sharedDataSource.locationManager.location)[Sunrise]);
    handler(nil);
}

- (NSDate *)nextSunriseAfterDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    NSDate *tomorrow = [calendar dateByAddingComponents:components toDate:date options:NSCalendarMatchNextTimePreservingSmallerUnits];
    NSDate *nextSunrise = [PlanetaryHourDataSource.sharedDataSource solarTransits](tomorrow, PlanetaryHourDataSource.sharedDataSource.locationManager.location)[Sunrise];
    
    return nextSunrise;
}

- (void)scheduleComplicationTimelineUpdateBackgroundTask:(NSDate *)date
{
    NSDate *nextSunriseAfterDate = [self nextSunriseAfterDate:date];
    [[WKExtension sharedExtension] scheduleBackgroundRefreshWithPreferredDate:nextSunriseAfterDate userInfo:nil scheduledCompletion:^(NSError * _Nullable error) {
        [[[CLKComplicationServer sharedInstance] activeComplications] enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:obj];
            
            NSDate *SunriseAfterNextSunriseAfterDate = [self nextSunriseAfterDate:nextSunriseAfterDate];
            
            
            [[WKExtension sharedExtension] scheduleBackgroundRefreshWithPreferredDate:SunriseAfterNextSunriseAfterDate userInfo:nil scheduledCompletion:^(NSError * _Nullable error) {
                [[[CLKComplicationServer sharedInstance] activeComplications] enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:obj];
                }];
            }];
            
        }];
        if (error)
            NSLog(@"Scheduled background timeline reload for complication error: %@", error.description);
    }];
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler(nil);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Templates

CLKComplicationTemplateModularLargeTallBody *(^complicationTemplateModularLargeTallBody)(NSString *, NSString *, UIColor *) = ^(NSString *headerText, NSString *bodyText, UIColor *tint)
{
    CLKComplicationTemplateModularLargeTallBody *template = [[CLKComplicationTemplateModularLargeTallBody alloc] init];
    template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:headerText];
    template.bodyTextProvider = [CLKSimpleTextProvider textProviderWithText:bodyText];
    template.tintColor = tint;
    
    return template;
};

CLKComplicationTemplateModularLargeTable *(^complicationTemplateModularLargeTable)(NSString *, NSString *, NSString *, NSString *, NSString *, UIColor *) = ^(NSString *text, NSString *row1Column1TextProvider, NSString *row1Column2TextProvider, NSString *row2Column1TextProvider, NSString *row2Column2TextProvider, UIColor *color)
{
    CLKComplicationTemplateModularLargeTable *template = [[CLKComplicationTemplateModularLargeTable alloc] init];
    template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:text];
    template.row1Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:row1Column1TextProvider];
    template.row1Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:row1Column2TextProvider];
    template.row2Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:row2Column1TextProvider];
    template.row2Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:row2Column2TextProvider];
    template.tintColor = color;
    //    template.headerImageProvider...
    
    return template;
};

CLKComplicationTemplateModularSmallSimpleText *(^complicationTemplateModularSmallSimpleText)(NSString *, UIColor *) = ^(NSString *text, UIColor *tint)
{
    CLKComplicationTemplateModularSmallSimpleText *template = [[CLKComplicationTemplateModularSmallSimpleText alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:text];
    template.tintColor = tint;
    
    return template;
};


CLKComplicationTemplateUtilitarianLargeFlat *(^complicationTemplateUtilitarianLargeFlat)(NSString *, UIColor *) = ^(NSString *text, UIColor *tint)
{
    CLKComplicationTemplateUtilitarianLargeFlat *template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:text];
    template.tintColor = tint;
    
    return template;
};

CLKComplicationTemplateUtilitarianSmallFlat *(^complicationTemplateUtilitarianSmallFlat)(NSString *, UIColor *) = ^(NSString *text, UIColor *tint)
{
    CLKComplicationTemplateUtilitarianSmallFlat *template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:text];
    template.tintColor = tint;
    
    return template;
};

CLKComplicationTemplateExtraLargeSimpleText *(^complicationTemplateExtraLargeSimpleText)(NSString *, UIColor *) = ^(NSString *text, UIColor *tint)
{
    CLKComplicationTemplateExtraLargeSimpleText *template = [[CLKComplicationTemplateExtraLargeSimpleText alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:text];
    template.tintColor = tint;
    
    return template;
};

CLKComplicationTemplateCircularSmallSimpleText *(^complicationTemplateCircularSmallSimpleText)(NSString *, UIColor *) = ^(NSString *text, UIColor *tint)
{
    CLKComplicationTemplateCircularSmallSimpleText *template = [[CLKComplicationTemplateCircularSmallSimpleText alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:text] ;
    template.tintColor = tint;
    
    return template;
};

CLKComplicationTemplateCircularSmallStackText *(^complicationTemplateCircularSmallStackText)(NSString *, NSString *) = ^(NSString *line1textProvider, NSString *line2TextProvider)
{
    CLKComplicationTemplateCircularSmallStackText *template = [[CLKComplicationTemplateCircularSmallStackText alloc] init];
    template.line1TextProvider = [CLKSimpleTextProvider textProviderWithText:line1textProvider];
    template.line2TextProvider = [CLKSimpleTextProvider textProviderWithText:line2TextProvider];
    
    return template;
};

CLKComplicationTemplateExtraLargeRingImage *(^complicationTemplateExtraLargeRingImage)(NSString *, CLKComplicationRingStyle, float, UIColor *) = ^(NSString *text, CLKComplicationRingStyle ringStyle, float fillFraction, UIColor *color)
{
    CLKComplicationTemplateExtraLargeRingImage *template = [[CLKComplicationTemplateExtraLargeRingImage alloc] init];
    template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[[PlanetaryHourDataSource sharedDataSource] imageFromText](text, color, 72.0)];
    template.ringStyle = ringStyle;
    template.fillFraction = fillFraction;
    template.tintColor = color;
    
    return template;
};

CLKComplicationTemplateModularSmallRingText *(^complicationTemplateModularSmallRingText)(NSString *, CLKComplicationRingStyle, float)  = ^(NSString *text, CLKComplicationRingStyle ringStyle, float fillFraction)
{
    CLKComplicationTemplateModularSmallRingText *template = [[CLKComplicationTemplateModularSmallRingText alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:text];
    template.ringStyle    = ringStyle;
    template.fillFraction = fillFraction;
    
    return template;
};

CLKComplicationTemplateGraphicCornerGaugeText *(^complicationTemplateGraphicCornerGaugeText)(NSString *, UIColor *, NSNumber *, NSDate *, NSDate *) = ^(NSString *symbol, UIColor *tintColor, NSNumber *hour, NSDate *startDate, NSDate *endDate)
{
    CLKComplicationTemplateGraphicCornerGaugeText *template = [[CLKComplicationTemplateGraphicCornerGaugeText alloc] init];
    
    Planet leadingPlanet           = (Planet)([[PlanetaryHourDataSource sharedDataSource] planetForPlanetSymbol](symbol) + 1) % NUMBER_OF_PLANETS;
    NSString *leadingPlanetSymbol  = [[PlanetaryHourDataSource sharedDataSource] planetSymbolForPlanet](leadingPlanet);
    UIColor *leadingPlanetColor    = [[PlanetaryHourDataSource sharedDataSource] colorForPlanetSymbol](leadingPlanetSymbol);
    
    Planet trailingPlanet          = (Planet)([[PlanetaryHourDataSource sharedDataSource] planetForPlanetSymbol](symbol) + 6) % NUMBER_OF_PLANETS;
    NSString *trailingPlanetSymbol = [[PlanetaryHourDataSource sharedDataSource] planetSymbolForPlanet](trailingPlanet);
    UIColor *trailingPlanetColor   = [[PlanetaryHourDataSource sharedDataSource] colorForPlanetSymbol](trailingPlanetSymbol);
    
    NSDate *earlierDate            = [startDate earlierDate:endDate];
    NSDate *laterDate              = ([earlierDate isEqualToDate:startDate]) ? endDate : startDate;
    
    template.outerTextProvider    = [CLKSimpleTextProvider textProviderWithText:symbol];
    template.tintColor            = tintColor;
    template.trailingTextProvider  = [CLKSimpleTextProvider textProviderWithText:leadingPlanetSymbol];
    template.leadingTextProvider = [CLKSimpleTextProvider textProviderWithText:trailingPlanetSymbol];
    template.gaugeProvider        = [CLKTimeIntervalGaugeProvider gaugeProviderWithStyle:CLKGaugeProviderStyleRing gaugeColors:@[trailingPlanetColor, tintColor, leadingPlanetColor] gaugeColorLocations:@[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0]] startDate:earlierDate startFillFraction:0.0 endDate:laterDate endFillFraction:1.0];
    
    return template;
};

CLKComplicationTemplateGraphicCircularOpenGaugeImage *(^complicationTemplateGraphicCircularOpenGaugeImage)(NSString *, UIColor *, NSNumber *, NSDate *, NSDate *, NSArray<UIColor *> *, NSArray<NSNumber *> *, CLKGaugeProviderStyle) = ^(NSString *symbol, UIColor *color, NSNumber *hour, NSDate *startDate, NSDate *endDate, NSArray<UIColor *> *gaugeColors, NSArray<NSNumber *> *gaugeColorLocations, CLKGaugeProviderStyle style)
{
    CLKComplicationTemplateGraphicCircularOpenGaugeImage *template = [[CLKComplicationTemplateGraphicCircularOpenGaugeImage alloc] init];
    template.centerTextProvider  = [CLKSimpleTextProvider textProviderWithText:symbol];
    template.bottomImageProvider = [CLKFullColorImageProvider providerWithFullColorImage:[[PlanetaryHourDataSource sharedDataSource] imageFromText]([NSString stringWithFormat:@"%ld", hour.longValue], color, 9.0)];
    template.gaugeProvider       = [CLKTimeIntervalGaugeProvider gaugeProviderWithStyle:style gaugeColors:gaugeColors gaugeColorLocations:gaugeColorLocations startDate:startDate endDate:endDate];
    
    return template;
};

CLKComplicationTemplateGraphicCircularOpenGaugeRangeText *(^complicationTemplateGraphicCircularOpenGaugeRangeText)(NSString *, UIColor *, NSNumber *, NSDate *, NSDate *) = ^(NSString *symbol, UIColor *tintColor, NSNumber *hour, NSDate *startDate, NSDate *endDate)
{
    CLKComplicationTemplateGraphicCircularOpenGaugeRangeText *template = [[CLKComplicationTemplateGraphicCircularOpenGaugeRangeText alloc] init];
    Planet leadingPlanet           = (Planet)([[PlanetaryHourDataSource sharedDataSource] planetForPlanetSymbol](symbol) + 1) % NUMBER_OF_PLANETS;
    NSString *leadingPlanetSymbol  = [[PlanetaryHourDataSource sharedDataSource] planetSymbolForPlanet](leadingPlanet);
    UIColor *leadingPlanetColor    = [[PlanetaryHourDataSource sharedDataSource] colorForPlanetSymbol](leadingPlanetSymbol);
    
    Planet trailingPlanet          = (Planet)([[PlanetaryHourDataSource sharedDataSource] planetForPlanetSymbol](symbol) + 6) % NUMBER_OF_PLANETS;
    NSString *trailingPlanetSymbol = [[PlanetaryHourDataSource sharedDataSource] planetSymbolForPlanet](trailingPlanet);
    UIColor *trailingPlanetColor   = [[PlanetaryHourDataSource sharedDataSource] colorForPlanetSymbol](trailingPlanetSymbol);
    
    NSDate *earlierDate            = [startDate earlierDate:endDate];
    NSDate *laterDate              = ([earlierDate isEqualToDate:startDate]) ? endDate : startDate;
    
    template.centerTextProvider   = [CLKSimpleTextProvider textProviderWithText:symbol];
    template.tintColor            = tintColor;
    template.trailingTextProvider  = [CLKSimpleTextProvider textProviderWithText:leadingPlanetSymbol];
    template.leadingTextProvider = [CLKSimpleTextProvider textProviderWithText:trailingPlanetSymbol];
    template.gaugeProvider        = [CLKTimeIntervalGaugeProvider gaugeProviderWithStyle:CLKGaugeProviderStyleRing gaugeColors:@[trailingPlanetColor, tintColor, leadingPlanetColor] gaugeColorLocations:@[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0]] startDate:earlierDate startFillFraction:0.0 endDate:laterDate endFillFraction:1.0];
    
    return template;
};

CLKComplicationTemplate *(^templateForComplication)(CLKComplicationFamily, NSDictionary *) = ^(CLKComplicationFamily family, NSDictionary *data) {
    CLKComplicationTemplate *template = nil;
    
    switch (family) {
        case CLKComplicationFamilyModularLarge:
        {
            long hour = [(NSNumber *)[data objectForKey:@"hour"] longValue] + 1;
            NSString *hourString = [NSString stringWithFormat:@"Hour %lu", hour];
            
            NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
            startDateFormatter.timeStyle        = NSDateFormatterShortStyle;
            NSString *startDateString           = [startDateFormatter stringFromDate:[data objectForKey:@"start"]];
            
            NSDateFormatter *endDateFormatter   = [[NSDateFormatter alloc] init];
            endDateFormatter.timeStyle          = NSDateFormatterShortStyle;
            NSString *endDateString             = [endDateFormatter stringFromDate:[data objectForKey:@"end"]];
            
            template = complicationTemplateModularLargeTable([data objectForKey:@"symbol"], [data objectForKey:@"name"], hourString, startDateString, endDateString, [data objectForKey:@"color"]);
            //            template = complicationTemplateModularLargeTallBody([data objectForKey:@"symbol"], [data objectForKey:@"name"], [data objectForKey:@"color"]);
            break ;
        }
        case CLKComplicationFamilyModularSmall:
        {
            template = complicationTemplateModularSmallSimpleText([data objectForKey:@"symbol"], [data objectForKey:@"color"]);
            //            template = [self complicationTemplateModularSmallRingText];
            break ;
        }
        case CLKComplicationFamilyUtilitarianLarge:
        {
            template = complicationTemplateUtilitarianLargeFlat([data objectForKey:@"symbol"], [data objectForKey:@"color"]);
            break;
        }
        case CLKComplicationFamilyUtilitarianSmall:
        {
            template = complicationTemplateUtilitarianSmallFlat([data objectForKey:@"symbol"], [data objectForKey:@"color"]);
            break;
        }
        case CLKComplicationFamilyExtraLarge:
        {
            //            template = complicationTemplateExtraLargeSimpleText([data objectForKey:@"symbol"], [data objectForKey:@"color"]);
            long hour = [(NSNumber *)[data objectForKey:@"hour"] longValue] + 1;
            float dayExpiry = ((hour * 60) * 60) / SECONDS_PER_DAY;
            template = complicationTemplateExtraLargeRingImage([data objectForKey:@"symbol"], CLKComplicationRingStyleOpen, dayExpiry, [data objectForKey:@"color"]);
            break;
        }
        case CLKComplicationFamilyCircularSmall:
        {
            template = complicationTemplateCircularSmallSimpleText([data objectForKey:@"symbol"], [data objectForKey:@"color"]);
            //            template = [self complicationTemplateCircularSmallStackText];
            break;
        }
        case CLKComplicationFamilyGraphicCorner:
        {
            template = complicationTemplateGraphicCornerGaugeText([data objectForKey:@"symbol"], [data objectForKey:@"color"], [data objectForKey:@"hour"], [data objectForKey:@"start"], [data objectForKey:@"end"]);
            break;
        }
        case CLKComplicationFamilyGraphicCircular:
        {
            template = complicationTemplateGraphicCircularOpenGaugeRangeText([data objectForKey:@"symbol"], [data objectForKey:@"color"], [data objectForKey:@"hour"], [data objectForKey:@"start"], [data objectForKey:@"end"]);
            break;
        }
        default:
        {
            break;
        }
    }
    
    return template;
};

#pragma mark - Placeholder templates

CLKComplicationTemplate *(^placeholderTemplate)(CLKComplication *) = ^(CLKComplication *complication)
{
    NSNumber *hour = [NSNumber numberWithInteger:0];
    NSString *hourString = [NSString stringWithFormat:@"Hour %@", hour];
    NSArray<NSDate *> *solarTransits = [PlanetaryHourDataSource.sharedDataSource solarTransits]([NSDate date], PlanetaryHourDataSource.sharedDataSource.locationManager.location);
    CLKComplicationTemplate *template = templateForComplication(complication.family,
                                                                [PlanetaryHourDataSource.sharedDataSource planetaryHourData](@"㊏", @"Earth", hour, hourString, solarTransits[Sunrise], solarTransits[Sunset], [UIColor greenColor]));
    
    return template;
};

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler
{
    handler(placeholderTemplate(complication));
}

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler
{
    [self scheduleComplicationTimelineUpdateBackgroundTask:[NSDate date]];
    handler(placeholderTemplate(complication));
}

#pragma mark - Timeline entries

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    __block CLKComplicationTemplate *template = nil;
    PlanetaryHourDataSource.sharedDataSource.planetaryHours(PlanetaryHourDataSource.sharedDataSource.locationManager.location, [NSDate date], ^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSString * _Nonnull abbr, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, UIColor * _Nonnull color, CLLocation * _Nonnull location, CLLocationDistance distance, BOOL current) {
        NSDateInterval *dateInterval = [[NSDateInterval alloc] initWithStartDate:startDate endDate:endDate];
        if ([dateInterval containsDate:[NSDate date]])
        {
            template = templateForComplication(complication.family,
                                               [PlanetaryHourDataSource.sharedDataSource planetaryHourData]([symbol string], name, [NSNumber numberWithInteger:hour], abbr, startDate, endDate, color));
            CLKComplicationTimelineEntry *tle = [CLKComplicationTimelineEntry entryWithDate:startDate complicationTemplate:template] ;
            handler(tle);
            
//            if (hour == 23)
//                [[[CLKComplicationServer sharedInstance] activeComplications] enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    [[CLKComplicationServer sharedInstance] extendTimelineForComplication:obj];
//                }];
        }
    });
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void (^)(NSArray<CLKComplicationTimelineEntry *> * _Nullable))handler
{
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler
{
//    __block NSMutableArray *entries = [NSMutableArray arrayWithCapacity:limit];
//    __block CLKComplicationTemplate *template = nil;
//
//    NSUInteger days = (NSUInteger)(limit % HOURS_PER_DAY);
//    for (int day = 0; day < days; day++)
//    {
//        NSDate *dateIntervalStart = [date dateByAddingTimeInterval:day * SECONDS_PER_DAY];
////        NSLog(@"Day %d of %d: %@", day, days, dateIntervalStart);
//        NSDateInterval *dateInterval = [[NSDateInterval alloc] initWithStartDate:dateIntervalStart endDate:[NSDate distantFuture]];
//        PlanetaryHourDataSource.sharedDataSource.planetaryHours(PlanetaryHourDataSource.sharedDataSource.locationManager.location, dateIntervalStart, ^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSString * _Nonnull abbr, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, UIColor * _Nonnull color, CLLocation * _Nonnull location, CLLocationDistance distance, BOOL current) {
//            if ([dateInterval containsDate:startDate] && entries.count < limit)
//            {
//                template = templateForComplication(complication.family,
//                                                  [PlanetaryHourDataSource.sharedDataSource planetaryHourData]([symbol string], name, [NSNumber numberWithInteger:hour], abbr, startDate, endDate, color));
//                CLKComplicationTimelineEntry *tle = [CLKComplicationTimelineEntry entryWithDate:startDate complicationTemplate:template] ;
//                [entries addObject:tle];
//            }
//        });
//    }
//
//    handler(entries);
    
    handler(nil);
}

@end






