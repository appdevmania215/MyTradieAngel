//
//  CompanyInfoPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "CompanyInfoPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"

#import <UIKit/UIImagePickerController.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "AsyncImageView.h"
#import "GCPlaceholderTextView.h"
#import "ActionSheetPicker.h"

@interface CompanyInfoPageVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    BaseVC *baseVC;
    UIActionSheet *actionsheet;
}
@end

@implementation CompanyInfoPageVC

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
    NSString *boldFontName = @"Optima-ExtraBlack";
    UIColor* darkColor = [UIColor colorWithRed:10.0/255 green:78.0/255 blue:108.0/255 alpha:1.0f];
    self.selFileBtn.backgroundColor = darkColor;
    self.selFileBtn.layer.cornerRadius = 3.0f;
    self.selFileBtn.titleLabel.font = [UIFont fontWithName:boldFontName size:14.f];
    [self.selFileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.selFileBtn setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    
    [self.dateFormatText setRightViewMode:UITextFieldViewModeAlways];
    self.dateFormatText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdownarrow.png"]];
    
    [self.smsCustText setRightViewMode:UITextFieldViewModeAlways];
    self.smsCustText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdownarrow.png"]];
    
    [self.sendSmsText setRightViewMode:UITextFieldViewModeAlways];
    self.sendSmsText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdownarrow.png"]];
    
    [self.smsConfMailText setRightViewMode:UITextFieldViewModeAlways];
    self.smsConfMailText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdownarrow.png"]];
    
    self.invMailContentText.placeholder = @"Enter invoice mail content";
    self.invText.placeholder = @"Enter invoice instructions";
    self.quoteMailContentText.placeholder = @"Enter quotation mail content";
    self.quoteText.placeholder = @"Enter quotation instructions";
    
    // Create Action Sheet
    NSString *actionSheetTitle = @"Please select image"; //Action Sheet Title
    //NSString *destructiveTitle = @"Destructive Button"; //Action Sheet Button Titles
    NSString *camera = @"Camera";
    NSString *gallery = @"Gallery";
    NSString *cancelTitle = @"Cancel";
    actionsheet = [[UIActionSheet alloc]
                        initWithTitle:actionSheetTitle
                        delegate:self
                        cancelButtonTitle:cancelTitle
                        destructiveButtonTitle:nil
                        otherButtonTitles:camera, gallery, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugBCostPageVC) NSLog(@"BCostPageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidLayoutSubviews
{
    [self.scrollView setContentSize:CGSizeMake(320.f, 1310.f)];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ( self.flag ) [self populateData];
    self.flag = NO;
}

- (void)scrolViewScrollToTop
{
    CGPoint upOffest = CGPointMake(0.f, 0.f);
    [self.scrollView setContentOffset:upOffest animated:YES];
}

// =================================================
// UITextField Delegate Delegate Methods
// =================================================
#pragma mark - UITextField Delegate Methods
//==================================================
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag >= 15  &&  textField.tag <= 18)
        return NO;
    else
        return YES;
}

