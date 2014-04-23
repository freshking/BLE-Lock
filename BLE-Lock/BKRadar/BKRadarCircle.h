//
//  BKRadarCircle.h
//  BKRadar
//
//  Created by Bastian Kohlbauer on 22.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKRadarCircle : UIView

- (void)setAnimationAlphaForBeginning:(CGFloat)alpha;
- (void)setAnimationAlphaForEnding:(CGFloat)alpha;
- (void)setLineWidth:(CGFloat)lineWidth;
- (void)setStrokeColor:(UIColor *)strokeColor;
- (void)setFillColor:(UIColor *)fillColor;

@property (assign, nonatomic) CGFloat alphaStart;
@property (assign, nonatomic) CGFloat alphaEnd;

@end
