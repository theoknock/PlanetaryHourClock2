//
//  ExtensionDelegate.m
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/17/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "NotificationController.h"
#import "PlanetaryHourDataSource.h"

@implementation ExtensionDelegate

@synthesize span = _span, center = _center, selectedIndex = _selectedIndex;

- (MKCoordinateSpan)span
{
    return _span;
}

- (void)setSpan:(MKCoordinateSpan)span
{
    _span = span;
}

- (CLLocationCoordinate2D)center
{
//    NSLog(@"Getting latitude %f, longitude %f", _center.latitude, _center.longitude);
    return _center;
}

- (void)setCenter:(CLLocationCoordinate2D)center
{
//    NSLog(@"Setting latitude %f, longitude %f", center.latitude, center.longitude);
    _center = CLLocationCoordinate2DMake(center.latitude, center.longitude);
//    NSLog(@"Setting _latitude %f, _longitude %f", _center.latitude, _center.longitude);
}

- (NSUInteger)selectedIndex
{
    return _selectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    _selectedIndex = selectedIndex % HOURS_PER_DAY;
    NSLog(@"Selected index: %lu", (unsigned long)_selectedIndex);
}

- (void)switchControllersWithSelectedHour:(NSUInteger)selectedHour
{
    if ([[[WKExtension sharedExtension] visibleInterfaceController] isEqual:[[WKExtension sharedExtension] rootInterfaceController]])
    {
        // switch to map
        PlanetaryHourDataSource.sharedDataSource.planetaryHours(PlanetaryHourDataSource.sharedDataSource.locationManager.location, [NSDate date], ^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSString * _Nonnull abbr, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, UIColor * _Nonnull color, CLLocation * _Nonnull location, CLLocationDistance distance, BOOL current) {
            if (hour == selectedHour)
            {
                [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] setCenter:location.coordinate];
                [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] setSelectedIndex:selectedHour];
                [[[WKExtension sharedExtension] rootInterfaceController] presentControllerWithName:@"MapInterfaceController" context:nil];
            }
        });
    } else {
        // switch to timeline
        [[[WKExtension sharedExtension] visibleInterfaceController] dismissController];
    }
}

- (void)applicationDidFinishLaunching
{
    [(ExtensionDelegate *)[[WKExtension sharedExtension] delegate] setSpan:MKCoordinateSpanMake(7.0, 7.0)];
    
    //[[PlanetaryHourDataSource.sharedDataSource locationManager] requestLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlanetaryHoursDataSourceUpdatedNotification"
                                                        object:[[PlanetaryHourDataSource.sharedDataSource locationManager] location]
                                                      userInfo:nil];
    
//    [self scheduleComplicationTimelineUpdateBackgroundTask];
}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

- (void)applicationWillEnterForeground
{

}

- (void)applicationDidEnterBackground
{
    
}

- (void)handleBackgroundTasks:(NSSet<WKRefreshBackgroundTask *> *)backgroundTasks {
    // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
    for (WKRefreshBackgroundTask * task in backgroundTasks) {
        // Check the Class of each task to decide how to process it
        if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKApplicationRefreshBackgroundTask *backgroundTask = (WKApplicationRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKSnapshotRefreshBackgroundTask class]]) {
            // Snapshot tasks have a unique completion call, make sure to set your expiration date
            WKSnapshotRefreshBackgroundTask *snapshotTask = (WKSnapshotRefreshBackgroundTask*)task;
            [snapshotTask setTaskCompletedWithDefaultStateRestored:NO estimatedSnapshotExpiration:[NSDate distantFuture] userInfo:nil];
        } else if ([task isKindOfClass:[WKWatchConnectivityRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKWatchConnectivityRefreshBackgroundTask *backgroundTask = (WKWatchConnectivityRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKURLSessionRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKURLSessionRefreshBackgroundTask *backgroundTask = (WKURLSessionRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKRelevantShortcutRefreshBackgroundTask class]]) {
            // Be sure to complete the relevant-shortcut task once you’re done.
            WKRelevantShortcutRefreshBackgroundTask *relevantShortcutTask = (WKRelevantShortcutRefreshBackgroundTask*)task;
            [relevantShortcutTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKIntentDidRunRefreshBackgroundTask class]]) {
            // Be sure to complete the intent-did-run task once you’re done.
            WKIntentDidRunRefreshBackgroundTask *intentDidRunTask = (WKIntentDidRunRefreshBackgroundTask*)task;
            [intentDidRunTask setTaskCompletedWithSnapshot:NO];
        } else {
            // make sure to complete unhandled task types
            [task setTaskCompletedWithSnapshot:NO];
        }
    }
}

@end

