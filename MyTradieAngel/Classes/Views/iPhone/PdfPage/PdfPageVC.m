//
//  PdfPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "PdfPageVC.h"

#import "AppConst.h"
#import "BaseVC.h"

@interface PdfPageVC ()
{
    BaseVC *baseVC;
}
@end

@implementation PdfPageVC

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugPdfPageVC) NSLog(@"PdfPageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (debugPdfPageVC) NSLog(@"PdfPageVC viewDidAppear: %@", self.urlString);
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:self.urlString];
    //URL Requst Object
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //Load the request in the UIWebView.
    [self.webView loadRequest:request];
    [self.webView setScalesPageToFit:YES];
    
    self.titleLabel.text = @"Loading...";
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (debugPdfPageVC) NSLog(@"PdfPageVC viewDidDisappear");
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    self.titleLabel.text = @"";
}

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark - Button Delegate Methods
//==================================================
- (IBAction)buttonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (debugPdfPageVC) NSLog(@"PdfPageVC buttonPressed: %d", button.tag);
    
    if (button.tag == 1) { // close
        [baseVC goToPrevPage];
    }
}

// =================================================
// UIWevView Delegate Methods
// =================================================
#pragma mark - UIWevView Delegate Methods
//==================================================
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (debugPdfPageVC) NSLog(@"PdfPageVC webViewDidFinishLoad");
    self.titleLabel.text = @"PDF Preview";
}

@end
