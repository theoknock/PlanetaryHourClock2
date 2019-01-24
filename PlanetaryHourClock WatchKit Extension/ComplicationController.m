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

//- (UIImage *)imageFromText:(NSString *)text
//{
//    NSMutableParagraphStyle *centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
//    centerAlignedParagraphStyle.alignment                = NSTextAlignmentCenter;
//    NSDictionary *centerAlignedTextAttributes            = @{NSForegroundColorAttributeName : [UIColor grayColor],
//                                                             NSFontAttributeName            : [UIFont systemFontOfSize:48.0 weight:UIFontWeightBold],
//                                                             NSParagraphStyleAttributeName  : centerAlignedParagraphStyle};
//
//    CGSize size = [text sizeWithAttributes:centerAlignedTextAttributes];
//    UIGraphicsBeginImageContext(size);
//    [text drawAtPoint:CGPointZero withAttributes:centerAlignedTextAttributes];
//
//    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    return image;
//}

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

CLKComplicationTemplateExtraLargeRingImage *(^complicationTemplateExtraLargeRingImage)(UIImage *, UIColor *) = ^(UIImage *image, UIColor *color)
{
    CLKComplicationTemplateExtraLargeRingImage *template = [[CLKComplicationTemplateExtraLargeRingImage alloc] init];
//    template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[self imageFromText:@"㊏"]];
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


- (CLKComplicationTemplate *)templateForComplication:(CLKComplicationFamily)family providerData:(NSDictionary *)data {
    CLKComplicationTemplate *template = nil;
    
    switch (family) {
        case CLKComplicationFamilyModularLarge:
            template = complicationTemplateModularLargeTable([data objectForKey:@"symbol"], [data objectForKey:@"name"], [data objectForKey:@"name"], [data objectForKey:@"name"], [data objectForKey:@"name"], [data objectForKey:@"color"]);
//            template = complicationTemplateModularLargeTallBody([data objectForKey:@"symbol"], [data objectForKey:@"name"], [data objectForKey:@"color"]);
            break ;
        case CLKComplicationFamilyModularSmall:
            template = complicationTemplateModularSmallSimpleText([data objectForKey:@"symbol"], [data objectForKey:@"color"]);
//            template = [self complicationTemplateModularSmallRingText];
            break ;
        case CLKComplicationFamilyUtilitarianLarge:
            template = complicationTemplateUtilitarianLargeFlat([data objectForKey:@"symbol"], [data objectForKey:@"color"]);
            break ;
        case CLKComplicationFamilyUtilitarianSmall:
            template = complicationTemplateUtilitarianSmallFlat([data objectForKey:@"symbol"], [data objectForKey:@"color"]);
            break;
        case CLKComplicationFamilyExtraLarge:
            template = complicationTemplateExtraLargeSimpleText([data objectForKey:@"symbol"], [data objectForKey:@"color"]);
//            template = [self complicationTemplateExtraLargeRingImage];
            break;
        case CLKComplicationFamilyCircularSmall:
            template = complicationTemplateCircularSmallSimpleText([data objectForKey:@"symbol"], [data objectForKey:@"color"]);
//            template = [self complicationTemplateCircularSmallStackText];
            break;
        default:
            break;
    }
    
    return template;
}

NSDictionary *(^planetaryHourProviderData)(NSString *, NSString *, NSString *, UIColor *) = ^(NSString *symbol, NSString *name, NSString *abbr, UIColor *color)
{
    NSDictionary *planetaryHourProviderDataDictionary = @{@"symbol" : symbol,
                                                          @"name"   : name,
                                                          @"color"  : color
                                                          };
    
    return planetaryHourProviderDataDictionary;
};

#pragma mark - Placeholder templates

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler
{
    CLKComplicationTemplate *template = [self templateForComplication:complication.family providerData:planetaryHourProviderData(@"㊏", @"Earth", @"TERA", [UIColor greenColor])];
    handler(template);
}

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler
{
    CLKComplicationTemplate *template = [self templateForComplication:complication.family providerData:planetaryHourProviderData(@"㊏", @"Earth", @"TERA", [UIColor greenColor])];
    handler(template);
}

#pragma mark - Timeline entries

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    __block CLKComplicationTemplate *template = nil;
    [PlanetaryHourDataSource.sharedDataSource currentPlanetaryHoursForLocation:PlanetaryHourDataSource.sharedDataSource.locationManager.location forDate:[NSDate date] completionBlock:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSString *abbr, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, UIColor *color, BOOL current) {
        NSDateInterval *dateInterval = [[NSDateInterval alloc] initWithStartDate:startDate endDate:endDate];
        if ([dateInterval containsDate:[NSDate date]])
        {
            template = [self templateForComplication:complication.family providerData:planetaryHourProviderData([symbol string], name, abbr, color)];
            CLKComplicationTimelineEntry *tle = [CLKComplicationTimelineEntry entryWithDate:startDate complicationTemplate:template] ;
            handler(tle);
        }
    }];
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self getTimelineEndDateForComplication:complication withHandler:^(NSDate * _Nullable timelineEndDate) {
        __block NSMutableArray *entries = [NSMutableArray arrayWithCapacity:limit];
        __block CLKComplicationTemplate *template = nil;
        NSDateInterval *dateInterval = [[NSDateInterval alloc] initWithStartDate:date endDate:timelineEndDate];
            [PlanetaryHourDataSource.sharedDataSource currentPlanetaryHoursForLocation:PlanetaryHourDataSource.sharedDataSource.locationManager.location forDate:date completionBlock:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSString *abbr, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, UIColor *color, BOOL current) {
                NSLog(@"Getting planetary hour data %ld", (long)hour);
                if ([dateInterval containsDate:startDate] && entries.count < limit)
                {
                    template = [self templateForComplication:complication.family providerData:planetaryHourProviderData([symbol string], name, abbr, color)];
                    CLKComplicationTimelineEntry *tle = [CLKComplicationTimelineEntry entryWithDate:startDate complicationTemplate:template] ;
                    [entries addObject:tle];
                    if (hour == 23) {
                        NSLog(@"Submitting %lu entries", (long)entries.count);
                        handler(entries);
                    }
                }
            }];
        }];
}

@end




