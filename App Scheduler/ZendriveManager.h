//
//  ZendriveManager.h
//  App Scheduler
//
//  Copyright © 2018 Zendrive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZendriveManager : NSObject

+ (ZendriveManager * )sharedInstance;
- (void)initializeZendriveSDKWithSuccessBlock:(void(^)(void))successBlock
                                 failureBlock:(void(^)(NSError *error))failureBlock;
- (void)enableDriveTrackingWithSuccessHandler:(void (^)(void))successBlock
                            andFailureHandler:(void (^)(NSError *error))failureBlock;
- (void)disableDriveTracking;
@end
