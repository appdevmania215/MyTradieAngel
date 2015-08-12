//
//  BCostPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "BCostPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"
#import "AppUtils.h"

#import "ActionSheetPicker.h"

#import <UIKit/UIImagePickerController.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface BCostPageVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    BaseVC *baseVC;
    UIActionSheet *actionsheet;
    AbstractActionSheetPicker *actionSheetPicker;
}
@end

@implementation BCostPageVC

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
    [self.dateText setRightViewMode:UITextFieldViewModeAlways];
    self.dateText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_icon.png"]];
    
    // Create Action Sheet
    //NSString *destructiveTitle = @"Destructive Button"; //Action Sheet Button Titles
    actionsheet = [[UIActionSheet alloc]
                        initWithTitle:@"Please select image"
                        delegate:self
                        cancelButtonTitle:@"Cancel"
                        destructiveButtonTitle:nil
                        otherButtonTitles:@"Camera", @"Gallery", nil];
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

- (void)viewDidAppear:(BOOL)animated
{
    if ( !self.imagePickerFlag ) {
        if ( self.flag ) [self initForm];
        else [self populateData];
    }
}

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark - Button Delegate Methods
//==================================================
- (IBAction)buttonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (debugBCostPageVC) NSLog(@"BCostPageVC buttonPressed: %d", button.tag);
    
    if (button.tag == 1) { // close
        [baseVC goToPrevPage];
    } else if (button.tag == 2) { // save
        if ([self.amtText.text isEqualToString:@""]) {
            [baseVC showToastMessage:@"Enter the amount" ForSec:1];
            return;
        }
        if ([self.taxOptText.text isEqualToString:@""]) {
            [baseVC showToastMessage:@"Select tax option" ForSec:1];
            return;
        }
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"update-cost.php"] forKey:@"url"];
        [dic setObject:self.costId forKey:@"id"];
        [dic setObject:[NSString stringWithFormat:@"%@ 00:00:00", self.dateText.text] forKey:@"date"];
        [dic setObject:self.amtText.text forKey:@"amount"];
        if ([self.taxOptText.text isEqualToString:@"Yes"]) [dic setObject:@"1" forKey:@"tax_incl"];
        else [dic setObject:@"0" forKey:@"tax_incl"];
        int index = [self.allHeads indexOfObject:self.headText.text];
        if (index > 0  &&  index <= self.allHeadIds.count) {
            [dic setObject:[self.allHeadIds objectAtIndex:index] forKey:@"head_id"];
            [dic setObject:self.headText.text forKey:@"head"];
        } else {
            [dic setObject:@"0" forKey:@"head_id"];
            [dic setObject:@"" forKey:@"head"];
        }
        
        NSString *imagePath = @"";
        if ([self.receiptImageView image]) {
            imagePath = [self saveImage:[self.receiptImageView image]];
            if ([imagePath isEqualToString:@"failed"]) {
                [baseVC showToastMessage:@"saving image failed" ForSec:1];
                return;
            }
        }
        [dic setObject:imagePath forKey:@"image"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:UPDATE_COST];
    } else if (button.tag == 3) { // select file
        [actionsheet showInView:self.view];
    }
}

// =================================================
// UITextField Delegate Methods
// =================================================
#pragma mark - UITextField Delegate Methods
//==================================================
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag > 10)
        return NO;
    else
        return YES;
}

- (IBAction)textFieldPressed:(id)sender
{
    UITextField *text = (UITextField *)sender;
    if (debugBCostPageVC) NSLog(@"BCostPageVC textFieldPressed: %d", text.tag);
    
    if (text.tag == 11) { // head option
        ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            if ([sender respondsToSelector:@selector(setText:)]) {
                [sender performSelector:@selector(setText:) withObject:selectedValue];
            }
        };
        
        ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
            if (debugInvoicesPageVC) NSLog(@"BCostPageVC Picker Canceled");
        };
        
        [ActionSheetStringPicker showPickerWithTitle:@"" rows:self.allHeads initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    } else if (text.tag ==  12) { // date
        NSDate *today = [NSDate date];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a Date" datePickerMode:UIDatePickerModeDate selectedDate:today target:self action:@selector(dateWasSelected:sender:) origin:sender];
        [actionSheetPicker showActionSheetPicker];
    } else if (text.tag ==  13) { // tax option
        ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            if ([sender respondsToSelector:@selector(setText:)]) {
                [sender performSelector:@selector(setText:) withObject:selectedValue];
            }
        };
        
        ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
            if (debugInvoicesPageVC) NSLog(@"BCostPageVC Picker Canceled");
        };
        NSArray *array = [[NSArray alloc] initWithObjects:@"No", @"Yes", nil];
        [ActionSheetStringPicker showPickerWithTitle:@"" rows:array initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    }
}

