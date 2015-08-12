//
//  BaseVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/26/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "BaseVC.h"

#import "AppConst.h"
#import "Model.h"

#import "LoginPageVC.h"
#import "SignupPageVC.h"

@interface BaseVC ()
{
    Model *model;
    
    LoginPageVC *loginPageVC;
    SignupPageVC *signupPageVC;
}
@property (nonatomic, strong) UIViewController *currentVC;
@end

@implementation BaseVC

@synthesize currentVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    loginPageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginPageVC"];
    signupPageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"signupPageVC"];
    
    [self.view addSubview:loginPageVC.view];
    [self addChildViewController:loginPageVC];
    
    currentVC = loginPageVC;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithModel:(Model *)anyModel
{
    if (debugBaseVC) NSLog(@"BaseVC initWithModel");
    model = anyModel;    
}

- (void)pushVC
{
    UIViewController *newVC = signupPageVC;
    
    if (newVC == nil) return;
    
    [newVC.view layoutIfNeeded];
    
    CGRect inputViewFrame = self.view.bounds;
    CGFloat inputViewWidth = inputViewFrame.size.width;
    
    CGRect newFrame = CGRectMake(self.view.bounds.size.width, 0, inputViewFrame.size.width, inputViewFrame.size.height);
    
    newVC.view.frame = newFrame;
    
    [self.currentVC willMoveToParentViewController:nil];
    [self addChildViewController:newVC];
    [self.view addSubview:newVC.view];
    
    [self.currentVC willMoveToParentViewController:nil];
    
    CGRect offSetRect=CGRectOffset(newFrame, -inputViewWidth, 0.0f);
    CGRect otherOffsetRect=CGRectOffset(self.currentVC.view.frame, -inputViewWidth, 0.0f);
    
    __weak __block BaseVC *weakSelf=self;
    [UIView animateWithDuration:0.4f
                     animations:^{
                         newVC.view.frame = offSetRect;
                         weakSelf.currentVC.view.frame=otherOffsetRect;
                     }
                     completion:^(BOOL finished){
                         [weakSelf.currentVC.view removeFromSuperview];
                         [weakSelf.currentVC removeFromParentViewController];
                         [newVC didMoveToParentViewController:weakSelf];
                         
                         weakSelf.currentVC = newVC;
                     }];
}

- (void)popVC
{
    UIViewController *newVC = loginPageVC;
    
    [newVC.view layoutIfNeeded];
    
    CGRect inputViewFrame = self.view.bounds;
    CGFloat inputViewWidth = inputViewFrame.size.width;
    
    CGRect newFrame=CGRectMake(-self.view.bounds.size.width, 0, inputViewFrame.size.width, inputViewFrame.size.height);
    
    newVC.view.frame=newFrame;
    
    [self.currentVC willMoveToParentViewController:nil];
    [self addChildViewController:newVC];
    [self.view addSubview:newVC.view];
    
    [self.currentVC willMoveToParentViewController:nil];
    
    CGRect offSetRect=CGRectOffset(newFrame, inputViewWidth, 0.0f);
    CGRect otherOffsetRect=CGRectOffset(self.currentVC.view.frame, inputViewWidth, 0.0f);
    
    __weak __block BaseVC *weakSelf=self;
    [UIView animateWithDuration:0.4f
                     animations:^{
                         newVC.view.frame=offSetRect;
                         weakSelf.currentVC.view.frame=otherOffsetRect;
                     }
                     completion:^(BOOL finished){
                         [weakSelf.currentVC.view removeFromSuperview];
                         [weakSelf.currentVC removeFromParentViewController];
                         [newVC didMoveToParentViewController:weakSelf];
                         
                         weakSelf.currentVC = newVC;
                     }];
}@end
