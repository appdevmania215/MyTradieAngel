//
//  AppDelegate.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/26/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Model, BaseVC;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    Model *model;
    BaseVC *view;
}

@property (strong, nonatomic) UIWindow *window;

@end
