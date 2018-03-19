## **Sample Implementation for iOS Scheduler in Objective-C**

### **Description:**

This document explains how to **develop Automatic Scheduling in iOS** :

- Automatic Scheduling Manager contains the **business logic** to turn on/off drive detection. It assumes that the user works on weekdays and does not want to be tracked over the weekend.
- The **trade-off** f this approach is that the switch to drive detection mode AutoOn may have a lot of delay because the iOS application will generally be in the suspended state until there&#39;s a significant location change, which generally happens on cellular tower switch and/or wifi endpoint changes.

- Although rarely, this may **lead to delayed trip start detection** (by a few miles) for first trip on Monday (which is the start of working schedule).
- Once ZendriveSDK is in AutoOn mode, it **will ensure that application wakes up** whenever required to detect trips.

### **How to use:**

- Drop the AutomaticSchedulingManager in your application
- Ensure that ZendriveSDK is setup with correct drive detection mode on application start
- Ensure that ZendriveDriveDetectionMode is correctly set to AutoOn/AutoOff whenever schedule switches in AutomaticSchedulingManager. Check setDriveDetectionModeAndResetSwitchTask of AutomaticSchedulingManager.
