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

#pragma mark - Placeholder Templates

CLKComplicationTemplateModularLargeTallBody *(^complicationTemplateModularLargeTallBody)(NSString *, NSString *) = ^(NSString *headerText, NSString *bodyText)
{
    CLKComplicationTemplateModularLargeTallBody *template = [[CLKComplicationTemplateModularLargeTallBody alloc] init];
    template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:headerText];
    template.bodyTextProvider = [CLKSimpleTextProvider textProviderWithText:bodyText];
    template.tintColor = [UIColor whiteColor];
    
    return template;
};

//CLKComplicationTemplateModularLargeTable *(^complicationTemplateModularLargeTable)(NSString *, NSString *, NSString *, NSString *, NSString *) = ^(NSString *a, NSString *b, NSString *c, NSString *d, NSString *e)
//{
//    CLKComplicationTemplateModularLargeTable *template = [[CLKComplicationTemplateModularLargeTable alloc] init];
//    template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
//    template.row1Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
//    template.row1Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
//    template.row2Column1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
//    template.row2Column2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
////    template.headerImageProvider...
//
//    return template;
//};

- (CLKComplicationTemplateModularSmallSimpleText *)complicationTemplateModularSmallSimpleText {
    CLKComplicationTemplateModularSmallSimpleText *template = [[CLKComplicationTemplateModularSmallSimpleText alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor whiteColor];
    return template;
}


- (CLKComplicationTemplateUtilitarianLargeFlat *)complicationTemplateUtilitarianLargeFlat {
    CLKComplicationTemplateUtilitarianLargeFlat *template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor whiteColor];
    return template;
}

- (CLKComplicationTemplateUtilitarianSmallFlat *)complicationTemplateUtilitarianSmallFlat {
    CLKComplicationTemplateUtilitarianSmallFlat *template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor whiteColor];
    return template;
}

