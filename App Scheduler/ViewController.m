//
//  ViewController.m
//  App Scheduler
//
//  Copyright © 2018 Zendrive. All rights reserved.
//

#import "ViewController.h"
#import "ZendriveManager.h"
#import "AutomaticSchedulingManager.h"

@interface ViewController ()
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [[ZendriveManager sharedInstance] initializeZendriveSDKWithSuccessBlock:^{
        NSLog(@"ZendriveSDK initialized");
    } failureBlock:^(NSError *error) {
        NSLog(@"ZendriveSDK initialization failed");
    }];
    [[AutomaticSchedulingManager sharedInstance] enableSchedulingManager];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
