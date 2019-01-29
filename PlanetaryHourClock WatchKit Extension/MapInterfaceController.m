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
    MKCoordinateSpan span;
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
    NSLog(@"User location: %f, %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
//    MKCoordinateRegion visibleRegion = MKCoordinateRegionMake(_userLocation.coordinate, MKCoordinateSpanMake(0.05, 0.05));
//    [self.map setRegion:visibleRegion];
}

#pragma mark - WKInterfaceController methods

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Map zoom control setup
    [self.crownSequencer setDelegate:self];
    [self.crownSequencer focus];
    
    // Annotations location update timer
    annotationUpdateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(annotationUpdateTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 1.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(annotationUpdateTimer, ^{
        CLLocation *userLocation = PlanetaryHourDataSource.sharedDataSource.locationManager.location;
        [self.map removeAllAnnotations];
        [self.map addAnnotation:userLocation.coordinate withPinColor:WKInterfaceMapPinColorPurple];
        [PlanetaryHourDataSource.sharedDataSource planetaryHours](userLocation, [NSDate date], ^(NSAttributedString *symbol, NSString *name, NSString *abbr, NSDate *startDate, NSDate *endDate, NSInteger hour, UIColor *color, CLLocation *location, CLLocationDistance length_meters, BOOL current)
        {
            [self.map addAnnotation:location.coordinate withImage:PlanetaryHourDataSource.sharedDataSource.imageFromText([symbol string], color, 36.0) centerOffset:CGPointZero];
        });
    });
    dispatch_resume(annotationUpdateTimer);
    
    // Location updates notification observer
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PlanetaryHoursDataSourceUpdatedNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self setUserLocation:(CLLocation *)note.object];
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

#pragma mark - WKCrownDelegate methods

- (void)crownDidRotate:(WKCrownSequencer *)crownSequencer rotationalDelta:(double)rotationalDelta
{
//    [self setUserLocation:[[CLLocation alloc]
//                           initWithCoordinate:CLLocationCoordinate2DMake(_userLocation.coordinate.latitude, _userLocation.coordinate.longitude + (rotationalDelta * 10.0))
//                           altitude:0.0
//                           horizontalAccuracy:kCLLocationAccuracyBest
//                           verticalAccuracy:kCLLocationAccuracyBest
//                           timestamp:[NSDate date]]];
    CLLocation *userLocation = PlanetaryHourDataSource.sharedDataSource.locationManager.location;
    
    
    span.latitudeDelta  += ((rotationalDelta * rotationalDelta) * (rotationalDelta)) + (span.latitudeDelta * rotationalDelta);
    span.longitudeDelta += ((rotationalDelta * rotationalDelta) * (rotationalDelta)) + (span.longitudeDelta * rotationalDelta);
    span.latitudeDelta   = (span.latitudeDelta < 0) ? 0  : (span.latitudeDelta  > MKCoordinateRegionForMapRect(MKMapRectWorld).span.latitudeDelta)  ? MKCoordinateRegionForMapRect(MKMapRectWorld).span.latitudeDelta  : span.latitudeDelta;
    span.longitudeDelta  = (span.longitudeDelta < 0) ? 0 : (span.longitudeDelta > MKCoordinateRegionForMapRect(MKMapRectWorld).span.longitudeDelta) ? MKCoordinateRegionForMapRect(MKMapRectWorld).span.longitudeDelta : span.longitudeDelta;
    
    MKCoordinateRegion visibleRegion = MKCoordinateRegionMake(PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate, span);
    
    [self.map setRegion:visibleRegion];
    
    
//    [self.map setVisibleMapRect:MKMapRectMake(MKMapPointForCoordinate(userLocation.coordinate).x, MKMapPointForCoordinate(userLocation.coordinate).y, span.latitudeDelta, span.longitudeDelta)];
//    span.latitudeDelta  += MKMapSizeWorld.width * rotationalDelta;
//    span.longitudeDelta += MKMapSizeWorld.height * rotationalDelta;
//    span.latitudeDelta   = (span.latitudeDelta  < 0) ? 0  : (span.latitudeDelta  > MKMapSizeWorld.width)  ? MKMapSizeWorld.width  : span.latitudeDelta;
//    span.longitudeDelta  = (span.longitudeDelta < 0) ? 0  : (span.longitudeDelta > MKMapSizeWorld.height) ? MKMapSizeWorld.height : span.longitudeDelta;
//    MKMapRect mapRect = MKMapRectMake(userLocationMapPoint.x, userLocationMapPoint.y, span.latitudeDelta, span.longitudeDelta);
//    [self.map setRegion:MKCoordinateRegionForMapRect(mapRect)];
//    [self.map setVisibleMapRect:mapRect];
    NSLog(@"rotational delta\t%f\t\tspan\t%f %f", rotationalDelta, span.latitudeDelta, span.longitudeDelta);
}

@end