- (IBAction)textFieldPressed:(id)sender
{
    UITextField *text = (UITextField *)sender;
    
    if (debugCompanyInfoPageVC) NSLog(@"CompanyInfoPageVC textFieldPressed: %d", text.tag);
    
    if (text.tag == 15) {
        ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            if ([sender respondsToSelector:@selector(setText:)]) {
                [sender performSelector:@selector(setText:) withObject:selectedValue];
            }
        };
        
        ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
            if (debugInvoicesPageVC) NSLog(@"InvociesPageVC Picker Canceled");
        };
        [ActionSheetStringPicker showPickerWithTitle:@"Select a date format" rows:baseVC.model.dateFormats initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    } else if (text.tag == 16) {
        ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            if ([sender respondsToSelector:@selector(setText:)]) {
                [sender performSelector:@selector(setText:) withObject:selectedValue];
                if (selectedIndex == 0) {
                    [self.sendSmsLabel setHidden:YES];
                    [self.sendSmsText setHidden:YES];
                } else {
                    [self.sendSmsLabel setHidden:NO];
                    [self.sendSmsText setHidden:NO];
                }
            }
        };
        
        ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
            if (debugInvoicesPageVC) NSLog(@"InvociesPageVC Picker Canceled");
        };
        NSArray *array = [[NSArray alloc] initWithObjects:@"No, dont send notifications", @"Yes, send them notifications", nil];
        [ActionSheetStringPicker showPickerWithTitle:@"" rows:array initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    } else if (text.tag == 17) {
        ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            if ([sender respondsToSelector:@selector(setText:)]) {
                [sender performSelector:@selector(setText:) withObject:selectedValue];
            }
        };
        
        ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
            if (debugInvoicesPageVC) NSLog(@"InvociesPageVC Picker Canceled");
        };
        [ActionSheetStringPicker showPickerWithTitle:@"" rows:baseVC.model.sendSmsOpts initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    } else if (text.tag == 18) {
        ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            if ([sender respondsToSelector:@selector(setText:)]) {
                [sender performSelector:@selector(setText:) withObject:selectedValue];
            }
        };
        
        ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
            if (debugInvoicesPageVC) NSLog(@"InvociesPageVC Picker Canceled");
        };
        NSArray *array = [[NSArray alloc] initWithObjects:@"Dont send me emails for sms  notifications", @"Send me emails for sms notifications", nil];
        [ActionSheetStringPicker showPickerWithTitle:@"" rows:array initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    }
}

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark - Button Delegate Methods
//==================================================
- (IBAction)delLogoCheckBtnPressed:(id)sender
{
    if (debugCompanyInfoPageVC) NSLog(@"CompanyInfoPageVC delLogoCheckBtnPressed");
    UIButton *button = (UIButton *)sender;
    if ( button.selected ) [button setSelected:NO];
    else [button setSelected:YES];
}

