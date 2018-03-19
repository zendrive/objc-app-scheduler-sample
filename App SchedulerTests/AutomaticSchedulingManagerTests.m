//
//  App_SchedulerTests.m
//  App SchedulerTests
//
//  Created by Alejandro Ponce on 3/6/18.
//  Copyright © 2018 Zendrive. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AutomaticSchedulingManager.h"
#import "SignificantLocationManager.h"
#import "AppPeriodicTask.h"
#import <OCMock/OCMock.h>

@interface AutomaticSchedulingManager()

@property (nonatomic) SignificantLocationManager *significantLocationManager;
@property (nonatomic) AppPeriodicTask *nextExecutionTask;

@property (nonatomic) BOOL isEnabled;

- (void)setDriveDetectionModeAndResetSwitchTask;
- (NSTimeInterval)nextOnDutyTimeDiff:(NSDate *)currentDate;
- (NSTimeInterval)nextOffDutyTimeDiff:(NSDate *)currentDate;
- (NSTimeInterval)nextOffDutyTimeDiff;
@end

@interface AutomaticSchedulingManagerTests : XCTestCase

@end

@implementation AutomaticSchedulingManagerTests

- (void)setUp {
    [super setUp];
    [AutomaticSchedulingManager teardown];
}

- (void)tearDown {
    [AutomaticSchedulingManager teardown];
    [super tearDown];
}

- (void)testNextOnDutyTimeDiff {
    // Setup
    AutomaticSchedulingManager *automaticSchedulingManager = [AutomaticSchedulingManager sharedInstance];

    for (int weekday = 2; weekday < 7; weekday++) {
        // Execute
        NSDate *date = [self nextDateForWeekday:weekday];
        NSTimeInterval timeDiff = [automaticSchedulingManager nextOnDutyTimeDiff:date];

        // Validate
        XCTAssertTrue(timeDiff == 0, @"Incorrect time diff");
    }

    NSDate *date = [self nextDateForWeekday:1];
    NSTimeInterval timeDiff = [automaticSchedulingManager nextOnDutyTimeDiff:date];

    // Validate
    XCTAssertTrue(timeDiff == 24*60*60, @"Incorrect time diff");

    date = [self nextDateForWeekday:7];
    timeDiff = [automaticSchedulingManager nextOnDutyTimeDiff:date];

    // Validate
    XCTAssertTrue(timeDiff == 2*24*60*60, @"Incorrect time diff");
}

- (void)testNextOffDutyTimeDiff {
    // Setup
    AutomaticSchedulingManager *automaticSchedulingManager = [AutomaticSchedulingManager sharedInstance];

    for (int weekday = 2; weekday < 7; weekday++) {
        // Execute
        NSDate *date = [self nextDateForWeekday:weekday];
        NSTimeInterval timeDiff = [automaticSchedulingManager nextOffDutyTimeDiff:date];

        // Validate
        XCTAssertTrue(timeDiff == (7 - weekday)*24*60*60, @"Incorrect time diff");
    }

    NSDate *date = [self nextDateForWeekday:1];
    NSTimeInterval timeDiff = [automaticSchedulingManager nextOffDutyTimeDiff:date];

    // Validate
    XCTAssertTrue(timeDiff == 0, @"Incorrect time diff");

    date = [self nextDateForWeekday:7];
    timeDiff = [automaticSchedulingManager nextOffDutyTimeDiff:date];

    // Validate
    XCTAssertTrue(timeDiff == 0, @"Incorrect time diff");
}

- (void)testShouldUserBeOndutyTrue {
    // Setup
    id asmMock = [OCMockObject partialMockForObject:[AutomaticSchedulingManager sharedInstance]];
    [[[[asmMock stub] andReturn:asmMock] classMethod] sharedInstance];
    [[[asmMock stub] andReturnValue:OCMOCK_VALUE(0)] nextOnDutyTimeDiff:[OCMArg any]];

    // Execute
    BOOL shouldUserBeOnduty = [asmMock shouldUserBeOnDuty];

    // Validate
    XCTAssertTrue(shouldUserBeOnduty, @"User not onduty even in Onduty time");

    // Teardown
    [asmMock stopMocking];
}

- (void)testShouldUserBeOndutyFalse {
    // Setup
    id asmMock = [OCMockObject partialMockForObject:[AutomaticSchedulingManager sharedInstance]];
    [[[[asmMock stub] andReturn:asmMock] classMethod] sharedInstance];
    [[[asmMock stub] andReturnValue:OCMOCK_VALUE(10000)] nextOnDutyTimeDiff:[OCMArg any]];

    // Execute
    BOOL shouldUserBeOnduty = [asmMock shouldUserBeOnDuty];

    // Validate
    XCTAssertFalse(shouldUserBeOnduty, @"User onduty even in Offduty time");

    // Teardown
    [asmMock stopMocking];
}

