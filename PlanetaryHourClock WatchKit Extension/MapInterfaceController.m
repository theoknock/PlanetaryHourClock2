//
//  MapInterfaceController.m
//  PlanetaryHourClock WatchKit App
//
//  Created by Xcode Developer on 1/26/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import "MapInterfaceController.h"
#import "ExtensionDelegate.h"
#import "PlanetaryHourDataSource.h"

@interface MapInterfaceController ()
{
    dispatch_source_t annotationUpdateTimer;
}

@end

@implementation MapInterfaceController

#pragma mark - Class location properties

@synthesize userLocation = _userLocation;

- (CLLocation *)userLocation
{
    return _userLocation;
}

- (void)setUserLocation:(CLLocation *)userLocation
{
    _userLocation = userLocation;
    MKCoordinateRegion visibleRegion = MKCoordinateRegionMake(_userLocation.coordinate, MKCoordinateRegionForMapRect(MKMapRectWorld).span);
    [self.map setRegion:visibleRegion];
}

#pragma mark - Planetary-hour annotations methods

NSDate *(^solarTransitDate)(NSDate *, SolarTransit) = ^(NSDate *date, SolarTransit solarTransit)
{
    NSArray<NSDate *> *solarTransits = [PlanetaryHourDataSource.sharedDataSource solarCalculationForDate:date location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
    
    return solarTransits[solarTransit];
};

CLLocation *(^locatePlanetaryHour)(CLLocation * _Nullable, NSDate * _Nullable, NSTimeInterval, NSUInteger) = ^(CLLocation * _Nullable location, NSDate * _Nullable date, NSTimeInterval timeOffset, NSUInteger hour) {
    if (!date) date = [NSDate date];
    hour = hour % HOURS_PER_DAY;
    NSArray<NSDate *> *solarTransits     = [[PlanetaryHourDataSource sharedDataSource] solarCalculationForDate:date location:location];
    NSArray<NSDate *> *nextSolarTransits = [[PlanetaryHourDataSource sharedDataSource] solarCalculationForDate:[date dateByAddingTimeInterval:SECONDS_PER_DAY] location:location];
    NSTimeInterval seconds_in_day        = [solarTransits[Sunset] timeIntervalSinceDate:solarTransits[Sunrise]];
    NSTimeInterval seconds_in_night      = [solarTransits[Sunrise] timeIntervalSinceDate:nextSolarTransits[Sunrise]];
    double meters_per_second             = MKMapSizeWorld.width / SECONDS_PER_DAY;
    double meters_per_day                = seconds_in_day   * meters_per_second;
    double meters_per_night              = seconds_in_night * meters_per_second;
    double meters_per_day_per_hour       = meters_per_day / HOURS_PER_SOLAR_TRANSIT;
    double meters_per_night_per_hour     = meters_per_night / HOURS_PER_SOLAR_TRANSIT;
    
    MKMapPoint user_location_point = MKMapPointForCoordinate(location.coordinate);
    MKMapPoint planetary_hour_origin = MKMapPointMake((hour < HOURS_PER_SOLAR_TRANSIT)
                                                      ? user_location_point.x + (meters_per_day_per_hour * hour)
                                                      : user_location_point.x + (meters_per_day + (meters_per_night_per_hour * (hour % 12))), user_location_point.y);
    planetary_hour_origin = MKMapPointMake(planetary_hour_origin.x - (timeOffset * meters_per_second), planetary_hour_origin.y);
    CLLocationCoordinate2D start_coordinate = MKCoordinateForMapPoint(planetary_hour_origin);
    CLLocation *planetaryHourLocation = [[CLLocation alloc] initWithLatitude:start_coordinate.latitude longitude:start_coordinate.longitude];
    
    return planetaryHourLocation;
};


#pragma mark - WKInterfaceController methods

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    annotationUpdateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(annotationUpdateTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 1.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(annotationUpdateTimer, ^{
        [self.map removeAllAnnotations];
        for (int hour = 0; hour < 5; hour++)
        {
            NSTimeInterval timeOffset = [[NSDate date] timeIntervalSinceDate:[PlanetaryHourDataSource.sharedDataSource solarCalculationForDate:[NSDate date] location:PlanetaryHourDataSource.sharedDataSource.locationManager.location][Sunrise]];
            CLLocationCoordinate2D planetaryHourCoordinate = locatePlanetaryHour(PlanetaryHourDataSource.sharedDataSource.locationManager.location, [NSDate date], timeOffset, hour).coordinate;
//            NSLog(@"Hour %d (%f, %f)", hour, planetaryHourCoordinate.latitude, planetaryHourCoordinate.longitude);
            [self.map addAnnotation:planetaryHourCoordinate withImage:[[PlanetaryHourDataSource sharedDataSource] imageFromText]([NSString stringWithFormat:@"%ld", (long)hour], nil, 9.0) centerOffset:CGPointZero];
        }
    });
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PlanetaryHoursDataSourceUpdatedNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"Received posted notification PlanetaryHoursDataSourceUpdatedNotification");
    
        [self setUserLocation:(CLLocation *)note.object];
        [[[CLKComplicationServer sharedInstance] activeComplications] enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:obj];
        }];
    }];
    
    dispatch_resume(annotationUpdateTimer);
    
    
    
    [self.crownSequencer setDelegate:self];
    [self.crownSequencer focus];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - WKCrownDelegate methods

- (void)crownDidRotate:(WKCrownSequencer *)crownSequencer rotationalDelta:(double)rotationalDelta
{
    [self setUserLocation:[[CLLocation alloc]
                           initWithCoordinate:CLLocationCoordinate2DMake(_userLocation.coordinate.latitude, _userLocation.coordinate.longitude + (rotationalDelta * 10.0))
                           altitude:0.0
                           horizontalAccuracy:kCLLocationAccuracyBest
                           verticalAccuracy:kCLLocationAccuracyBest
                           timestamp:[NSDate date]]];
//    NSLog(@"rotational delta\t%f\t\t%f\t%f", rotationalDelta, _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude);
}

@end



