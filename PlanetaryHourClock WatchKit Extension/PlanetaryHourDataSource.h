//
//  PlanetaryHourDataSource.h
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/18/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <WatchKit/WatchKit.h>

NS_ASSUME_NONNULL_BEGIN

#define SECONDS_PER_DAY 86400.00f
#define HOURS_PER_DAY 24
#define HOURS_PER_SOLAR_TRANSIT 12

typedef NS_ENUM(NSUInteger, SolarTransit) {
    Sunrise,
    Sunset
};

typedef NS_ENUM(NSUInteger, PlanetaryHoursTimelineDirection) {
    PlanetaryHoursTimelineDirectionForward,
    PlanetaryHoursTimelineDirectionBackward
};

typedef void(^PlanetaryHourCompletionBlock)(NSAttributedString *symbol, NSString *name, NSString *abbr, NSDate *startDate, NSDate *endDate, NSInteger hour, UIColor *color, BOOL current);
typedef void(^PlanetaryHoursRangeCompletionBlock)(NSRange planetaryHoursRange);

@interface PlanetaryHourDataSource : NSObject <CLLocationManagerDelegate>
{
    CLLocationCoordinate2D lastCoordinate;
}

+ (nonnull PlanetaryHourDataSource *)sharedDataSource;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) dispatch_queue_t planetaryHourDataRequestQueue;

- (void)currentPlanetaryHoursForLocation:(CLLocation *)location forDate:(NSDate *)date completionBlock:(PlanetaryHourCompletionBlock)planetaryHour;
- (NSArray<NSDate *> *)solarCalculationForDate:(NSDate *)date location:(CLLocation *)location;

@property (strong, nonatomic) NSArray<NSNumber *> *(^planetaryHourDurations)(NSDate *sunrise, NSDate *sunset, NSDate *nextSunrise);
@property (strong, nonatomic) UIImage *(^imageFromText)(NSString *text, UIColor * _Nullable color, float size);

@end

NS_ASSUME_NONNULL_END