- (void)testSetDriveDetectionModeAndResetSwitchTaskOn {
    // Setup
    AutomaticSchedulingManager *autoSchManager = [AutomaticSchedulingManager sharedInstance];
    id asmMock = [OCMockObject partialMockForObject:autoSchManager];
    [[[[asmMock stub] andReturn:asmMock] classMethod] sharedInstance];
    [[[asmMock stub] andReturnValue:OCMOCK_VALUE(YES)] isEnabled];
    [[[asmMock stub] andReturnValue:OCMOCK_VALUE(YES)] shouldUserBeOnDuty];
    [[[asmMock stub] andReturnValue:OCMOCK_VALUE(10000)] nextOffDutyTimeDiff:[OCMArg any]];

    AppPeriodicTask *task = [[AppPeriodicTask alloc] init];
    id mockTask = [OCMockObject partialMockForObject:task];
    [[[[mockTask expect] classMethod] andForwardToRealObject]
     scheduleBlock:[OCMArg any] onQueue:[OCMArg any] afterDelaySeconds:10000];

    [[[asmMock expect] andForwardToRealObject] setNextExecutionTask:[OCMArg any]];

    // Execute
    [asmMock setDriveDetectionModeAndResetSwitchTask];

    // Verify
    [asmMock verify];
    [mockTask verify];

    // Teardown
    [asmMock stopMocking];
    [mockTask stopMocking];
}

- (void)testSetDriveDetectionModeAndResetSwitchTaskOff {
    // Setup
    AutomaticSchedulingManager *autoSchManager = [AutomaticSchedulingManager sharedInstance];
    id asmMock = [OCMockObject partialMockForObject:autoSchManager];
    [[[[asmMock stub] andReturn:asmMock] classMethod] sharedInstance];
    [[[asmMock stub] andReturnValue:OCMOCK_VALUE(YES)] isEnabled];
    [[[asmMock stub] andReturnValue:OCMOCK_VALUE(NO)] shouldUserBeOnDuty];
    [[[asmMock stub] andReturnValue:OCMOCK_VALUE(10000)] nextOnDutyTimeDiff:[OCMArg any]];

    AppPeriodicTask *task = [[AppPeriodicTask alloc] init];
    id mockTask = [OCMockObject partialMockForObject:task];
    [[[[mockTask expect] classMethod] andForwardToRealObject]
     scheduleBlock:[OCMArg any] onQueue:[OCMArg any] afterDelaySeconds:10000];

    [[[asmMock expect] andForwardToRealObject] setNextExecutionTask:[OCMArg any]];

    // Execute
    [asmMock setDriveDetectionModeAndResetSwitchTask];

    // Verify
    [asmMock verify];
    [mockTask verify];

    // Teardown
    [asmMock stopMocking];
    [mockTask stopMocking];
}

- (void)testEnableSchedulingManager {
    // Setup
    AutomaticSchedulingManager *autoSchManager = [AutomaticSchedulingManager sharedInstance];
    id asmMock = [OCMockObject partialMockForObject:autoSchManager];
    [[[[asmMock stub] andReturn:asmMock] classMethod] sharedInstance];

    [[[asmMock expect] andForwardToRealObject] setSignificantLocationManager:[OCMArg any]];

    __block id significantLocationManagerMock = [OCMockObject partialMockForObject:
                                                 [[SignificantLocationManager alloc] init]];
    [[[asmMock stub] andReturn:significantLocationManagerMock] significantLocationManager];
    [[significantLocationManagerMock expect] startMonitoringSignificantLocationUpdates];

    // Execute
    [asmMock enableSchedulingManager];

    // Verify
    [asmMock verify];
    [significantLocationManagerMock verify];
    XCTAssertTrue([asmMock isEnabled], @"Not enabled after enableSchedulingManager call");

    // Teardown
    [asmMock stopMocking];
    [significantLocationManagerMock stopMocking];
}

- (void)testDisableSchedulingManager {
    // Setup
    AutomaticSchedulingManager *autoSchManager = [AutomaticSchedulingManager sharedInstance];
    id asmMock = [OCMockObject partialMockForObject:autoSchManager];
    [[[[asmMock stub] andReturn:asmMock] classMethod] sharedInstance];

    [[[asmMock expect] andForwardToRealObject]
     setSignificantLocationManager:[OCMArg checkWithBlock:^BOOL(id obj) {
        return (obj == nil);
    }]];

    __block id significantLocationManagerMock = [OCMockObject partialMockForObject:
                                                 [[SignificantLocationManager alloc] init]];
    [[[asmMock stub] andReturn:significantLocationManagerMock] significantLocationManager];
    [[significantLocationManagerMock expect] stopMonitoringSignificantLocationUpdates];

    // Execute
    [asmMock enableSchedulingManager];
    [asmMock disableSchedulingManager];

    // Verify
    [asmMock verify];
    [significantLocationManagerMock verify];
    XCTAssertFalse([asmMock isEnabled], @"Enabled after disableSchedulingManager call");
    XCTAssertNil([asmMock nextExecutionTask], @"Did not reset nextExecutionTask");

    // Teardown
    [asmMock stopMocking];
    [significantLocationManagerMock stopMocking];
}

//------------------------------------------------------------------------------
#pragma mark - Utils
//------------------------------------------------------------------------------
- (NSDate *)nextDateForWeekday:(int)weekday {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday|NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitTimeZone fromDate:now];

    NSUInteger weekdayToday = [components weekday];
    NSInteger daysToWeekday = (7 + weekday - weekdayToday) % 7;
    NSDate *startDate = [calendar dateFromComponents:components];
    return [calendar dateByAddingUnit:NSCalendarUnitDay value:daysToWeekday
                               toDate:startDate options:0];
}

@end
