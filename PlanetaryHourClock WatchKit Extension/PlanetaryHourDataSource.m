//
//  PlanetaryHourDataSource.m
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/18/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "PlanetaryHourDataSource.h"
#import "FESSolarCalculator.h"

@implementation PlanetaryHourDataSource

static PlanetaryHourDataSource *sharedDataSource = NULL;
+ (nonnull PlanetaryHourDataSource *)sharedDataSource
{
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
                      if (!sharedDataSource)
                      {
                          sharedDataSource = [[self alloc] init];
                      }
                  });
    
    return sharedDataSource;
}

- (UIImage * _Nonnull (^)(NSString * _Nonnull, UIColor * _Nullable, float))imageFromText
{
    return ^(NSString *text, UIColor *color, CGFloat fontsize)
    {
        NSMutableParagraphStyle *centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        centerAlignedParagraphStyle.alignment                = NSTextAlignmentCenter;
        NSDictionary *centerAlignedTextAttributes            = @{NSForegroundColorAttributeName : (!color) ? [UIColor redColor] : color,
                                                                 NSParagraphStyleAttributeName  : centerAlignedParagraphStyle,
                                                                 NSFontAttributeName            : [UIFont systemFontOfSize:fontsize weight:UIFontWeightBlack]
                                                                 };
        
        CGSize textSize = [text sizeWithAttributes:centerAlignedTextAttributes];
        UIGraphicsBeginImageContextWithOptions(textSize, NO, 0);
        [text drawAtPoint:CGPointZero withAttributes:centerAlignedTextAttributes];
        
        CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    };
}

- (instancetype)init
{
    if (self == [super init])
    {
        self.planetaryHourDataRequestQueue = dispatch_queue_create_with_target("Planetary Hour Data Request Queue", DISPATCH_QUEUE_CONCURRENT, dispatch_get_main_queue());
    }
    
    return self;
}

#pragma mark - Location Services

- (CLLocationManager *)locationManager
{
    CLLocationManager *lm = self->_locationManager;
    if (!lm)
    {
        lm = [[CLLocationManager alloc] init];
        lm.desiredAccuracy = kCLLocationAccuracyKilometer;
        lm.distanceFilter  = 100;
        
        if ([lm respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [lm requestWhenInUseAuthorization];
        }
        lm.delegate = self;
        [lm startUpdatingLocation];
        
        self->_locationManager = lm;
        
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    
    return lm;
}

#pragma mark <CLLocationManagerDelegate methods>

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s\n%@", __PRETTY_FUNCTION__, error.localizedDescription);
    [manager requestLocation];
    
    //        dispatch_block_t locate;
    //        __block dispatch_block_t validateLocation = ^(void) {
    //            if (!CLLocationCoordinate2DIsValid([[[[PlanetaryHourDataSource sharedDataSource] locationManager] location] coordinate]))
    //            {
    //                locate();
    //            }
    //        };
    //
    //        locate = ^(void) {
    //            [[[PlanetaryHourDataSource sharedDataSource] locationManager] requestLocation];
    //            validateLocation();
    //        };
    //
    //        locate();
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        NSLog(@"Failure to authorize location services\t%d", status);
        //        [manager stopUpdatingLocation];
    }
    else
    {
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
            status == kCLAuthorizationStatusAuthorizedAlways)
        {
            NSLog(@"Location services authorized\t%d", status);
            //            [manager requestLocation];
            
            //            __block dispatch_block_t locate;
            //            dispatch_block_t validateLocation = ^(void) {
            //                if (!CLLocationCoordinate2DIsValid([[manager location] coordinate]) ||
            //                    [[manager location] coordinate].latitude == 0.0 ||
            //                    [[manager location] coordinate].longitude == 0.0)
            //                {
            //                    locate();
            //                }
            //                else {
            //                    NSLog(@"Latitude: %f\tLongitude: %f\t\t%@", [[manager location] coordinate].latitude,
            //                          [[manager location] coordinate].longitude,
            //                          [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]]);
            //                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //                    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            //                    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            //                    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            //                    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
            //                    NSLog(@"Localized date\t%@", [currentTime description]);
            //                }
            //            };
            //
            //            locate = ^(void) {
            //                [manager requestLocation];
            //                validateLocation();
            //            };
            //
            //            locate();
        } else {
            NSLog(@"Location services authorization status code:\t%d", status);
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    CLLocationCoordinate2D coordinate = locations.lastObject.coordinate;
    if (CLLocationCoordinate2DIsValid(coordinate) && (coordinate.latitude != 0.0 || coordinate.longitude != 0.0))
    {
        if (coordinate.latitude != lastCoordinate.latitude && coordinate.longitude != lastCoordinate.longitude)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PlanetaryHoursDataSourceUpdatedNotification"
                                                                object:locations.lastObject
                                                              userInfo:nil];
            lastCoordinate = coordinate;
        }
        NSLog(@"Posting PlanetaryHoursDataSourceUpdatedNotification...");
    }
}

