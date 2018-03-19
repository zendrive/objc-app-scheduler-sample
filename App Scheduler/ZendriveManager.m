//
//  ZendriveManager.m
//  App Scheduler
//
//  Copyright © 2018 Zendrive. All rights reserved.
//

#import "ZendriveManager.h"
#import <ZendriveSDK/Zendrive.h>
#import "AutomaticSchedulingManager.h"

static ZendriveManager *_sharedInstance;
@interface ZendriveManager()<ZendriveDelegateProtocol>

@end

@implementation ZendriveManager

+ (ZendriveManager * )sharedInstance {
    @synchronized (self) {
        if (!_sharedInstance) {
            _sharedInstance = [[ZendriveManager alloc] init];
        }
        return _sharedInstance;
    }
}

//------------------------------------------------------------------------------
#pragma mark - setup-teardown
//------------------------------------------------------------------------------
- (void)initializeZendriveSDKWithSuccessBlock:(void (^)(void))successBlock
                                 failureBlock:(void (^)(NSError *))failureBlock {
    ZendriveConfiguration *configuration = [[ZendriveConfiguration alloc] init];
    configuration.applicationKey = @"your-sdk-key"; // Replace with your Zendrive sdk key
    if ([[AutomaticSchedulingManager sharedInstance] shouldUserBeOnDuty]) {
        configuration.driveDetectionMode = ZendriveDriveDetectionModeAutoON;
    }
    else {
        configuration.driveDetectionMode = ZendriveDriveDetectionModeAutoOFF;
    }
    configuration.driverId = @"your-driver-id"; // Maybe user email?

    [Zendrive
     setupWithConfiguration:configuration delegate:self
     completionHandler: ^(BOOL success, NSError *error) {
         @synchronized(self) {
             if(error) {
                 NSLog(@"[ZendriveManager]: setupWithConfiguration:error: %@",
                       error.localizedFailureReason);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (failureBlock) {
                         failureBlock(error);
                     }
                 });
             } else {
                 NSLog(@"[ZendriveManager]: setupWithConfiguration:success");
                 ZendriveDriveDetectionMode driveDetectionMode;
                 if ([[AutomaticSchedulingManager sharedInstance] shouldUserBeOnDuty]) {
                     driveDetectionMode = ZendriveDriveDetectionModeAutoON;
                 }
                 else {
                     driveDetectionMode = ZendriveDriveDetectionModeAutoOFF;
                 }
                 [Zendrive setDriveDetectionMode:driveDetectionMode];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (successBlock) {
                         successBlock();
                     }
                 });
             }
         }
     }];
}

- (void)enableDriveTrackingWithSuccessHandler:(void (^)(void))successBlock
                            andFailureHandler:(void (^)(NSError *))failureBlock {
    @synchronized(self) {
        if ([Zendrive isSDKSetup]) {
            [Zendrive setDriveDetectionMode:ZendriveDriveDetectionModeAutoON];
            if (successBlock) {
                successBlock();
            }
            return;
        }

        [self initializeZendriveSDKWithSuccessBlock:successBlock failureBlock:failureBlock];
    }
}

- (void)disableDriveTracking {
    @synchronized(self) {
        NSLog(@"[ZendriveManager]: disableDriveTracking");
        [Zendrive setDriveDetectionMode:ZendriveDriveDetectionModeAutoOFF];
    }
}

#pragma mark - ZendriveDelegateProtocol

- (void)processStartOfDrive:(ZendriveDriveStartInfo *)startInfo {
    NSLog(@"Start of Drive invoked");
}

- (void)processResumeOfDrive:(ZendriveDriveResumeInfo *)drive {
    NSLog(@"Resume of Drive invoked");
}

- (void)processEndOfDrive:(ZendriveDriveInfo *)drive {
    NSLog(@"End of Drive invoked");
}

- (void)processLocationDenied {
    NSLog(@"User denied Location to Zendrive SDK.");
}

- (void)processLocationApproved   {
    NSLog(@"User approved Location to Zendrive SDK.");
}

- (void)processAccidentDetected:(ZendriveAccidentInfo *)accidentInfo {
    NSLog(@"Accident detected by Zendrive SDK.");
}

@end
