//
//  AutomaticSchedulingManager.m
//  App Scheduler
//
//  Copyright © 2018 Zendrive. All rights reserved.
//

#import "AutomaticSchedulingManager.h"
#import "ZendriveManager.h"
#import "AppPeriodicTask.h"
#import "SignificantLocationManager.h"

typedef enum {
    WeekdaySunday = 1,
    WeekdayMonday,
    WeekdayTuesday,
    WeekdayWednesday,
    WeekdayThursday,
    WeekdayFriday,
    WeekdaySaturday
} Weekday;

static const NSTimeInterval kSecondsInADay = 24*60*60;
AutomaticSchedulingManager *_sharedInstance;

@interface AutomaticSchedulingManager()<SignificantLocationManagerDelegate>

@property (nonatomic) SignificantLocationManager *significantLocationManager;
@property (nonatomic) AppPeriodicTask *nextExecutionTask;

@property (nonatomic) BOOL isEnabled;
@end

@implementation AutomaticSchedulingManager

+ (AutomaticSchedulingManager *)sharedInstance {
    @synchronized(self) {
        if (!_sharedInstance) {
            _sharedInstance = [[AutomaticSchedulingManager alloc] init];
        }
        return _sharedInstance;
    }
}

+ (void)teardown {
    @synchronized(self) {
        [_sharedInstance disableSchedulingManager];
        _sharedInstance = nil;
    }
}

//------------------------------------------------------------------------------
#pragma mark - Instance methods
//------------------------------------------------------------------------------
- (instancetype)init {
    self = [super init];
    if (self) {
        _isEnabled = NO;
    }
    return self;
}

- (void)enableSchedulingManager {
    if (self.isEnabled) {
        return;
    }

    self.isEnabled = YES;
    [self setDriveDetectionModeAndResetSwitchTask];

    // This is used as a backup to reset driveDetectionMode if we don't get any opportunity
    // to do so
    self.significantLocationManager = [[SignificantLocationManager alloc] initWithDelegate:self];
    [self.significantLocationManager startMonitoringSignificantLocationUpdates];
}

- (void)disableSchedulingManager {
    if (!self.isEnabled) {
        return;
    }
    [self.nextExecutionTask cancel];
    self.nextExecutionTask = nil;
    [self.significantLocationManager stopMonitoringSignificantLocationUpdates];
    self.significantLocationManager = nil;
    self.isEnabled = NO;
}

- (void)setDriveDetectionModeAndResetSwitchTask {
    if (!self.isEnabled) {
        // Skip if not enabled
        return;
    }
    NSTimeInterval nextExecutionTimeDiff;
    if ([self shouldUserBeOnDuty]) {
        [[ZendriveManager sharedInstance]
         enableDriveTrackingWithSuccessHandler:nil
         andFailureHandler:^(NSError *error) {
             // Display error to user (and retry in a few mins)
        }];
        nextExecutionTimeDiff = [self nextOffDutyTimeDiff];
    }
    else {
        [[ZendriveManager sharedInstance] disableDriveTracking];
        nextExecutionTimeDiff = [self nextOnDutyTimeDiff];
    }

    __weak AutomaticSchedulingManager *weakself = self;
    self.nextExecutionTask = [AppPeriodicTask scheduleBlock:^(AppPeriodicTask *task) {
        AutomaticSchedulingManager *strongself = weakself;
        [strongself setDriveDetectionModeAndResetSwitchTask];
    } onQueue:dispatch_get_main_queue() afterDelaySeconds:nextExecutionTimeDiff];
}

- (BOOL)shouldUserBeOnDuty {
    return ([self nextOnDutyTimeDiff] <= 0);
}

- (NSTimeInterval)nextOnDutyTimeDiff {
    return [self nextOnDutyTimeDiff:[NSDate date]];
}

- (NSTimeInterval)nextOnDutyTimeDiff:(NSDate *)currentDate {
    // Assuming weekday working schedule
    NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents =
    [cal components:NSCalendarUnitWeekday|NSCalendarUnitDay|
     NSCalendarUnitMonth|NSCalendarUnitYear fromDate:currentDate];
    if (dateComponents.weekday != WeekdaySunday &&
        dateComponents.weekday != WeekdaySaturday) {
        return 0;
    }
    else {
        int daysDiff = 0;
        if (dateComponents.weekday == WeekdaySunday) {
            daysDiff = 1;
        }
        else {
            // Saturday
            daysDiff = 2;
        }
        return [[[cal dateFromComponents:dateComponents]
                 dateByAddingTimeInterval:daysDiff*kSecondsInADay]
                timeIntervalSinceDate:currentDate];
    }
}

- (NSTimeInterval)nextOffDutyTimeDiff {
    // Assuming weekday working schedule
    return [self nextOffDutyTimeDiff:[NSDate date]];
}

- (NSTimeInterval)nextOffDutyTimeDiff:(NSDate *)currentDate {
    // Assuming weekday working schedule
    NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents =
    [cal components:NSCalendarUnitWeekday|NSCalendarUnitDay|
     NSCalendarUnitMonth|NSCalendarUnitYear fromDate:currentDate];
    if (dateComponents.weekday == WeekdaySunday || dateComponents.weekday == WeekdaySaturday) {
        return 0;
    }
    else {
        long daysDiff = 7 - dateComponents.weekday;
        return [[[cal dateFromComponents:dateComponents]
                 dateByAddingTimeInterval:daysDiff*kSecondsInADay]
                timeIntervalSinceDate:currentDate];
    }
}

//------------------------------------------------------------------------------
#pragma mark - SignificantLocationManagerDelegate
//------------------------------------------------------------------------------
- (void)didReceiveSignificantLocationUpdate {
    [self setDriveDetectionModeAndResetSwitchTask];
}

@end
