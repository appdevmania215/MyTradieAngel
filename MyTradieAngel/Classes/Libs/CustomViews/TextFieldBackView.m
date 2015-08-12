//
//  TextFieldBackView.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 4/5/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "TextFieldBackView.h"

@implementation TextFieldBackView

@synthesize cornerRaidus;
@synthesize borderWidth;
@synthesize redValue;
@synthesize greenValue;
@synthesize blueValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        cornerRaidus = 5.f;
        borderWidth = 2;
        redValue = 212;
        greenValue = 212;
        blueValue = 212;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        cornerRaidus = 5.f;
        borderWidth = 2;
        redValue = 212;
        greenValue = 212;
        blueValue = 212;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    // Mask the container view's layer to round the corners
    CALayer *cornerMaskLayer = self.layer;
    cornerMaskLayer.cornerRadius = cornerRaidus;
    cornerMaskLayer.masksToBounds = YES;
    cornerMaskLayer.borderWidth = borderWidth;
    cornerMaskLayer.borderColor = [UIColor colorWithRed:(redValue/255.f) green:(greenValue/255.f) blue:(blueValue/255.f) alpha:1.0f].CGColor;
}

@end
