//
//  TextFieldBackView.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 4/5/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldBackView : UIView
{
    UIView *strokeView;
}

@property (nonatomic, assign) float cornerRaidus;
@property (nonatomic, assign) int borderWidth;
@property (nonatomic, assign) int redValue;
@property (nonatomic, assign) int greenValue;
@property (nonatomic, assign) int blueValue;

@end