- (CLKComplicationTemplateExtraLargeSimpleText *)complicationTemplateModularLargeSimpleText {
    CLKComplicationTemplateExtraLargeSimpleText *template = [[CLKComplicationTemplateExtraLargeSimpleText alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor whiteColor];
    return template;
}

- (CLKComplicationTemplateCircularSmallSimpleText *)complicationTemplateCircularSmallSimpleText {
    CLKComplicationTemplateCircularSmallSimpleText *template = [[CLKComplicationTemplateCircularSmallSimpleText alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor whiteColor];
    return template;
}

- (CLKComplicationTemplateCircularSmallStackText *)complicationTemplateCircularSmallStackText {
    CLKComplicationTemplateCircularSmallStackText *template = [[CLKComplicationTemplateCircularSmallStackText alloc] init];
    template.line1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
    template.line2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Earth"];
    return template;
}

//- (CLKComplicationTemplateExtraLargeRingImage *)complicationTemplateExtraLargeRingImage {
//    CLKComplicationTemplateExtraLargeRingImage *template = [[CLKComplicationTemplateExtraLargeRingImage alloc] init];
//    template.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[self imageFromText:@"㊏"]];
//    return template;
//}

- (CLKComplicationTemplateModularSmallRingText *)complicationTemplateModularSmallRingText {
    CLKComplicationTemplateModularSmallRingText *template = [[CLKComplicationTemplateModularSmallRingText alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
    template.ringStyle    = CLKComplicationRingStyleClosed;
    template.fillFraction = .5;
    return template;
}


- (CLKComplicationTemplate *)templateForComplication:(CLKComplication *)complication {
    CLKComplicationTemplate *template = nil;
    
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
            template = complicationTemplateModularLargeTallBody(@"㊏", @"Earth"); // complicationTemplateModularLargeTallBody(@"㊏", @"Earth");
            break ;
        case CLKComplicationFamilyModularSmall:
            template = [self complicationTemplateModularSmallSimpleText];
//            template = [self complicationTemplateModularSmallRingText];
            break ;
        case CLKComplicationFamilyUtilitarianLarge:
            template = [self complicationTemplateUtilitarianLargeFlat];
            break ;
        case CLKComplicationFamilyUtilitarianSmall:
            template = [self complicationTemplateUtilitarianSmallFlat];
            break;
        case CLKComplicationFamilyExtraLarge:
            template = [self complicationTemplateModularLargeSimpleText];
//            template = [self complicationTemplateExtraLargeRingImage];
            break;
        case CLKComplicationFamilyCircularSmall:
//            template = [self complicationTemplateCircularSmallSimpleText];
            template = [self complicationTemplateCircularSmallStackText];
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
        [PlanetaryHourDataSource.sharedDataSource currentPlanetaryHoursForLocation:PlanetaryHourDataSource.sharedDataSource.locationManager.location forDate:[NSDate date] completionBlock:^(NSAttributedString * _Nonnull symbol, NSString *abbr, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, UIColor *color, BOOL current) {
            NSDateInterval *dateInterval = [[NSDateInterval alloc] initWithStartDate:startDate endDate:endDate];
            if ([dateInterval containsDate:[NSDate date]])
            {
                switch (complication.family) {
                    case CLKComplicationFamilyModularLarge:
                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).headerTextProvider).text = name;
                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).bodyTextProvider).text = [symbol string];
                        break ;
                    case CLKComplicationFamilyModularSmall:
//                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularSmallRingText *)template).textProvider).text = [symbol string];
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
//                        ((CLKImageProvider *)((CLKComplicationTemplateExtraLargeRingImage *)template).imageProvider).onePieceImage = [self imageFromText:[symbol string]];
                        break;
                    case CLKComplicationFamilyCircularSmall:
//                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateCircularSmallSimpleText *)template).textProvider).text = [symbol string];
                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateCircularSmallStackText *)template).line1TextProvider).text = [symbol string];
                        ((CLKSimpleTextProvider *)((CLKComplicationTemplateCircularSmallStackText *)template).line2TextProvider).text = name;
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
            [PlanetaryHourDataSource.sharedDataSource currentPlanetaryHoursForLocation:PlanetaryHourDataSource.sharedDataSource.locationManager.location forDate:date completionBlock:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSString *abbr, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, UIColor *color, BOOL current) {
                NSLog(@"Getting planetary hour data %ld", (long)hour);
                if ([dateInterval containsDate:startDate] && entries.count < limit)
                {
                    NSLog(@"Adding as an entry %lu (count %lu of limit %lu)", (long)hour, (long)entries.count, (long)limit);
                    switch (complication.family) {
                        case CLKComplicationFamilyModularLarge:
                            ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).headerTextProvider).text = name;
                            ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).bodyTextProvider).text = [symbol string];
                            break;
                        case CLKComplicationFamilyModularSmall:
//                            ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularSmallRingText *)template).textProvider).text = [symbol string];
                            ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularSmallSimpleText *)template).textProvider).text = [symbol string];
                            break;
                        case CLKComplicationFamilyUtilitarianLarge:
                            ((CLKSimpleTextProvider *)((CLKComplicationTemplateUtilitarianLargeFlat *)template).textProvider).text = [symbol string];
                            break;
                        case CLKComplicationFamilyUtilitarianSmall:
                            ((CLKSimpleTextProvider *)((CLKComplicationTemplateUtilitarianSmallFlat *)template).textProvider).text = [symbol string];
                            break;
                        case CLKComplicationFamilyExtraLarge:
                            ((CLKSimpleTextProvider *)((CLKComplicationTemplateExtraLargeSimpleText *)template).textProvider).text = [symbol string];
//                            ((CLKImageProvider *)((CLKComplicationTemplateExtraLargeRingImage *)template).imageProvider).onePieceImage = [self imageFromText:[symbol string]];
                            break;
                        case CLKComplicationFamilyCircularSmall:
//                            ((CLKSimpleTextProvider *)((CLKComplicationTemplateCircularSmallSimpleText *)template).textProvider).text = [symbol string];
                            ((CLKSimpleTextProvider *)((CLKComplicationTemplateCircularSmallStackText *)template).line1TextProvider).text = [symbol string];
                            ((CLKSimpleTextProvider *)((CLKComplicationTemplateCircularSmallStackText *)template).line2TextProvider).text = abbr;
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
    CLKComplicationTemplate *template = [self templateForComplication:complication];
    
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
            template = [[CLKComplicationTemplateModularLargeTallBody alloc] init];
            ((CLKComplicationTemplateModularLargeTallBody *)template).headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            ((CLKComplicationTemplateModularLargeTallBody *)template).bodyTextProvider   = [CLKSimpleTextProvider textProviderWithText:@"Earth"];
            break;
        case CLKComplicationFamilyModularSmall:
