//
//  ViewController.m
//  BLE-Lock
//
//  Created by Bastian Kohlbauer on 21.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "ViewController.h"


#import "RFduinoManager.h"
#import "RFduino.h"

#define kDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define SWITCH_STATE @"com.Bastian-Kohlbauer.BLE-Lock.switchState"

@interface ViewController ()
@end


@implementation ViewController

@synthesize newrfduino;

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setTitle:@"BLE-Lock"];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    if (![[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_STATE])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:SWITCH_STATE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    _reset = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reset setFrame:CGRectMake((self.view.frame.size.width/2)-60, (self.view.frame.size.height-60), 120, 40)];
    [_reset setTitle:@"Lock / Reset" forState:UIControlStateNormal];
    [_reset setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_reset setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_reset.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [_reset.layer setMasksToBounds:YES];
    [_reset.layer setCornerRadius:10.0f];
    [_reset.layer setBorderWidth:1.0f];
    [_reset.layer setBorderColor:[UIColor blackColor].CGColor];
    [_reset addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_reset addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_reset];

    _switchSelector = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width- 65, 8, 60, 27)];
    [_switchSelector addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [_switchSelector setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:SWITCH_STATE] boolValue] animated:NO];
    [self.navigationController.navigationBar addSubview:_switchSelector];
    
    _progress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    _progress.frame = CGRectMake(0.0, 64.0, self.view.frame.size.width, 20.0);
    _progress.progressViewStyle = UIProgressViewStyleDefault;
    _progress.progressTintColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    [self.view addSubview:_progress];
    
    _radar = [[BKRadar alloc]initWithFrame:CGRectMake(0, 0, 250, 250) radarStyle:RadarStyleCircle];
    [_radar setCenter:self.view.center];
    [self.view addSubview:_radar];
    
    _statsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 80)];
    [_statsLabel setTextAlignment:NSTextAlignmentCenter];
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

- (void)viewDidAppear:(BOOL)animated
{
    
    
    //[radar startAnimating];
    
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
        [kDelegate.rfduinoManager startScan];
        
        [_radar startAnimating];
        [_statsLabel setHidden:YES];
        [_progress setHidden:NO];
        [_progress setProgress:0.0f];
        [_reset setHidden:NO];
        return;
    }
    else
    {
        [kDelegate.rfduinoManager stopScan];
        [newrfduino disconnect];
        
        [_radar stopAnimating];
        [_statsLabel setHidden:NO];
        [_progress setHidden:YES];
        [_reset setHidden:YES];
        [_statsLabel setText:@"Not Scanning"];
        return;
    }
    
}

- (void)sendByte:(uint8_t)byte
{
    uint8_t tx[1] = { byte };
    NSData *data = [NSData dataWithBytes:(void*)&tx length:1];
    [newrfduino send:data];
}

- (void)buttonTouchDown:(id)sender
{
    NSLog(@"TouchDown");
    [self sendByte:1];
}

- (void)buttonTouchUpInside:(id)sender
{
    NSLog(@"TouchUpInside");
    [self sendByte:0];
}

- (void)didReceive:(NSData *)data
{
    NSLog(@"RecievedData");
    
    const uint8_t *value = [data bytes];
    // int len = [data length];
    
    NSLog(@"value = %x", value[0]);
    
    if (value[0] == 1)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self performSelector:@selector(speechOutput:) withObject:@"Alarm" afterDelay:0.0];
    }
    
    
    //newrfduino = [kDelegate.rfduinoManager.rfduinos objectAtIndex:0];
    [self calculateSignalStrength:newrfduino];
 
    //if (value[0])
    //    [image1 setImage:on];
    //else
    //    [image1 setImage:off];
    //
}


#pragma mark - Provate Methods

- (void)calculateSignalStrength:(RFduino *)rfduino
{
    if (!rfduino) return;
    
    

    
    NSString *text = [[NSString alloc] initWithFormat:@"%@", rfduino.name];
    
    NSString *uuid = rfduino.UUID;
    int rssi = rfduino.advertisementRSSI.intValue;
    NSLog(@"rssi: %i",rssi);
    
    NSString *advertising = @"";
    if (rfduino.advertisementData) {
        advertising = [[NSString alloc] initWithData:rfduino.advertisementData encoding:NSUTF8StringEncoding];
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
    [detail appendFormat:@"Packets: %d\n", rfduino.advertisementPackets];
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
