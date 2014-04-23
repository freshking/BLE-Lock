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
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