#pragma mark - SolarData Calculations

double const FESSolarCalculationZenithOfficial = 90.83;

double const toRadians = M_PI / 180;
double const toDegrees = 180 / M_PI;

NSDate *(^dateFromJulianDayNumber)(double) = ^(double julianDayValue)
{
    // calculation of Gregorian date from Julian Day Number ( http://en.wikipedia.org/wiki/Julian_day )
    int JulianDayNumber = (int)floor(julianDayValue);
    int J = floor(JulianDayNumber + 0.5);
    int j = J + 32044;
    int g = j / 146097;
    int dg = j - (j/146097) * 146097; // mod
    int c = (dg / 36524 + 1) * 3 / 4;
    int dc = dg - c * 36524;
    int b = dc / 1461;
    int db = dc - (dc/1461) * 1461; // mod
    int a = (db / 365 + 1) * 3 / 4;
    int da = db - a * 365;
    int y = g * 400 + c * 100 + b * 4 + a;
    int m = (da * 5 + 308) / 153 - 2;
    int d = da - (m + 4) * 153 / 5 + 122;
    NSDateComponents *components = [NSDateComponents new];
    components.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    components.year = y - 4800 + (m + 2) / 12;
    components.month = ((m+2) - ((m+2)/12) * 12) + 1;
    components.day = d + 1;
    double timeValue = ((julianDayValue - floor(julianDayValue)) + 0.5) * 24;
    components.hour = (int)floor(timeValue);
    double minutes = (timeValue - floor(timeValue)) * 60;
    components.minute = (int)floor(minutes);
    components.second = (int)((minutes - floor(minutes)) * 60);
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *returnDate = [calendar dateFromComponents:components];
    
    return returnDate;
};

int (^julianDayNumberFromDate)(NSDate *) = ^(NSDate *inDate)
{
    // calculation of Julian Day Number (http://en.wikipedia.org/wiki/Julian_day ) from Gregorian Date
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:inDate];
    int a = (14 - (int)[components month]) / 12;
    int y = (int)[components year] +  4800 - a;
    int m = (int)[components month] + (12 * a) - 3;
    int JulianDayNumber = (int)[components day] + (((153 * m) + 2) / 5) + (365 * y) + (y/4) - (y/100) + (y/400) - 32045;
    
    return JulianDayNumber;
};

