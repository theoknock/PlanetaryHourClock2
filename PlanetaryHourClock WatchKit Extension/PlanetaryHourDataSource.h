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

typedef void(^PlanetaryHourCompletionBlock)(NSAttributedString *symbol, NSString *name, NSString *abbr, NSDate *startDate, NSDate *endDate, NSInteger hour, UIColor *color, CLLocation *location, CLLocationDistance distance, BOOL current);

@interface PlanetaryHourDataSource : NSObject <CLLocationManagerDelegate>
{
    CLLocationCoordinate2D lastCoordinate;
}

+ (nonnull PlanetaryHourDataSource *)sharedDataSource;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) dispatch_queue_t planetaryHourDataRequestQueue;

@property (strong, nonatomic) void (^planetaryHours)(CLLocation *location, NSDate *date, PlanetaryHourCompletionBlock planetaryHour);
@property (strong, nonatomic) NSArray<NSNumber *> *(^planetaryHourDurations)(NSDate *sunrise, NSDate *sunset, NSDate *nextSunrise);
@property (strong, nonatomic) UIImage *(^imageFromText)(NSString *text, UIColor * _Nullable color, CGFloat fontsize);
@property (strong, nonatomic) NSDictionary *(^planetaryHourData)(NSString *symbol, NSString *name, NSNumber *hour, NSString *abbr, NSDate *start, NSDate *end, UIColor *color);
@property (strong, nonatomic) CLLocation *(^locatePlanetaryHour)(CLLocation * _Nullable location, NSDate * _Nullable date, double meters_per_second, double meters_per_day, double meters_per_day_hour, double meters_per_night_hour, NSTimeInterval timeOffset, NSUInteger hour);
@property (strong, nonatomic) NSArray<NSDate *> *(^solarTransits)(NSDate *date, CLLocation *location);

@end

NS_ASSUME_NONNULL_END
