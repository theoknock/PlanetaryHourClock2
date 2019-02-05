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

#pragma mark - WKInterfaceController methods

- (IBAction)displayTimeline
{
    [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] switchControllers];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
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
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    MKCoordinateRegion visibleRegion = MKCoordinateRegionMake(PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate, [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] span]);
    [self.map setRegion:visibleRegion];
    
    dispatch_resume(annotationUpdateTimer);
    
    [self.crownSequencer setDelegate:self];
    [self.crownSequencer focus];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    
    [self.crownSequencer resignFocus];
    dispatch_suspend(annotationUpdateTimer);
}

#pragma mark - WKCrownDelegate methods

- (void)crownDidRotate:(WKCrownSequencer *)crownSequencer rotationalDelta:(double)rotationalDelta
{
    MKCoordinateSpan tempSpan        = [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] span];
    tempSpan.latitudeDelta          += ((rotationalDelta * rotationalDelta) * (rotationalDelta)) + (tempSpan.latitudeDelta * rotationalDelta);
    tempSpan.longitudeDelta         += ((rotationalDelta * rotationalDelta) * (rotationalDelta)) + (tempSpan.longitudeDelta * rotationalDelta);
    tempSpan.latitudeDelta           = (tempSpan.latitudeDelta < 0) ? 0  : (tempSpan.latitudeDelta  > MKCoordinateRegionForMapRect(MKMapRectWorld).span.latitudeDelta)  ? MKCoordinateRegionForMapRect(MKMapRectWorld).span.latitudeDelta  : tempSpan.latitudeDelta;
    tempSpan.longitudeDelta          = (tempSpan.longitudeDelta < 0) ? 0 : (tempSpan.longitudeDelta > MKCoordinateRegionForMapRect(MKMapRectWorld).span.longitudeDelta) ? MKCoordinateRegionForMapRect(MKMapRectWorld).span.longitudeDelta : tempSpan.longitudeDelta;
//    NSLog(@"\t\t%f, %f", tempSpan.latitudeDelta, tempSpan.longitudeDelta);
    MKCoordinateRegion visibleRegion = MKCoordinateRegionMake(PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate, tempSpan);
    [self.map setRegion:visibleRegion];
    [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] setSpan:tempSpan];
}

@end