NSArray<NSDate *> *(^calculateSolarData)(NSDate *, CLLocationCoordinate2D) = ^(NSDate *startDate, CLLocationCoordinate2D coordinate)
{
    // math in this method comes directly from http://users.electromagnetic.net/bu/astro/sunrise-set.php
    // with a change to calculate twilight times as well (that information comes from
    // http://williams.best.vwh.net/sunrise_sunset_algorithm.htm ). The math in the first url
    // is sourced from http://www.astro.uu.nl/~strous/AA/en/reken/zonpositie.html which no longer exists
    // but a copy was found on the Wayback Machine at
    // http://web.archive.org/web/20110723172451/http://www.astro.uu.nl/~strous/AA/en/reken/zonpositie.html
    // All constants can be referenced and are explained on the archive.org page
    
    // run the calculations based on the users criteria at initalization time
    //    int JulianDayNumber = [FESSolarCalculator julianDayNumberFromDate:self.startDate];
    int JulianDayNumber = julianDayNumberFromDate(startDate);
    double JanuaryFirst2000JDN = 2451545.0;
    
    // this formula requires west longitude, thus 75W = 75, 45E = -45
    // convert to get it there
    double westLongitude = coordinate.longitude * -1.0;
    
    // define some of our mathmatical values;
    double Nearest = 0.0;
    double ElipticalLongitudeOfSun = 0.0;
    double ElipticalLongitudeRadians = ElipticalLongitudeOfSun * toRadians;
    double MeanAnomoly = 0.0;
    double MeanAnomolyRadians = MeanAnomoly * toRadians;
    double MAprev = -1.0;
    double Jtransit = 0.0;
    
    // we loop through our calculations for Jtransit
    // Running the loop the first time we then re-run it with Jtransit
    // as the input to refine MeanAnomoly. Once MeanAnomoly is equal
    // to the previous run's MeanAnomoly calculation we can continue
    while (MeanAnomoly != MAprev) {
        MAprev = MeanAnomoly;
        Nearest = round(((double)JulianDayNumber - JanuaryFirst2000JDN - 0.0009) - (westLongitude/360.0));
        double Japprox = JanuaryFirst2000JDN + 0.0009 + (westLongitude/360.0) + Nearest;
        if (Jtransit != 0.0) {
            Japprox = Jtransit;
        }
        double Ms = (357.5291 + 0.98560028 * (Japprox - JanuaryFirst2000JDN));
        MeanAnomoly = fmod(Ms, 360.0);
        MeanAnomolyRadians = MeanAnomoly * toRadians;
        double EquationOfCenter = (1.9148 * sin(MeanAnomolyRadians)) + (0.0200 * sin(2.0 * (MeanAnomolyRadians))) + (0.0003 * sin(3.0 * (MeanAnomolyRadians)));
        double eLs = (MeanAnomoly + 102.9372 + EquationOfCenter + 180.0);
        ElipticalLongitudeOfSun = fmod(eLs, 360.0);
        ElipticalLongitudeRadians = ElipticalLongitudeOfSun * toRadians;
        if (Jtransit == 0.0) {
            Jtransit = Japprox + (0.0053 * sin(MeanAnomolyRadians)) - (0.0069 * sin(2.0 * ElipticalLongitudeRadians));
        }
    }
    
    double DeclinationOfSun = asin( sin(ElipticalLongitudeRadians) * sin(23.45 * toRadians) ) * toDegrees;
    double DeclinationOfSunRadians = DeclinationOfSun * toRadians;
    
    // We now have solar noon for our day
    //    NSDate *solarNoon = dateFromJulianDayNumber(Jtransit);
    
    // create a block to run our per-zenith calculations based on solar noon
    double H1 = (cos(FESSolarCalculationZenithOfficial * toRadians) - sin(coordinate.latitude * toRadians) * sin(DeclinationOfSunRadians));
    double H2 = (cos(coordinate.latitude * toRadians) * cos(DeclinationOfSunRadians));
    double HourAngle = acos( (H1  * toRadians) / (H2  * toRadians) ) * toDegrees;
    
    double Jss = JanuaryFirst2000JDN + 0.0009 + ((HourAngle + westLongitude)/360.0) + Nearest;
    
    // compute the setting time from Jss approximation
    double Jset = Jss + (0.0053 * sin(MeanAnomolyRadians)) - (0.0069 * sin(2.0 * ElipticalLongitudeRadians));
    // calculate the rise time based on solar noon and the set time
    double Jrise = Jtransit - (Jset - Jtransit);
    
    // assign the rise and set dates to the correct properties
    NSDate *riseDate = dateFromJulianDayNumber(Jrise);
    NSDate *setDate = dateFromJulianDayNumber(Jset);
    
    return @[riseDate, setDate];
};


#pragma mark - Planetary Hour Calculation definitions and enumerations

