//
//  BKRadar.m
//  BKRadar
//
//  Created by Bastian Kohlbauer on 22.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "BKRadar.h"
#import "BKRadarStandard.h"
#import "BKRadarCircle.h"

@interface BKRadar ()
@property (strong, nonatomic) BKRadarStandard *radarStandard;
@property (strong, nonatomic) BKRadarCircle *radarCircle;
@property (assign, nonatomic) BOOL animationCancelled;
@property (assign, nonatomic) BOOL doubleTap;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@end

@implementation BKRadar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        _radarStyle = RadarStyleCircle;
        _animationCancelled = YES;
        _doubleTap = NO;
        [self setHidden:_animationCancelled];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame radarStyle:(RadarStyle)style
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        _radarStyle = style;
        _animationCancelled = YES;
        _doubleTap = NO;
        [self setHidden:_animationCancelled];
    }
    return self;
}

- (void)setRadarStyle:(RadarStyle)radarStyle
{
    [self stopAnimating];
    
    _radarStyle = radarStyle;
    
    if (_radarStyle == RadarStyleCircle)
    {
        [_radarCircle setHidden:NO];
        [_radarStandard setHidden:YES];
    }
    else if (_radarStyle == RadarStyleStandard)
    {
        [_radarCircle setHidden:YES];
        [_radarStandard setHidden:NO];
    }
    
    [self startAnimating];
}

- (void)startAnimating
{
    _animationCancelled = NO;
    [self setHidden:_animationCancelled];
    [self setUserInteractionEnabled:YES];
    
    if (_radarStyle == RadarStyleCircle)
    {
        if (!_radarCircle)
        {
            _radarCircle = [[BKRadarCircle alloc]initWithFrame:CGRectMake(self.frame.size.width/2, self.frame.size.height/2, 0, 0)];
            [_radarCircle setAlpha:_radarCircle.alphaStart];
        }
        [self addSubview:_radarCircle];

        [UIView animateWithDuration:2.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState //| UIViewAnimationOptionRepeat
                         animations:^(void) {
                             
                             [_radarCircle setFrame:self.bounds];
                             [_radarCircle setAlpha:_radarCircle.alphaEnd];
                             
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:0.1
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^(void) {
                                                  
                                                  [_radarCircle setAlpha:0.0];
                                                  
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  [_radarCircle removeFromSuperview];
                                                  _radarCircle = nil;
                                                  
                                                  if(!_animationCancelled) {
                                                      __weak id weakSelf = self;
                                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                          [weakSelf startAnimating];
                                                      }];
                                                  }
                                                  
                                              }];
                             
                             
                         }];
        
        
    }
    else if (_radarStyle == RadarStyleStandard)
    {
        
        if (!_radarStandard)
        {
            _radarStandard = [[BKRadarStandard alloc]initWithFrame:self.bounds];
            [_radarStandard addInnerCircle:YES withColor:[UIColor whiteColor] andSizeFactor:0.10];
        }
        [self addSubview:_radarStandard];
        
        CABasicAnimation * spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        spin.duration = 1;
        spin.toValue = [NSNumber numberWithFloat:M_PI];
        spin.cumulative = YES;
        spin.repeatCount = MAXFLOAT;
        [_radarStandard.layer addAnimation:spin forKey:@"spin"];
        
    }
    
    
}

- (void)stopAnimating
{
    _animationCancelled = YES;
    [self setHidden:_animationCancelled];
    [self setUserInteractionEnabled:NO];
    
    [CATransaction begin];
    if (_radarStyle == RadarStyleCircle)
    {
        [_radarCircle.layer removeAllAnimations];
    }
    else if (_radarStyle == RadarStyleStandard)
    {
        [_radarStandard.layer removeAllAnimations];
    }
    [CATransaction commit];
}

- (BOOL)isAnimating
{
    return !_animationCancelled;
}

- (void)setDoubleTapToSwitch:(BOOL)doubleTap
{
    _doubleTap = doubleTap;
    
    if (_doubleTap)
    {
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(animationTapped)];
        [_tap setNumberOfTapsRequired:2];
        [self addGestureRecognizer:_tap];
    }
    else
    {
        [self removeGestureRecognizer:_tap];
    }
}

- (void)animationTapped
{
    if (_radarStyle == RadarStyleCircle)
    {
        [self setRadarStyle:RadarStyleStandard];
    }
    else if (_radarStyle == RadarStyleStandard)
    {
        [self setRadarStyle:RadarStyleCircle];
    }
    
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
