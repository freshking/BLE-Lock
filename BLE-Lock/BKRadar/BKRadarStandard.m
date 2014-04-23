//
//  BKRadarStandard.m
//  BLE-Lock
//
//  Created by Bastian Kohlbauer on 23.04.14.
//  Copyright (c) 2014 Bastian Kohlbauer. All rights reserved.
//

#import "BKRadarStandard.h"
#import "AngleGradientLayer.h"

@interface BKRadarStandard ()
@property (strong, nonatomic) UIColor *startColor;
@property (strong, nonatomic) UIColor *endColor;
@end

@implementation BKRadarStandard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        _startColor = [UIColor colorWithRed:0.255 green:0.522 blue:0.969 alpha:1.000];
        _endColor = [UIColor whiteColor];
        
        AngleGradientLayer *l = (AngleGradientLayer *)self.layer;
        l.colors = [NSArray arrayWithObjects:
                    (id)_startColor.CGColor,
                    (id)_endColor.CGColor,
                    nil];
        
        CGFloat a = MIN(l.frame.size.width, l.frame.size.height);
        CGRect rect = CGRectMake((self.frame.size.width - a)/2, (self.frame.size.height - a)/2, a, a);
        l.frame = rect;
        l.cornerRadius = a / 2.0f;
        
        self.clipsToBounds = YES;
        
    }
    return self;
}

+ (Class)layerClass
{
	return [AngleGradientLayer class];
}

- (void)setColors:(NSArray*)colors
{
    AngleGradientLayer *l = (AngleGradientLayer *)self.layer;
    l.colors = colors;
}

- (void)setStartColor:(UIColor *)startColor
{
    _startColor = startColor;
}

- (void)setEndColor:(UIColor *)endColor
{
    _endColor = endColor;
}

- (void)addInnerCircle:(BOOL)add withColor:(UIColor*)color andSizeFactor:(double)factor
{
    AngleGradientLayer *l = (AngleGradientLayer *)self.layer;
    
    if (!add)
    {
        [[[l sublayers] objectAtIndex:0] removeAllObjects];
        return;
    }
    
    CGFloat a = MIN(l.frame.size.width, l.frame.size.height);
    
    a *= factor;
    
    CALayer *layer = [CALayer layer];
    [layer setMasksToBounds:YES];
    [layer setBackgroundColor:[color CGColor]];
    [layer setCornerRadius:a/2];
    
    CGRect rect = CGRectMake((self.frame.size.width - a)/2, (self.frame.size.height - a)/2, a, a);
    [layer setFrame:rect];
    [l addSublayer:layer];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

}
*/

@end