#define NUMBER_OF_PLANETS 7

typedef NS_ENUM(NSUInteger, Planet) {
    Sun,
    Moon,
    Mars,
    Mercury,
    Jupiter,
    Venus,
    Saturn
};

typedef NS_ENUM(NSUInteger, Day) {
    SUN,
    MON,
    TUE,
    WED,
    THU,
    FRI,
    SAT
};

typedef NS_ENUM(NSUInteger, Meridian) {
    AM,
    PM
};

NSString *(^planetSymbolForPlanet)(Planet) = ^(Planet planet) {
    planet = planet % NUMBER_OF_PLANETS;
    switch (planet) {
        case Sun:
            return @"☉";
            break;
        case Moon:
            return @"☽";
            break;
        case Mars:
            return @"♂︎";
            break;
        case Mercury:
            return @"☿";
            break;
        case Jupiter:
            return @"♃";
            break;
        case Venus:
            return @"♀︎";
            break;
        case Saturn:
            return @"♄";
            break;
        default:
            break;
    }
};

NSString *(^planetAbbreviatedNameForPlanet)(NSString *) = ^(NSString *planetName) {
    if ([planetName isEqualToString:@"Sun"])
        return @"SUN";
    if ([planetName isEqualToString:@"Moon"])
        return @"MOON";
    if ([planetName isEqualToString:@"Mars"])
        return @"MARS";
    if ([planetName isEqualToString:@"Mercury"])
        return @"MERC";
    if ([planetName isEqualToString:@"Jupiter"])
        return @"JPTR";
    if ([planetName isEqualToString:@"Venus"])
        return @"VENS";
    if ([planetName isEqualToString:@"Saturn"])
        return @"STRN";
    else
        return @"EARTH";
};


- (NSDate *)localDateForDate:(NSDate *)date
{
    NSCalendar *calendar             = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [calendar componentsInTimeZone:[NSTimeZone systemTimeZone] fromDate:date];
    dateComponents.timeZone          = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    dateComponents.calendar          = calendar;
    NSDate *currentTime              = [calendar dateFromComponents:dateComponents];
    
    return currentTime;
}

Planet(^planetForDay)(NSDate * _Nullable) = ^(NSDate * _Nullable date) {
    if (!date) date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    Planet planet = [calendar component:NSCalendarUnitWeekday fromDate:date] - 1;
    
    return planet;
};

Planet(^planetForHour)(NSDate * _Nullable, NSUInteger) = ^(NSDate * _Nullable date, NSUInteger hour) {
    hour = hour % HOURS_PER_DAY;
    Planet planet = (planetForDay(date) + hour) % NUMBER_OF_PLANETS;
    
    return planet;
};

NSString *(^planetNameForDay)(NSDate * _Nullable) = ^(NSDate * _Nullable date)
{
    Day day = (Day)planetForDay(date);
    switch (day) {
        case SUN:
            return @"Sun";
            break;
        case MON:
            return @"Moon";
            break;
        case TUE:
            return @"Mars";
            break;
        case WED:
            return @"Mercury";
            break;
        case THU:
            return @"Jupiter";
            break;
        case FRI:
            return @"Venus";
            break;
        case SAT:
            return @"Saturn";
            break;
        default:
            break;
    }
};

NSString *(^planetSymbolForDay)(NSDate * _Nullable) = ^(NSDate * _Nullable date) {
    return planetSymbolForPlanet(planetForDay(date));
};

NSString *(^planetNameForHour)(NSDate * _Nullable, NSUInteger) = ^(NSDate * _Nullable date, NSUInteger hour)
{
    switch (planetForHour(date, hour)) {
        case Sun:
            return @"Sun";
            break;
        case Moon:
            return @"Moon";
            break;
        case Mars:
            return @"Mars";
            break;
        case Mercury:
            return @"Mercury";
            break;
        case Jupiter:
            return @"Jupiter";
            break;
        case Venus:
            return @"Venus";
            break;
        case Saturn:
            return @"Saturn";
            break;
        default:
            break;
    }
};

