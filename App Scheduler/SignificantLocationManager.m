//
//  SignificantLocationManager.m
//  App Scheduler
//
//  Copyright © 2018 Zendrive. All rights reserved.
//

#import "SignificantLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface SignificantLocationManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation SignificantLocationManager

- (instancetype)initWithDelegate:(NSObject<SignificantLocationManagerDelegate> *)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;

        // Paused updates are not resumed until app launches
        // into foreground. So disable automatic pause.
        _locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    return self;
}

- (void)startMonitoringSignificantLocationUpdates {
    [_locationManager startMonitoringSignificantLocationChanges];
    NSLog(@"[SignificantLocationManager]: Started monitoring significant location changes");
}

- (void)stopMonitoringSignificantLocationUpdates {
    [_locationManager stopMonitoringSignificantLocationChanges];
    NSLog(@"[SignificantLocationManager]: Stopped monitoring significant location changes");
}

//------------------------------------------------------------------------------
#pragma mark - CLLocationManagerDelegate
//------------------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"[SignificantLocationManager]: Significant location update received");
    if (self.delegate && [self.delegate
                          respondsToSelector:@selector(didReceiveSignificantLocationUpdate)]) {
        [self.delegate didReceiveSignificantLocationUpdate];
    }
}
@end
