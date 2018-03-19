//
//  SignificantLocationManager.h
//  App Scheduler
//
//  Copyright © 2018 Zendrive. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SignificantLocationManagerDelegate

- (void)didReceiveSignificantLocationUpdate;
@end

@interface SignificantLocationManager : NSObject

@property (nonatomic, weak) NSObject<SignificantLocationManagerDelegate> *delegate;

- (instancetype)initWithDelegate:(NSObject<SignificantLocationManagerDelegate> *)delegate;
- (void)startMonitoringSignificantLocationUpdates;
- (void)stopMonitoringSignificantLocationUpdates;
@end
