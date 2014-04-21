//
//  ViewController.h
//  BLE-Lock
//
//  Created by Bastian Kohlbauer on 21.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFduinoManagerDelegate.h"

@class RFduinoManager;
@class RFduino;

@interface ViewController : UIViewController <RFduinoManagerDelegate>
{
    RFduinoManager *rfduinoManager;
}

@property (nonatomic, strong) RFduino *rfduino;

@end
