//
//  BKRadar.h
//  BKRadar
//
//  Created by Bastian Kohlbauer on 22.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    RadarStyleStandard,
    RadarStyleCircle,
} RadarStyle;

@interface BKRadar : UIView

- (id)initWithFrame:(CGRect)frame radarStyle:(RadarStyle)style;
- (void)setRadarStyle:(RadarStyle)radarStyle;
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;
- (void)setDoubleTapToSwitch:(BOOL)doubleTap;

@property (assign, nonatomic) RadarStyle radarStyle;

@end
