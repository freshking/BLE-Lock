//
//  ViewController.m
//  BLE-Lock
//
//  Created by Bastian Kohlbauer on 21.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "RFduinoManager.h"
#import "RFduino.h"

#define UDID @"4CCC5638-0957-15E7-1EB4-96F0D9C61AB3"

@interface ViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIProgressView *progress;
@end

@implementation ViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        rfduinoManager = [RFduinoManager sharedRFduinoManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    rfduinoManager.delegate = self;
    rfduinoManager
    
    _progress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    _progress.frame = CGRectMake(0.0, 0.0, 150.0, 20.0);
    _progress.center = self.view.center;
    _progress.progressViewStyle = UIProgressViewStyleDefault;
    _progress.progressTintColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    [self.view addSubview:_progress];
    
    [_progress setHidden:YES];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator.center = self.view.center;
    [_indicator setHidesWhenStopped:YES];
    [self.view addSubview:_indicator];
    
    [_indicator startAnimating];
    
    
    //AudioServicesPlaySystemSound(1007); // sms received
    //AudioServicesPlaySystemSound(1304); // alarm
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RfduinoDiscoveryDelegate methods

- (void)didDiscoverRFduino:(RFduino *)rfduino
{
    NSLog(@"didDiscoverRFduino");
    
    if (!rfduino.outOfRange && [rfduino.UUID isEqualToString:UDID]) {
        _rfduino = rfduino;
        [rfduinoManager connectRFduino:_rfduino];
    }
}

- (void)didUpdateDiscoveredRFduino:(RFduino *)rfduino
{
    NSLog(@"didUpdateRFduino");
    [self calculateSignalStrength];
}

- (void)didConnectRFduino:(RFduino *)rfduino
{
    NSLog(@"didConnectRFduino");
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //AudioServicesPlaySystemSound(1100);
    [self performSelector:@selector(speechOutput:) withObject:@"Device Connected" afterDelay:0.5];
    
    [_indicator stopAnimating];
    [_progress setHidden:_indicator.isAnimating];
    [rfduinoManager stopScan];
    [self calculateSignalStrength];
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
    [self performSelector:@selector(speechOutput:) withObject:@"Device Disconnected" afterDelay:0.5];
    
    _rfduino = nil;
    [_indicator startAnimating];
    [_progress setHidden:_indicator.isAnimating];
    [rfduinoManager startScan];
}

#pragma mark - Provate Methods

- (void)calculateSignalStrength
{
    int rssi = _rfduino.advertisementRSSI.intValue;
    
    NSString *advertising = @"";
    if (_rfduino.advertisementData) {
        advertising = [[NSString alloc] initWithData:_rfduino.advertisementData encoding:NSUTF8StringEncoding];
    }
    
    
    int value = rssi;
    
    // only interested in graphing the rssi range between -75 and -103
    if (value > -75) {
        value = -75;
    }
    if (value < -103) {
        value = -103;
    }
    
    // translate rssi to signal strength between 0 and 28
    value += 103;
    
    // calculate ratio
    float ratio = (float)value / (-75 - -103);
    
    // moving average over 20 samples
    int samples = 20;
    if ([advertising hasPrefix:@"-"]) {
        // device using non-default avertising (switch the instaneous sampling)
        samples = 1;
    }
    
    if (_progress.progress == 0.0) {
        // use the instantaneous value for the first sample
        _progress.progress = ratio;
    } else {
        _progress.progress = (ratio * 1.0/samples) + (_progress.progress * (samples - 1.0)/samples);
    }
}

- (void)speechOutput:(NSString*)text
{
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:text];
    utterance.rate *= 0.6;
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
    [synthesizer speakUtterance:utterance];
}


@end
