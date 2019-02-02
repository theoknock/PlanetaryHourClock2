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

#pragma mark - WKInterfaceController methods

- (IBAction)displayTimeline
{
    [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] switchControllers];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Map zoom control setup
    span = MKCoordinateSpanMake(50.0, 50.0);
    MKCoordinateRegion visibleRegion = MKCoordinateRegionMake(PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate, span);
    [self.map setRegion:visibleRegion];
    
    // Annotations location update timer
    annotationUpdateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(annotationUpdateTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 1.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(annotationUpdateTimer, ^{
        CLLocation *userLocation = PlanetaryHourDataSource.sharedDataSource.locationManager.location;
        [self.map removeAllAnnotations];
        [self.map addAnnotation:userLocation.coordinate withPinColor:WKInterfaceMapPinColorPurple];
        [PlanetaryHourDataSource.sharedDataSource planetaryHours](userLocation, [NSDate date], ^(NSAttributedString *symbol, NSString *name, NSString *abbr, NSDate *startDate, NSDate *endDate, NSInteger hour, UIColor *color, CLLocation *location, CLLocationDistance distance, BOOL current)
                                                                  {
                                                                      if ([location distanceFromLocation:userLocation] <= (distance / 5.0))
                                                                      {
                                                                          [self.map addAnnotation:location.coordinate withImage:PlanetaryHourDataSource.sharedDataSource.imageFromText([symbol string], color, 18.0) centerOffset:CGPointZero];
                                                                      }
                                                                  });
    });
    dispatch_resume(annotationUpdateTimer);
    
    // Location updates notification observer
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PlanetaryHoursDataSourceUpdatedNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [[[CLKComplicationServer sharedInstance] activeComplications] enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:obj];
        }];
    }];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    [self.crownSequencer setDelegate:self];
    [self.crownSequencer focus];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    
    [self.crownSequencer resignFocus];
}

#pragma mark - WKCrownDelegate methods

- (void)crownDidRotate:(WKCrownSequencer *)crownSequencer rotationalDelta:(double)rotationalDelta
{
    dispatch_async(dispatch_get_main_queue(), ^{
        span.latitudeDelta  += ((rotationalDelta * rotationalDelta) * (rotationalDelta)) + (span.latitudeDelta * rotationalDelta);
        span.longitudeDelta += ((rotationalDelta * rotationalDelta) * (rotationalDelta)) + (span.longitudeDelta * rotationalDelta);
        span.latitudeDelta   = (span.latitudeDelta < 0) ? 0  : (span.latitudeDelta  > MKCoordinateRegionForMapRect(MKMapRectWorld).span.latitudeDelta)  ? MKCoordinateRegionForMapRect(MKMapRectWorld).span.latitudeDelta  : span.latitudeDelta;
        span.longitudeDelta  = (span.longitudeDelta < 0) ? 0 : (span.longitudeDelta > MKCoordinateRegionForMapRect(MKMapRectWorld).span.longitudeDelta) ? MKCoordinateRegionForMapRect(MKMapRectWorld).span.longitudeDelta : span.longitudeDelta;
        
        MKCoordinateRegion visibleRegion = MKCoordinateRegionMake(PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate, span);
        [self.map setRegion:visibleRegion];
        
    });
}

@end






