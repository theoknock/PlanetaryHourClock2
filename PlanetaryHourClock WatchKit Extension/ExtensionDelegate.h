//
//  ExtensionDelegate.h
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/17/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import "PlanetaryHourDataSource.h"

@interface ExtensionDelegate : NSObject <WKExtensionDelegate>

@property (assign, nonatomic, setter=setSpan:) MKCoordinateSpan span;
@property (assign, nonatomic, setter=setCenter:) CLLocationCoordinate2D center;
@property (assign, nonatomic, setter=setSelectedIndex:) NSUInteger selectedIndex;


- (void)switchControllersWithSelectedHour:(NSUInteger)selectedHour;

@end
