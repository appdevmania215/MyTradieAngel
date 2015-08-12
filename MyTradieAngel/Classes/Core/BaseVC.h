//
//  BaseVC.h
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/26/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Model;
//@class HomePageVC, MentionsPageVC;

@interface BaseVC : UIViewController

//@property (nonatomic, retain) HomePageVC *homePageVC;
//@property (nonatomic, retain) MentionsPageVC *mentionsPageVC;

- (void)initWithModel:(Model *)anyModel;
- (void)pushVC;
- (void)popVC;

@end