// =================================================
// Implementation Methods
// =================================================
#pragma mark - Implementation Methods
//==================================================
- (void)dateWasSelected:(NSDate *)selectedDate sender:(id)sender {
    UITextField *text = (UITextField *)sender;
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    text.text = [AppUtils getDateStringFromDate:selectedDate];
}
/*
 - (void)animalWasSelected:(NSNumber *)selectedIndex element:(id)element {
 //may have originated from textField or barButtonItem, use an IBOutlet instead of element
 }
 - (void)measurementWasSelectedWithBigUnit:(NSNumber *)bigUnit smallUnit:(NSNumber *)smallUnit element:(id)element {
 }
 */
- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}

// =================================================
// Actionsheet Methods
// =================================================
#pragma mark- Actionsheet Methods
//==================================================
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (debugBCostPageVC) NSLog(@"BCostPageVC actionSheet clickedButtonAtIndex: %d" , buttonIndex);
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    } else {
        self.imagePickerFlag = YES;
        if (buttonIndex == 0) { // camera button
            NSLog(@"Camera pressed");
            [self startCameraControllerFromViewController:self usingDelegate:self];
        } else if (buttonIndex == 1) { // gallery button
            NSLog(@"Gallery pressed");
            [self startMediaBrowserFromViewController:self usingDelegate:self];
        }
    }
}

// =================================================
// startMediaBrowserFromViewController - Display the camera roll to import photo from
// =================================================
#pragma mark- startMediaBrowserFromViewController Methods
//==================================================
- (BOOL)startMediaBrowserFromViewController: (UIViewController*) controller
                              usingDelegate: (id <UIImagePickerControllerDelegate,
                                              UINavigationControllerDelegate>) delegate
{
    if (debugBCostPageVC) NSLog(@"startMediaBrowserFromViewController:");
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the Camera Roll album.
    // mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Displays still images only
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    // Hides the controls for moving & scaling pictures, or for trimming movies.
    // To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

// =================================================
// startCameraControllerFromViewController - Display the camera view to take photo
// =================================================
#pragma mark- startCameraControllerFromViewController Methods
//==================================================
- (BOOL)startCameraControllerFromViewController: (UIViewController*) controller
                                  usingDelegate: (id <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate>) delegate
{
    if (debugBCostPageVC) NSLog(@"startCameraControllerFromViewController:");
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or movie capture, if both are available:
    // cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    // Allows only to take still image only
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    // Hides the controls for moving & scaling pictures, or for trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}

//==================================================
// UIImagePickerController Delegate Methods
//==================================================
#pragma mark - UIImagePickerController Delegate Methods
//==================================================
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
    if (debugBCostPageVC) NSLog(@"imagePickerController:");
    
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
        
        [self.receiptImageView setImage:imageToUse];
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (NSString *)saveImage:(UIImage*)image
{
    if (debugBCostPageVC) NSLog(@"BCostPageVC saveImage:");
    if (image != nil) {
        //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
        //NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
        NSString *fileName = [NSString stringWithFormat:@"costentry-%@.png", [formatter stringFromDate:date]];
        /*
         NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
         NSMutableString *randomString = [NSMutableString stringWithCapacity:10];
         for (int i=0; i<10; i++) {
         [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
         }
         NSString *fileName = [NSString stringWithFormat:@"%@.png", randomString]; */
        
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:fileName];
        NSData *data = UIImagePNGRepresentation(image);
        if ([data writeToFile:path atomically:YES]) {
            return fileName;
        } else {
            return @"failed";
        }
    }
    
    return nil;
}

- (UIImage *)loadImage:(NSString*)imagePath
{
    if (debugBCostPageVC) NSLog(@"BCostPageVC loadImage: %@", imagePath);
    UIImage *image = [UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:imagePath]];
    return image;
}

// =================================================
// Custom Methods
// =================================================
#pragma mark - Custom Methods
//==================================================
- (void)initForm
{
    if (debugBCostPageVC) NSLog(@"BCostPageVC initForm");
    
    self.costId = @"0";
    self.headText.text = @"None Selected";
    self.descText.text = @"";
    self.dateText.text = [AppUtils getDateStringFromDate:[NSDate date]];
    self.amtText.text = @"";
    self.taxOptText.text = @"";
    [self.receiptImageView setImage:nil];
}

- (void)populateData
{
    if (debugBCostPageVC) NSLog(@"BCostPageVC populateData");
    
    NSDictionary *data = baseVC.model.data;
    self.costId = [data valueForKey:@"c_id"];
    self.headText.text = [data valueForKey:@"head"];
    self.descText.text = @"";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:[data valueForKey:@"date"]];
    self.dateText.text = [AppUtils getDateStringFromDate:date];
    self.amtText.text = [data valueForKey:@"amt"];
    if ([[data valueForKey:@"tax_incl"] intValue] == 1)
        self.taxOptText.text = @"Yes";
    else self.taxOptText.text = @"No";
    
    NSString *imagePath = [data valueForKey:@"image"];
    if ([imagePath isEqualToString:@""]) {
        [self.receiptImageView setImage:nil];
    } else {
        UIImage *image = [self loadImage:imagePath];
        if (image) {
            [self.receiptImageView setImage:image];
        } else {
            [self.receiptImageView setImage:nil];
        }
    }
}

@end