NSString *(^planetSymbolForHour)(NSDate * _Nullable, NSUInteger) = ^(NSDate * _Nullable date, NSUInteger hour) {
    return planetSymbolForPlanet(planetForHour(date, hour));
};

typedef NS_ENUM(NSUInteger, PlanetColor) {
    Yellow,
    White,
    Red,
    Brown,
    Orange,
    Green,
    Grey
};

UIColor *(^colorForPlanetSymbol)(NSString *) = ^(NSString *planetarySymbol) {
    if ([planetarySymbol isEqualToString:@"☉"])
        return [UIColor yellowColor];
    else if ([planetarySymbol isEqualToString:@"☽"])
        return [UIColor whiteColor];
    else if ([planetarySymbol isEqualToString:@"♂︎"])
        return [UIColor redColor];
    else if ([planetarySymbol isEqualToString:@"☿"])
        return [UIColor brownColor];
    else if ([planetarySymbol isEqualToString:@"♃"])
        return [UIColor orangeColor];
    else if ([planetarySymbol isEqualToString:@"♀︎"])
        return [UIColor greenColor];
    else if ([planetarySymbol isEqualToString:@"♄"])
        return [UIColor grayColor];
    else
        return [UIColor whiteColor];
};

NSAttributedString *(^attributedPlanetSymbol)(NSString *) = ^(NSString *symbol) {
    NSMutableParagraphStyle *centerAlignedParagraphStyle  = [[NSMutableParagraphStyle alloc] init];
    centerAlignedParagraphStyle.alignment                 = NSTextAlignmentCenter;
    NSDictionary *centerAlignedTextAttributes             = @{NSForegroundColorAttributeName : colorForPlanetSymbol(symbol),
                                                              NSFontAttributeName            : [UIFont systemFontOfSize:48.0 weight:UIFontWeightBold],
                                                              NSParagraphStyleAttributeName  : centerAlignedParagraphStyle};
    
    NSAttributedString *attributedSymbol = [[NSAttributedString alloc] initWithString:symbol attributes:centerAlignedTextAttributes];
    
    return attributedSymbol;
};

#pragma Planetary Hour Calculation methods

- (NSArray<NSDate *> * _Nonnull (^)(NSDate * _Nonnull, CLLocation * _Nonnull))solarTransits
{
    return ^(NSDate *date, CLLocation *location)
    {
        NSArray<NSDate *> *solarTransits = calculateSolarData(date, location.coordinate);
        
        NSDate *earlierDate = [solarTransits[Sunrise] earlierDate:date];
        if ([earlierDate isEqualToDate:date])
        {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.day = -1;
            NSDate *yesterday = [calendar dateByAddingComponents:components toDate:date options:NSCalendarMatchNextTimePreservingSmallerUnits];
            NSArray<NSDate *> *newSolarTransits = calculateSolarData(yesterday, location.coordinate);
            
            return newSolarTransits;
        } else {
            // No changes to date necessary
            return solarTransits;
        }
    };
};

NSArray<NSNumber *> *(^planetaryHourDurations)(NSDate *, NSDate *, NSDate *) = ^(NSDate *sunrise, NSDate *sunset, NSDate *nextSunrise)
{
    NSTimeInterval daySpan             = [sunset timeIntervalSinceDate:sunrise];
    NSTimeInterval dayHourLength       = (daySpan / HOURS_PER_SOLAR_TRANSIT);
    NSTimeInterval nightSpan           = [nextSunrise timeIntervalSinceDate:sunset];
    NSTimeInterval nightHourLength     = (nightSpan / HOURS_PER_SOLAR_TRANSIT);
    NSArray<NSNumber *> *hourDurations = @[[NSNumber numberWithDouble:dayHourLength], [NSNumber numberWithDouble:nightHourLength]];
    
    return hourDurations;
};

