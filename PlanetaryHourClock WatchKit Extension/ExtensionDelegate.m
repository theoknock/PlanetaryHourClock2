//
//  ExtensionDelegate.m
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/17/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "PlanetaryHourDataSource.h"

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    // Perform any final initialization of your application.
    
    dispatch_block_t locate;
    __block dispatch_block_t validateLocation = ^(void) {
        CLLocation *lastLocation = [[[PlanetaryHourDataSource sharedDataSource] locationManager] location];
        if (!CLLocationCoordinate2DIsValid(lastLocation.coordinate) ||
            [[[[PlanetaryHourDataSource sharedDataSource] locationManager] location] coordinate].latitude == 0.0 ||
            [[[[PlanetaryHourDataSource sharedDataSource] locationManager] location] coordinate].longitude == 0.0 ||
            [[[[PlanetaryHourDataSource sharedDataSource] locationManager] location] coordinate].latitude != lastLocation.coordinate.latitude ||
            [[[[PlanetaryHourDataSource sharedDataSource] locationManager] location] coordinate].longitude != lastLocation.coordinate.longitude)
        {
            locate();
        }
//        else {
//            NSLog(@"Latitude: %f\tLongitude: %f\t\t%@", [[[[PlanetaryHourDataSource sharedDataSource] locationManager] location] coordinate].latitude,
//                  [[[[PlanetaryHourDataSource sharedDataSource] locationManager] location] coordinate].longitude,
//                  [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]]);
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
//            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
//            NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
//            NSLog(@"Localized date\t%@", [currentTime description]);
//        }
    };
    
    locate = ^(void) {
        [[[PlanetaryHourDataSource sharedDataSource] locationManager] requestLocation];
        validateLocation();
    };
    
    locate();
    
}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[[CLKComplicationServer sharedInstance] activeComplications] enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:obj];
    }];
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
    [[WKExtension sharedExtension] scheduleBackgroundRefreshWithPreferredDate:[NSDate date] userInfo:nil scheduledCompletion:^(NSError * _Nullable error) {
        [[[CLKComplicationServer sharedInstance] activeComplications] enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:obj];
        }];
        if (error)
            NSLog(@"Scheduled background timeline reload for complication error: %@", error.description);
    }];
}

- (void)applicationWillEnterForeground
{
    [[[CLKComplicationServer sharedInstance] activeComplications] enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:obj];
    }];
}

- (void)applicationDidEnterBackground
{
    [[[CLKComplicationServer sharedInstance] activeComplications] enumerateObjectsUsingBlock:^(CLKComplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:obj];
    }];
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
            [snapshotTask setTaskCompletedWithDefaultStateRestored:YES estimatedSnapshotExpiration:[NSDate distantFuture] userInfo:nil];
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
