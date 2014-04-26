//
//  AppDelegate.m
//  BLE-Lock
//
//  Created by Bastian Kohlbauer on 21.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import "AppDelegate.h"

#import "RFduinoManager.h"
#import "RFduino.h"

//#define UDID @"4CCC5638-0957-15E7-1EB4-96F0D9C61AB3"
#define SWITCH_STATE @"com.Bastian-Kohlbauer.BLE-Lock.switchState"
#define DEVICEIDKEY @"com.Bastian-Kohlbauer.BLE-Lock.deviceIDKey"

@interface AppDelegate()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _rfduinoManager = [RFduinoManager sharedRFduinoManager];
    _rfduinoManager.delegate = self;
    
    _viewController = [[ViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_viewController];
    [self.window setRootViewController:navController];
        
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    /*
    wasScanning = false;
    
    if (rfduinoManager.isScanning)
    {
        wasScanning = true;
        [rfduinoManager stopScan];
    }
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    /*
    if (wasScanning && [[[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_STATE] boolValue] == YES)
    {
        [rfduinoManager startScan];
        wasScanning = false;
    }
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - RfduinoDiscoveryDelegate methods

- (void)didDiscoverRFduino:(RFduino *)rfduino
{
    NSLog(@"didDiscoverRFduino");
    
    NSString *deviceID = [[NSUserDefaults standardUserDefaults] objectForKey:DEVICEIDKEY];
    if (deviceID.length == 0) return;
    
    //if (!rfduino.outOfRange && [rfduino.UUID isEqualToString:UDID]) {
    if (!rfduino.outOfRange && [rfduino.UUID isEqualToString:deviceID]) {
        [_rfduinoManager connectRFduino:rfduino];
    }
}

- (void)didUpdateDiscoveredRFduino:(RFduino *)rfduino
{
    NSLog(@"didUpdateRFduino");
    
}

- (void)didConnectRFduino:(RFduino *)rfduino
{
    NSLog(@"didConnectRFduino");
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //AudioServicesPlaySystemSound(1100);
    [_viewController performSelector:@selector(speechOutput:) withObject:@"Device Connected" afterDelay:0.5];
    
    _viewController.newrfduino = rfduino;
    [_viewController.newrfduino setDelegate:_viewController];
    
    [_viewController.reset setHidden:NO];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_STATE] boolValue] == YES) [_viewController.radar stopAnimating];
    [_viewController.progress setHidden:_viewController.radar.isAnimating];
    [_viewController.statsLabel setHidden:_viewController.radar.isAnimating];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_STATE] boolValue] == YES) [_rfduinoManager stopScan];
}

- (void)didLoadServiceRFduino:(RFduino *)rfduino
{
    NSLog(@"didLoadServiceRFduino");
}

- (void)didDisconnectRFduino:(RFduino *)rfduino
{
    NSLog(@"didDisconnectRFduino");
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //AudioServicesPlaySystemSound(1100);
    [_viewController performSelector:@selector(speechOutput:) withObject:@"Device Disconnected" afterDelay:0.5];
    
    [_viewController.reset setHidden:YES];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_STATE] boolValue] == YES)[_viewController.radar startAnimating];
    [_viewController.progress setHidden:_viewController.radar.isAnimating];
    [_viewController.statsLabel setHidden:_viewController.radar.isAnimating];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_STATE] boolValue] == YES) [_rfduinoManager startScan];
}

@end
