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
- (void)planetaryHour:(PlanetaryHourCompletionBlock)planetaryHour;
- (void)planetaryHoursForTimelineDirection:(PlanetaryHoursTimelineDirection)timelineDirection markerDate:(NSDate *)date completionBlock:(PlanetaryHoursRangeCompletionBlock)completionBlock;
- (void)planetForHour:(NSUInteger)hour completionBlock:(PlanetaryHourCompletionBlock)planetaryHour;
- (NSArray<NSDate *> *)solarCalculationForDate:(NSDate *)date location:(CLLocation *)location;

@end

NS_ASSUME_NONNULL_END
