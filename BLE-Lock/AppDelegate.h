//
//  AppDelegate.h
//  BLE-Lock
//
//  Created by Bastian Kohlbauer on 21.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFduinoManagerDelegate.h"
#import "ViewController.h"

@class RFduinoManager;
@class RFduino;

@interface AppDelegate : UIResponder <UIApplicationDelegate,RFduinoManagerDelegate>
{
    //RFduinoManager *rfduinoManager;
    //bool wasScanning;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RFduinoManager *rfduinoManager;
@property (strong, nonatomic) ViewController *viewController;

@end
