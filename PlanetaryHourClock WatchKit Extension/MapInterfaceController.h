//
//  MapInterfaceController.h
//  PlanetaryHourClock WatchKit App
//
//  Created by Xcode Developer on 1/26/19.
//  Copyright © 2019 The Life of a Demoniac. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapInterfaceController : WKInterfaceController <WKCrownDelegate>

@property (weak, nonatomic) IBOutlet WKInterfaceMap *map;

@end

NS_ASSUME_NONNULL_END