//            template = [[CLKComplicationTemplateModularSmallRingText alloc] init];
//            ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularSmallRingText *)template).textProvider).text = @"㊏";
//            template = [[CLKComplicationTemplateModularSmallSimpleText alloc] init];
            ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularSmallSimpleText *)template).textProvider).text = @"㊏";;
            break;
        case CLKComplicationFamilyUtilitarianLarge:
//            template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init];
            ((CLKComplicationTemplateUtilitarianLargeFlat *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break;
        case CLKComplicationFamilyUtilitarianSmall:
//            template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
            ((CLKComplicationTemplateUtilitarianSmallFlat *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break;
        case CLKComplicationFamilyExtraLarge:
//            template = [[CLKComplicationTemplateExtraLargeSimpleText alloc] init];
            ((CLKComplicationTemplateExtraLargeSimpleText *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
//            template = [[CLKComplicationTemplateExtraLargeRingImage alloc] init];
//            ((CLKImageProvider *)((CLKComplicationTemplateExtraLargeRingImage *)template).imageProvider).onePieceImage = [self imageFromText:@"㊏"];
            break;
        case CLKComplicationFamilyCircularSmall:
//            template = [[CLKComplicationTemplateCircularSmallSimpleText alloc] init];
//            ((CLKComplicationTemplateCircularSmallSimpleText *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
//            template = [[CLKComplicationTemplateCircularSmallStackText alloc] init];
            ((CLKComplicationTemplateCircularSmallStackText *)template).line1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            ((CLKComplicationTemplateCircularSmallStackText *)template).line2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Earth"];
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
    CLKComplicationTemplate *template = [self templateForComplication:complication];
    
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
            template = [[CLKComplicationTemplateModularLargeTallBody alloc] init];
            ((CLKComplicationTemplateModularLargeTallBody *)template).headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            ((CLKComplicationTemplateModularLargeTallBody *)template).bodyTextProvider   = [CLKSimpleTextProvider textProviderWithText:@"Earth"];
            break ;
        case CLKComplicationFamilyModularSmall:
//            template = [[CLKComplicationTemplateModularSmallRingText alloc] init];
//            ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularSmallRingText *)template).textProvider).text = @"㊏";
//            template = [[CLKComplicationTemplateModularSmallSimpleText alloc] init];
            ((CLKComplicationTemplateModularSmallSimpleText *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break ;
        case CLKComplicationFamilyUtilitarianLarge:
//            template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init] ;
            ((CLKComplicationTemplateUtilitarianLargeFlat *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break ;
        case CLKComplicationFamilyUtilitarianSmall:
//            template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
            ((CLKComplicationTemplateUtilitarianSmallFlat *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            break;
        case CLKComplicationFamilyExtraLarge:
//            template = [[CLKComplicationTemplateExtraLargeSimpleText alloc] init] ;
            ((CLKComplicationTemplateExtraLargeSimpleText *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
//            template = [[CLKComplicationTemplateExtraLargeRingImage alloc] init];
//            ((CLKImageProvider *)((CLKComplicationTemplateExtraLargeRingImage *)template).imageProvider).onePieceImage = [self imageFromText:@"㊏"];
            break;
        case CLKComplicationFamilyCircularSmall:
            //            template = [[CLKComplicationTemplateCircularSmallSimpleText alloc] init];
            //            ((CLKComplicationTemplateCircularSmallSimpleText *)template).textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
//            template = [[CLKComplicationTemplateCircularSmallStackText alloc] init];
            ((CLKComplicationTemplateCircularSmallStackText *)template).line1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"];
            ((CLKComplicationTemplateCircularSmallStackText *)template).line2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Earth"];
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




