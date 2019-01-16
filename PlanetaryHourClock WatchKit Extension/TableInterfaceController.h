//
//  TableInterfaceController.h
//  PlanetaryHour Extension
//
//  Created by Xcode Developer on 10/18/18.
//  Copyright © 2018 Xcode Developer. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceTable *planetaryHoursTable;

@end

NS_ASSUME_NONNULL_END
