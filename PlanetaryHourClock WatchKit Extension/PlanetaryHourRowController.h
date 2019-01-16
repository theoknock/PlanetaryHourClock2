//
//  PlanetaryHourRowController.h
//  PlanetaryHours
//
//  Created by Xcode Developer on 10/18/18.
//  Copyright © 2018 Xcode Developer. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlanetaryHourRowController : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *planetLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *symbolLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *rowGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *countDownTimerGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *hourLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *startDateLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *endDateLabel;

@end

NS_ASSUME_NONNULL_END