- (IBAction)buttonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (debugCompanyInfoPageVC) NSLog(@"CompanyInfoPageVC buttonPressed: %d", button.tag);
    
    if (button.tag == 12) {
        [baseVC goToPrevPage];
    } else if (button.tag == 13) {
        NSString *businessName = self.busiNameText.text;
        if ([businessName length] == 0) {
            [baseVC showToastMessage:@"Enter the business name" ForSec:1];
            return;
        }
        NSString *address = self.addrText.text;
        if ([address length] == 0) {
            [baseVC showToastMessage:@"Enter the address" ForSec:1];
            return;
        }
        NSString *subCity = self.subCityText.text;
        if ([subCity length] == 0) {
            [baseVC showToastMessage:@"Enter the suburb and city" ForSec:1];
            return;
        }
        NSString *postCode = self.pCodeText.text;
        if ([postCode length] == 0) {
            [baseVC showToastMessage:@"Enter the postal mocde" ForSec:1];
            return;
        }
        NSString *abn = self.abnText.text;
        if ([abn length] == 0) {
            [baseVC showToastMessage:@"Enter the abn" ForSec:1];
            return;
        }
        NSString *bankDetails = self.bankText.text;
        if ([bankDetails length] == 0) {
            [baseVC showToastMessage:@"Enter the bank details" ForSec:1];
            return;
        }
        
        NSString *invMailContent = self.invMailContentText.text;
        NSString *invText = self.invText.text;
        NSString *quotMailContent = self.quoteMailContentText.text;
        NSString *quotText = self.quoteText.text;
        
        //NSString *defaultAppDesc = self.appDescText.text;
        NSString *defaultAppAmount = self.appAmountText.text;
        if ([defaultAppAmount length] == 0) {
            [baseVC showToastMessage:@"Enter the default app amount" ForSec:1];
            return;
        }
        NSString *taxDescription = self.taxDescText.text;
        if ([taxDescription length] == 0) {
            [baseVC showToastMessage:@"Enter the tax description" ForSec:1];
            return;
        }
        NSString *taxPercent = self.taxPercentText.text;
        if ([taxPercent length] == 0) {
            [baseVC showToastMessage:@"Enter the tax percentage" ForSec:1];
            return;
        }
        NSString *ccCharges = self.ccChargesText.text;
        if ([ccCharges length] == 0) {
            [baseVC showToastMessage:@"Enter the CC Charges" ForSec:1];
            return;
        }
        
        NSString *smsCust = [self.smsCustText.text isEqualToString:@"No, dont send notifications"] ? @"0" : @"1";
        NSString *sendSms = [NSString stringWithFormat:@"%d", [self.sendSmsText.text intValue]];
        if ([smsCust isEqualToString:@"0"]) sendSms = @"0";
        NSString *smsConfMail = [self.smsConfMailText.text isEqualToString:@"Dont send me emails for sms  notifications"] ? @"0" : @"1";;
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"update-settings.php"] forKey:@"url"];
        [dic setObject:businessName forKey:@"business_name"];
        [dic setObject:address forKey:@"address"];
        [dic setObject:subCity forKey:@"area"];
        [dic setObject:postCode forKey:@"postcode"];
        [dic setObject:abn forKey:@"ABN"];
        [dic setObject:bankDetails forKey:@"bank_details"];
        [dic setObject:invMailContent forKey:@"invoice_mail"];
        [dic setObject:invText forKey:@"invoice_text"];
        [dic setObject:quotMailContent forKey:@"quot_mail"];
        [dic setObject:quotText forKey:@"quot_text"];
        [dic setObject:defaultAppAmount forKey:@"default_amt"];
        [dic setObject:taxDescription forKey:@"tax_label"];
        [dic setObject:taxPercent forKey:@"tax_percent"];
        [dic setObject:ccCharges forKey:@"cc_percent"];
        [dic setObject:smsCust forKey:@"sms_allowed"];
        [dic setObject:sendSms forKey:@"sms_time"];
        [dic setObject:smsConfMail forKey:@"sms_email"];
        if ( self.delLogoBtn.selected ) {
            [dic setObject:@"1" forKey:@"del_logo"];
        } else {
            [dic setObject:@"0" forKey:@"del_logo"];
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
            NSString *fileName = [NSString stringWithFormat:@"business-logo-%@.png", [formatter stringFromDate:date]];
            [dic setObject:fileName forKey:@"file_image"];
            
            if (self.logoImage != nil) {
                NSData *imageData = UIImagePNGRepresentation(self.logoImage);
                NSString *encodedImageData = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                encodedImageData = [encodedImageData stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
                [dic setObject:encodedImageData forKey:@"imagedata"];
            }
        }
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:UPDATE_SETTINGS];
    } else if (button.tag == 14) {
        [actionsheet showInView:self.view];
    }
}

// =================================================
// ActionSheet Delegate Methods
// =================================================
#pragma mark - ActionSheet Delegate Methods
//==================================================
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (debugCompanyInfoPageVC) NSLog(@"CompanyInfoPageVC clickedButtonAtIndex: %d" , buttonIndex);
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Destructive Button"]) {
        NSLog(@"Destructive pressed --> Delete Something");
    }
    if ([buttonTitle isEqualToString:@"Camera"]) {
        NSLog(@"Camera pressed");
        [self startCameraControllerFromViewController:self usingDelegate:self];
    }
    if ([buttonTitle isEqualToString:@"Gallery"]) {
        NSLog(@"Gallery pressed");
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    }
}

// =================================================
// ActionSheet Delegate Methods
// =================================================
#pragma mark - ImagePicker Delegate Methods
//==================================================
// ---------------------------------------------------------------------------------------
// startCameraControllerFromViewController - Display the camera view to take photo
// ---------------------------------------------------------------------------------------
- (BOOL)startCameraControllerFromViewController: (UIViewController*) controller
                                  usingDelegate: (id <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate>) delegate
{
    if (debugCompanyInfoPageVC) NSLog(@"CompanyInfoPageVC startCameraControllerFromViewController:");
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    //    cameraUI.mediaTypes =
    //    [UIImagePickerController availableMediaTypesForSourceType:
    //     UIImagePickerControllerSourceTypeCamera];
    
    // Allows only to take still image only
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}

