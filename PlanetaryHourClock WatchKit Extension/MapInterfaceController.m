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
//    [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] setCenter:PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate];
    
    annotationUpdateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(annotationUpdateTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 1.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(annotationUpdateTimer, ^{
        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake([(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] center].latitude, [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] center].longitude);
        [self.map removeAllAnnotations];
        [self.map addAnnotation:PlanetaryHourDataSource.sharedDataSource.locationManager.location.coordinate withPinColor:WKInterfaceMapPinColorPurple];
        [PlanetaryHourDataSource.sharedDataSource planetaryHours](PlanetaryHourDataSource.sharedDataSource.locationManager.location, [NSDate date], ^(NSAttributedString *symbol, NSString *name, NSString *abbr, NSDate *startDate, NSDate *endDate, NSInteger hour, UIColor *color, CLLocation *location, CLLocationDistance distance, BOOL current)
                                                                  {
                                                                      CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
                                                                      if ([location distanceFromLocation:centerLocation] <= (distance / 5.0))
                                                                      {
                                                                          [self.map addAnnotation:location.coordinate withImage:PlanetaryHourDataSource.sharedDataSource.imageFromText([symbol string], color, 18.0) centerOffset:CGPointZero];
                                                                      }
                                                                      centerLocation = nil;
                                                                  });
    });
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    MKCoordinateRegion visibleRegion = MKCoordinateRegionMake([(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] center], [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] span]);
    [self.map setRegion:visibleRegion];
    
    dispatch_resume(annotationUpdateTimer);
    
    [self.crownSequencer setDelegate:self];
    [self.crownSequencer focus];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    
    [self.crownSequencer resignFocus];
    [self.map removeAllAnnotations];
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
    MKCoordinateRegion visibleRegion = MKCoordinateRegionMake([(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] center], tempSpan);
    [self.map setRegion:visibleRegion];
    [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] setSpan:tempSpan];
}

@end






