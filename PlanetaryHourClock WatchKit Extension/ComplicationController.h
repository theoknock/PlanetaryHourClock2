//
//  ComplicationController.h
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/17/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <ClockKit/ClockKit.h>
#import "PlanetaryHourDataSource.h"

@interface ComplicationController : NSObject <CLKComplicationDataSource, PlanetaryHourDataSourceDelegate>

@end