// ---------------------------------------------------------------------------------------
// startCameraControllerFromViewController - Display the camera roll to import photo from
// ---------------------------------------------------------------------------------------
- (BOOL)startMediaBrowserFromViewController: (UIViewController*) controller
                              usingDelegate: (id <UIImagePickerControllerDelegate,
                                              UINavigationControllerDelegate>) delegate
{
    if (debugCompanyInfoPageVC) NSLog(@"CompanyInfoPageVC startMediaBrowserFromViewController");
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    //    mediaUI.mediaTypes =
    //    [UIImagePickerController availableMediaTypesForSourceType:
    //     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Displays still images only
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

// =======================================================================================
// UIImagePickerControllerDelegate Delegate Methods
// =======================================================================================
// ---------------------------------------------------------------------------------------
// For responding to the user tapping Cancel.
// ---------------------------------------------------------------------------------------
//- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    if (debugAddPictureVC) NSLog(@"FPAddPictureVC imagePickerControllerDidCancel");
//    //[[picker parentViewController] dismissViewControllerAnimated:NO completion:nil];
//}

// ---------------------------------------------------------------------------------------
// For responding to the user accepting a newly-captured or impported picture or movie
// ---------------------------------------------------------------------------------------
- (void)imagePickerController: (UIImagePickerController *) picker
didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    if (debugCompanyInfoPageVC) NSLog(@"CompanyInfoPageVC imagePickerController:");
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        UIImage *imageToUse;
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        self.logoImage = imageToUse;
        [self.logoImageView setImage:imageToUse];
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

// =================================================
// Custom Methods
// =================================================
#pragma mark - Custom Methods
//==================================================
- (void)populateData
{
    if (debugCompanyInfoPageVC) NSLog(@"CompanyInfoPageVC populateData");
    
    NSDictionary *data = baseVC.model.data;
    
    self.busiNameText.text = [data valueForKey:@"business_name"];
    self.logoImageView.imageURL = [NSURL URLWithString:[data valueForKey:@"logo_file"]];
    NSURL *url = [NSURL URLWithString:[data valueForKey:@"logo_file"]];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    self.logoImage = [[UIImage alloc] initWithData:imageData];
    [self.delLogoBtn setSelected:NO];
    
    self.addrText.text = [data valueForKey:@"address"];
    self.subCityText.text = [data valueForKey:@"address_area"];
    self.pCodeText.text = [data valueForKey:@"postcode"];
    
    self.abnText.text = [data valueForKey:@"abn"];
    self.bankText.text = [data valueForKey:@"bank_details"];
    
    self.invMailContentText.text = [data valueForKey:@"invoice_mail"];
    self.invText.text = [data valueForKey:@"invoice_notes"];
    self.quoteMailContentText.text = [data valueForKey:@"quot_mail"];
    self.quoteText.text = [data valueForKey:@"quot_notes"];
    
    self.dateFormatText.text = [data valueForKey:@"yyyy-mm-dd"];
    
    self.appDescText.text = [data valueForKey:@"app_default_label"];
    self.appAmountText.text = [data valueForKey:@"app_default_amt"];
    self.taxDescText.text = [data valueForKey:@"tax_label"];
    self.taxPercentText.text = [data valueForKey:@"tax_percent"];
    self.ccChargesText.text = [data valueForKey:@"cc_percent"];
    
    if ([[data valueForKey:@"sms_allowed"] intValue] == 0) {
        self.smsCustText.text = @"No, dont send notifications";
        [self.sendSmsLabel setHidden:YES];
        [self.sendSmsText setHidden:YES];
    } else {
        self.smsCustText.text = @"Yes, send them notifications";
        [self.sendSmsLabel setHidden:NO];
        [self.sendSmsText setHidden:NO];
    }
    self.sendSmsText.text = [NSString stringWithFormat:@"%@ hours before appointment", [data valueForKey:@"sms_time"]];
    if ([[data valueForKey:@"sms_email"] intValue] == 0) {
        self.smsConfMailText.text = @"Dont send me emails for sms notifications";
    } else {
        self.smsConfMailText.text = @"Send me emails for sms notifications";
    }
    
    [self scrolViewScrollToTop];
}
@end
