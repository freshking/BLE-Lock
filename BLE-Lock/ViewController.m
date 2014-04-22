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
#define SWITCH_STATE @"com.Bastian-Kohlbauer.BLE-Lock.switchState"

@interface ViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIProgressView *progress;
@property (nonatomic, strong) UISwitch *switchSelector;
@property (nonatomic, strong) UILabel *statsLabel;
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
    
    [self setTitle:@"BLE-Lock"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    rfduinoManager.delegate = self;

    if (![[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_STATE])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:SWITCH_STATE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [rfduinoManager startScan];
    }

    _switchSelector = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width- 65, 8, 60, 27)];
    [_switchSelector addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [_switchSelector setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_STATE] boolValue] animated:NO];
    [self.navigationController.navigationBar addSubview:_switchSelector];
    
    _progress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    _progress.frame = CGRectMake(0.0, 64.0, self.view.frame.size.width, 20.0);
    _progress.progressViewStyle = UIProgressViewStyleDefault;
    _progress.progressTintColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    [self.view addSubview:_progress];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator.center = self.view.center;
    [_indicator setHidesWhenStopped:YES];
    [self.view addSubview:_indicator];
    
    _statsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 80)];
    [_statsLabel setNumberOfLines:4];
    [_statsLabel setAdjustsFontSizeToFitWidth:YES];
    [_statsLabel setCenter:self.view.center];
    [_statsLabel.layer setCornerRadius:10.0f];
    [_statsLabel.layer setMasksToBounds:YES];
    [_statsLabel.layer setBorderColor:[UIColor blackColor].CGColor];
    [_statsLabel.layer setBorderWidth:1.0f];
    [self.view addSubview:_statsLabel];
    
    [self switchChanged:nil];
    
    //AudioServicesPlaySystemSound(1007); // sms received
    //AudioServicesPlaySystemSound(1304); // alarm
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:_switchSelector.on] forKey:SWITCH_STATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (_switchSelector.on)
    {
        if (!rfduinoManager.isScanning)
        {
            [rfduinoManager startScan];
        }
        
        [_indicator startAnimating];
        [_statsLabel setHidden:YES];
        [_progress setHidden:NO];
        [_progress setProgress:0.0f];
        [_statsLabel setTextAlignment:NSTextAlignmentLeft];
    }
    else
    {
        if (rfduinoManager.isScanning)
        {
            [rfduinoManager stopScan];
        }
        
        [_indicator stopAnimating];
        [_statsLabel setHidden:NO];
        [_progress setHidden:YES];
        [_statsLabel setTextAlignment:NSTextAlignmentCenter];
        [_statsLabel setText:@"Not scanning."];
    }
    
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
    [_statsLabel setHidden:_indicator.isAnimating];
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
    [_statsLabel setHidden:_indicator.isAnimating];
    [rfduinoManager startScan];
}

#pragma mark - Provate Methods

- (void)calculateSignalStrength
{
    NSString *text = [[NSString alloc] initWithFormat:@"%@", _rfduino.name];
    
    NSString *uuid = _rfduino.UUID;
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
    
    NSMutableString *detail = [NSMutableString stringWithCapacity:100];
    [detail appendFormat:@"%@\n", text];
    [detail appendFormat:@"RSSI: %d dBm", rssi];
    while ([detail length] < 25)
        [detail appendString:@" "];
    [detail appendFormat:@"Packets: %d\n", _rfduino.advertisementPackets];
    [detail appendFormat:@"Advertising: %@\n", advertising];
    [detail appendFormat:@"%@", uuid];
    [_statsLabel setText:detail];
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
