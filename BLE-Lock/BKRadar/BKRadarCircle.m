//
//  BKRadarCircle.m
//  BKRadar
//
//  Created by Bastian Kohlbauer on 22.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import "BKRadarCircle.h"


@interface BKRadarCircle ()
@property (assign, nonatomic) CGFloat lineWidth;
@property (strong, nonatomic) UIColor *strokeColor;
@property (strong, nonatomic) UIColor *fillColor;
@end

@implementation BKRadarCircle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        _alphaStart = 0.85;
        _alphaEnd = 0.4;
        _lineWidth = 4.0;
        _strokeColor = [UIColor colorWithRed:0.115 green:0.394 blue:0.958 alpha:1.000];
        _fillColor = [UIColor colorWithRed:0.255 green:0.522 blue:0.969 alpha:1.000];
    }
    return self;
}

- (void)setAnimationAlphaForBeginning:(CGFloat)alpha
{
    _alphaStart = alpha;
}

- (void)setAnimationAlphaForEnding:(CGFloat)alpha
{
    _alphaEnd = alpha;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

     CGFloat a = MIN(self.frame.size.width, self.frame.size.height) - _lineWidth;
     
     //Get current context
     CGContextRef mainContext = UIGraphicsGetCurrentContext();
    
    CGRect newRect = rect;
    newRect.origin.x = ((self.frame.size.width - a)/2.0f);
    newRect.origin.y = ((self.frame.size.height - a)/2.0f);
    newRect.size.width = a;
    newRect.size.height = a;
     
     // Fill circle
    
    const CGFloat *_components = CGColorGetComponents(_fillColor.CGColor);
    CGFloat red     = _components[0];
    CGFloat green = _components[1];
    CGFloat blue   = _components[2];
    CGFloat alpha = _components[3];
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat redBallColors[] = {
        red,green,blue,0.5,
        red,green,blue,alpha,
    };
    CGFloat glossLocations[] = {0.0, 1.0};
    CGGradientRef ballGradient = CGGradientCreateWithColorComponents(baseSpace, redBallColors, glossLocations, 2);
    CGPoint startPoint = self.center;
    CGPoint endPoint = self.center;
    CGContextDrawRadialGradient(mainContext, ballGradient, startPoint, 0, endPoint, a/2, 0);

    
    // Stroke circle
    
    
    
    CGContextAddEllipseInRect(mainContext, newRect);
    CGContextSetLineWidth(mainContext, _lineWidth);
    CGContextSetStrokeColorWithColor(mainContext, [_strokeColor CGColor]);
    
    
    //Draw the path
    CGContextDrawPath(mainContext, kCGPathStroke);
    
}

@end