- (NSDictionary * _Nonnull (^)(NSString * _Nonnull, NSString * _Nonnull, NSNumber * _Nonnull, NSString * _Nonnull, NSDate * _Nonnull, NSDate * _Nonnull, UIColor * _Nonnull))planetaryHourData
{
    return ^(NSString *symbol, NSString *name, NSNumber *hour, NSString *abbr, NSDate *start, NSDate *end, UIColor *color)
    {
        NSDictionary *planetaryHourProviderData = @{
                                                              @"symbol" : symbol,
                                                              @"name"   : name,
                                                              @"hour"   : hour,
                                                              @"abbr"   : abbr,
                                                              @"start"  : start,
                                                              @"end"    : end,
                                                              @"color"  : color
                                                              };
        
        return planetaryHourProviderData;
    };
};

- (CLLocation * _Nonnull (^)(CLLocation * _Nullable, NSDate * _Nullable, double, double, double, double, NSTimeInterval, NSUInteger))locatePlanetaryHour
{
    return ^(CLLocation * _Nullable location, NSDate * _Nullable date, double meters_per_second, double meters_per_day, double meters_per_day_hour, double meters_per_night_hour, NSTimeInterval timeOffset, NSUInteger hour)
    {
        MKMapPoint user_location_point = MKMapPointForCoordinate(location.coordinate);
        MKMapPoint planetary_hour_origin = MKMapPointMake(((hour < HOURS_PER_SOLAR_TRANSIT)
                                                          ? user_location_point.x + (meters_per_day_hour * hour)
                                                          : user_location_point.x + (meters_per_day + (meters_per_night_hour * (hour % 12))))
                                                          - (timeOffset * meters_per_second),
                                                          user_location_point.y);
        CLLocationCoordinate2D start_coordinate = MKCoordinateForMapPoint(planetary_hour_origin);
        CLLocation *planetaryHourLocation = [[CLLocation alloc] initWithLatitude:start_coordinate.latitude longitude:start_coordinate.longitude];

        return planetaryHourLocation;
    };
};

- (void (^)(CLLocation * _Nonnull, NSDate * _Nonnull, PlanetaryHourCompletionBlock _Nonnull))planetaryHours
{
    return ^(CLLocation *location, NSDate *date, PlanetaryHourCompletionBlock planetaryHour)
    {
        NSArray<NSDate *> *solarTransits     = PlanetaryHourDataSource.sharedDataSource.solarTransits(date, location);
        NSArray<NSDate *> *nextSolarTransits = PlanetaryHourDataSource.sharedDataSource.solarTransits([date dateByAddingTimeInterval:SECONDS_PER_DAY], location);
        NSArray<NSNumber *> *durations       = planetaryHourDurations(solarTransits[Sunrise], solarTransits[Sunset], nextSolarTransits[Sunrise]);
        
        // time
        NSTimeInterval seconds_in_day        = [solarTransits[Sunset] timeIntervalSinceDate:solarTransits[Sunrise]];
        NSTimeInterval seconds_in_night      = [nextSolarTransits[Sunrise] timeIntervalSinceDate:solarTransits[Sunset]];
        NSTimeInterval seconds_per_day       = seconds_in_day + seconds_in_night;
        // distance
        double map_points_per_second         = MKMapSizeWorld.width / seconds_per_day;
        double meters_per_second             = MKMetersPerMapPointAtLatitude(location.coordinate.latitude) * map_points_per_second;
        double meters_per_day                = seconds_in_day   * meters_per_second;
        double meters_per_night              = seconds_in_night * meters_per_second;

        double meters_per_day_hour           = meters_per_day   / HOURS_PER_SOLAR_TRANSIT;
        double meters_per_night_hour         = meters_per_night / HOURS_PER_SOLAR_TRANSIT;
        
        NSTimeInterval timeOffset            = [date timeIntervalSinceDate:solarTransits[Sunrise]];
        
        __block NSInteger hour = 0;
        __block dispatch_block_t planetaryHoursDictionaries;
        void(^planetaryHoursDictionary)(void) = ^(void) {
            Meridian meridian                 = (hour < HOURS_PER_SOLAR_TRANSIT) ? AM : PM;
            SolarTransit transit              = (hour < HOURS_PER_SOLAR_TRANSIT) ? Sunrise : Sunset;
            NSInteger mod_hour                = hour % 12;
            NSTimeInterval startTimeInterval  = durations[meridian].doubleValue * mod_hour;
            NSDate *startDate                 = [[NSDate alloc] initWithTimeInterval:startTimeInterval sinceDate:solarTransits[transit]];
            NSTimeInterval endTimeInterval    = durations[meridian].doubleValue * (mod_hour + 1);
            NSDate *endDate                   = [[NSDate alloc] initWithTimeInterval:endTimeInterval sinceDate:solarTransits[transit]];
            NSDateInterval *dateInterval      = [[NSDateInterval alloc] initWithStartDate:startDate endDate:endDate];
            
            NSAttributedString *symbol        = attributedPlanetSymbol(planetSymbolForHour(solarTransits[Sunrise], hour));
            NSString *name                    = planetNameForHour(solarTransits[Sunrise], hour);
            NSString *abbr                    = planetAbbreviatedNameForPlanet(name);
            UIColor *color                    = colorForPlanetSymbol([symbol string]);
            CLLocation *coordinate            = PlanetaryHourDataSource.sharedDataSource.locatePlanetaryHour(location, date, meters_per_second, meters_per_day, meters_per_day_hour, meters_per_night_hour, timeOffset, hour);
            planetaryHour(symbol, name, abbr, startDate, endDate, hour, color, coordinate,
                          (CLLocationDistance)((meridian == AM) ? meters_per_day_hour : meters_per_night_hour),
                          ([dateInterval containsDate:date]) ? YES : NO);
            
            hour++;
            if (hour < HOURS_PER_DAY)
                planetaryHoursDictionaries();
        };
        
        planetaryHoursDictionaries = ^{
            planetaryHoursDictionary();
        };
        planetaryHoursDictionaries();
    };
};

