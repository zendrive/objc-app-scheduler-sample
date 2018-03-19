//
//  AutomaticSchedulingManager.h
//  App Scheduler
//
//  Copyright © 2018 Zendrive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutomaticSchedulingManager : NSObject

+ (AutomaticSchedulingManager *)sharedInstance;
+ (void)teardown;
- (BOOL)shouldUserBeOnDuty;
- (void)enableSchedulingManager;
- (void)disableSchedulingManager;
@end
