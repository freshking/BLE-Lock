//
//  BKRadar.m
//  BKRadar
//
//  Created by Bastian Kohlbauer on 22.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "BKRadar.h"
#import "BKRadarCircle.h"

@interface BKRadar ()
@property (assign, nonatomic) RadarStyle radarStyle;
@property (strong, nonatomic) BKRadarCircle *radarCircle;
@property (assign, nonatomic) BOOL animationCancelled;
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
        [self setHidden:_animationCancelled];
    }
    return self;
}

- (void)startAnimating
{
    _animationCancelled = NO;
    [self setHidden:_animationCancelled];
    
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
        //_radarView = [[BKRadarStandard alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        /*
        CABasicAnimation *appDeleteShakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        appDeleteShakeAnimation.autoreverses = YES;
        appDeleteShakeAnimation.repeatDuration = HUGE_VALF;
        appDeleteShakeAnimation.duration = 3.0;
        appDeleteShakeAnimation.fromValue = [NSNumber numberWithFloat:-degreeToRadian(5)];
        appDeleteShakeAnimation.toValue=[NSNumber numberWithFloat:degreeToRadian(5)];
        [self.layer addAnimation:appDeleteShakeAnimation forKey:@"appDeleteShakeAnimation"];
        */
    }
    
    //[_radarView setCenter:self.center];
    
}

- (void)stopAnimating
{
    _animationCancelled = YES;
    [self setHidden:_animationCancelled];
    
    [CATransaction begin];
    [_radarCircle.layer removeAllAnimations];
    [CATransaction commit];
}


- (BOOL)isAnimating
{
    return !_animationCancelled;
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