//- (void)planetaryHour:(PlanetaryHourCompletionBlock)planetaryHour
//{
//    NSArray<NSDate *> *solarTransits = [self solarCalculationForDate:[NSDate date] location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
//    NSTimeInterval daySpan         = [solarTransits[Sunset] timeIntervalSinceDate:solarTransits[Sunrise]];
//    NSArray<NSNumber *> *durations = hourDurations(daySpan);
//
//    __block NSInteger hour         = 0;
//    __block dispatch_block_t planetaryHoursDictionaries;
//
//    void(^planetaryHoursDictionary)(void) = ^(void) {
//        Meridian meridian                 = (hour < HOURS_PER_SOLAR_TRANSIT) ? AM : PM;
//        SolarTransit transit              = (hour < HOURS_PER_SOLAR_TRANSIT) ? Sunrise : Sunset;
//        NSInteger mod_hour                = hour % 12;
//        NSTimeInterval startTimeInterval  = durations[meridian].doubleValue * mod_hour;
//        NSDate *sinceDate                 = solarTransits[transit];
//        NSDate *startTime                 = [[NSDate alloc] initWithTimeInterval:startTimeInterval sinceDate:sinceDate];
//        NSTimeInterval endTimeInterval    = durations[meridian].doubleValue * (mod_hour + 1);
//        NSDate *endTime                   = [[NSDate alloc] initWithTimeInterval:endTimeInterval sinceDate:sinceDate];
//        NSDateInterval *dateInterval      = [[NSDateInterval alloc] initWithStartDate:startTime endDate:endTime];
//
//        NSAttributedString *symbol        = attributedPlanetSymbol(planetSymbolForHour(solarTransits[Sunrise], hour));
//        NSString *name                    = planetNameForHour(solarTransits[Sunrise], hour);
//        if ([dateInterval containsDate:[NSDate date]])
//        {
//            planetaryHour(symbol, name, startTime, endTime, hour, ([dateInterval containsDate:[NSDate date]]) ? YES : NO);
//            NSLog(@"CURRENT HOUR %ld", (long)hour);
//        } else {
//            hour++;
//            if (hour < HOURS_PER_DAY)
//                planetaryHoursDictionaries();
//        }
//    };
//
//    planetaryHoursDictionaries = ^{
//        planetaryHoursDictionary();
//    };
//    planetaryHoursDictionaries();
//}
//
//- (void)planetaryHoursForTimelineDirection:(PlanetaryHoursTimelineDirection)timelineDirection markerDate:(NSDate *)date completionBlock:(PlanetaryHoursRangeCompletionBlock)completionBlock
//{
//    NSArray<NSDate *> *solarTransits = [self solarCalculationForDate:[NSDate date] location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
//    NSTimeInterval daySpan         = [solarTransits[Sunset] timeIntervalSinceDate:solarTransits[Sunrise]];
//    NSArray<NSNumber *> *durations = hourDurations(daySpan);
//
//    int hour = 0;
//    for (int i = 0; i < HOURS_PER_DAY; i++)
//    {
//        Meridian meridian                 = (hour < HOURS_PER_SOLAR_TRANSIT) ? AM : PM;
//        SolarTransit transit              = (hour < HOURS_PER_SOLAR_TRANSIT) ? Sunrise : Sunset;
//        NSInteger mod_hour                = hour % 12;
//        NSTimeInterval startTimeInterval  = durations[meridian].doubleValue * mod_hour;
//        NSDate *sinceDate                 = solarTransits[transit];
//        NSDate *startTime                 = [[NSDate alloc] initWithTimeInterval:startTimeInterval sinceDate:sinceDate];
//        NSTimeInterval endTimeInterval    = durations[meridian].doubleValue * (mod_hour + 1);
//        NSDate *endTime                   = [[NSDate alloc] initWithTimeInterval:endTimeInterval sinceDate:sinceDate];
//        NSDateInterval *dateInterval      = [[NSDateInterval alloc] initWithStartDate:startTime endDate:endTime];
//
//        if ([dateInterval containsDate:date]) break;
//        else hour++;
//    }
//
//    int location = (timelineDirection == PlanetaryHoursTimelineDirectionForward) ? hour : 0;
//    int length   = (timelineDirection == PlanetaryHoursTimelineDirectionForward) ? HOURS_PER_DAY - location : location;
//    NSRange range = NSMakeRange(location, length);
//
//    completionBlock(range);
//}
//
//- (void)planetForHour:(NSUInteger)hour completionBlock:(PlanetaryHourCompletionBlock)planetaryHour
//{
//    NSArray<NSDate *> *solarTransits = [self solarCalculationForDate:[NSDate date] location:PlanetaryHourDataSource.sharedDataSource.locationManager.location];
//    NSTimeInterval daySpan         = [solarTransits[Sunset] timeIntervalSinceDate:solarTransits[Sunrise]];
//    NSArray<NSNumber *> *durations = hourDurations(daySpan);
//
//    Meridian meridian                 = (hour < HOURS_PER_SOLAR_TRANSIT) ? AM : PM;
//    SolarTransit transit              = (hour < HOURS_PER_SOLAR_TRANSIT) ? Sunrise : Sunset;
//    NSInteger mod_hour                = hour % 12;
//    NSTimeInterval startTimeInterval  = durations[meridian].doubleValue * mod_hour;
//    NSDate *sinceDate                 = solarTransits[transit];
//    NSDate *startTime                 = [[NSDate alloc] initWithTimeInterval:startTimeInterval sinceDate:sinceDate];
//    NSTimeInterval endTimeInterval    = durations[meridian].doubleValue * (mod_hour + 1);
//    NSDate *endTime                   = [[NSDate alloc] initWithTimeInterval:endTimeInterval sinceDate:sinceDate];
//    NSDateInterval *dateInterval      = [[NSDateInterval alloc] initWithStartDate:startTime endDate:endTime];
//
//    NSAttributedString *symbol        = attributedPlanetSymbol(planetSymbolForHour(solarTransits[Sunrise], hour));
//    NSString *name                    = planetNameForHour(solarTransits[Sunrise], hour);
//    planetaryHour(symbol, name, startTime, endTime, hour, ([dateInterval containsDate:[NSDate date]]) ? YES : NO);
//}

@end



