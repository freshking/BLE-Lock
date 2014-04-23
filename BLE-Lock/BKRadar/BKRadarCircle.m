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
    
    /** Fill circle **/
    
    CGContextAddArc(mainContext, self.frame.size.width/2.0f, self.frame.size.height/2.0f, a/2.0f, 0.f, (float)2.f*M_PI, true);
    CGContextSetFillColorWithColor(mainContext, [_fillColor CGColor]);
    CGContextFillPath(mainContext);
    
    /** Stroke circle **/
    
    //CGRect rectangle = CGRectMake(((a)/2.0f) + (_lineWidth/2.0f), ((a)/2.0f) + (_lineWidth/2.0f), a, a);
    
    CGRect newRect = rect;
    newRect.origin.x = ((self.frame.size.width - a)/2.0f);
    newRect.origin.y = ((self.frame.size.height - a)/2.0f);
    newRect.size.width = a;
    newRect.size.height = a;
    
    CGContextAddEllipseInRect(mainContext, newRect);
    CGContextSetLineWidth(mainContext, _lineWidth);
    CGContextSetStrokeColorWithColor(mainContext, [_strokeColor CGColor]);
    
    
    //Draw the path
    CGContextDrawPath(mainContext, kCGPathStroke);

}

@end
