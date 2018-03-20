# Sample Implementation for iOS Scheduler in Objective-C


## Description:

This document explains how to **develop Automatic Scheduling in iOS**:



*   Automatic Scheduling Manager contains the **business logic** to turn drive detection on and off. One key assumption is that a drive has weekday shifts and will not be tracked on weekends
*   The **downside** for this approach is that the the SDK accuracy will likely be impacted. Specifically, the switch to drive detection mode AutoOn may be significantly delayed because the iOS application will generally be in the suspended state until there's a significant location change, which generally happens on cellular tower switch and/or wifi endpoint change.
    *   Although rarely, this may **lead to delayed trip start detection** (by a few miles) for the first trip after the weekend (which is the start of working schedule).
    *   Once ZendriveSDK is in AutoOn mode, it **will ensure that application wakes up** whenever required to detect trips.


## Implementation Tips:



*   Drop the AutomaticSchedulingManager into your application
*   Ensure that ZendriveSDK is setup with correct drive detection mode on application start
*   Ensure that ZendriveDriveDetectionMode is correctly set to AutoOn/AutoOff whenever schedule switches in AutomaticSchedulingManager. Check setDriveDetectionModeAndResetSwitchTask of AutomaticSchedulingManager.
*   Questions? Please reach out to [support@zendrive.com](mailto:support@zendrive.com)


## Recommended Test Plan:


#### Test Requirements


*   Atleast 5 Drivers/Test-Users
*   Minimum 30 mins of driving everyday 
*   Test should run continuously for 7 days


#### Testing Instructions (for each user)



*   Install the application containing the scheduler
*   Setup the application with user info and provide "Always Allow" location permission to the application
*   Test for a week (including weekend)


#### Expected Result

 All the trips within the weekdays (Monday - Friday) will be recorded but no trips will be recorded over the weekend (Saturday - Sunday)
