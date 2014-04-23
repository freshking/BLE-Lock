//
//  BKRadarStandard.h
//  BLE-Lock
//
//  Created by Bastian Kohlbauer on 23.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKRadarStandard : UIView

- (void)setColors:(NSArray*)colors;
- (void)setStartColor:(UIColor *)startColor;
- (void)setEndColor:(UIColor *)endColor;
- (void)addInnerCircle:(BOOL)add withColor:(UIColor*)color andSizeFactor:(double)factor;

@end
