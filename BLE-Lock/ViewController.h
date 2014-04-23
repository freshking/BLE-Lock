//
//  ViewController.h
//  BLE-Lock
//
//  Created by Bastian Kohlbauer on 21.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BKRadar.h"
#import "RFduino.h"

@interface ViewController : UIViewController <RFduinoDelegate>

- (void)speechOutput:(NSString*)text;

@property (strong, nonatomic) RFduino *newrfduino;
@property (nonatomic, strong) BKRadar *radar;
@property (nonatomic, strong) UIProgressView *progress;
@property (nonatomic, strong) UISwitch *switchSelector;
@property (nonatomic, strong) UILabel *statsLabel;
@property (nonatomic, strong) UIButton *reset;

@end
