//
//  BCostsPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "BCostsPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"
#import "AppUtils.h"

#import "CostCell.h"
#import "ActionSheetPicker.h"

#import "BCostPageVC.h"

@interface BCostsPageVC ()<UIActionSheetDelegate>
{
    NSInteger curItemIndex;
    
    BaseVC *baseVC;
    UIActionSheet *actionsheet;
    AbstractActionSheetPicker *actionSheetPicker;
}
@end

@implementation BCostsPageVC

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
    
    [baseVC makeButtonUI:self.showMoreBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.addBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.searchBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.cancelBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    
    [self.fromDateText setRightViewMode:UITextFieldViewModeAlways];
    self.fromDateText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_icon.png"]];
    
    [self.toDateText setRightViewMode:UITextFieldViewModeAlways];
    self.toDateText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_icon.png"]];
    
    [self.sortText setRightViewMode:UITextFieldViewModeAlways];
    self.sortText.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdownarrow.png"]];
    
    self.popupMaskView = [[UIView alloc] init];
    [self.popupMaskView setFrame:self.view.frame];
    [self.view addSubview:self.popupMaskView];
    [self.popupMaskView setBackgroundColor:[UIColor blackColor]];
    [self.popupMaskView setAlpha:0.5f];
    [self.popupMaskView setHidden:YES];
    
    [self.view addSubview:self.popupFilterView];
    self.popupFilterView.layer.cornerRadius = 10.0f;
    self.popupFilterView.center = self.view.center;
    [self.popupFilterView setHidden:YES];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.filterTitle.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10.0f, 10.0f)];
    maskLayer.path = maskPath.CGPath;
    self.filterTitle.layer.mask = maskLayer;
    
    // Create Action Sheet
    NSString *actionSheetTitle = @"Please select a action you want"; //Action Sheet Title
    //NSString *destructiveTitle = @"Destructive Button"; //Action Sheet Button Titles
    NSString *cancelTitle = @"Cancel";
    actionsheet = [[UIActionSheet alloc]
                        initWithTitle:actionSheetTitle
                        delegate:self
                        cancelButtonTitle:cancelTitle
                        destructiveButtonTitle:nil
                        otherButtonTitles:@"Edit this item", @"Delete this item", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugHeadsPageVC) NSLog(@"HeadsPageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.itemCountLabel.text = [NSString stringWithFormat:@"    Total Items: %d", baseVC.model.allData.count];
}

- (void)viewDidLayoutSubviews
{
    if ( IS_IPHONE_5 ) { // if iphone Retina 4 inch
        CGRect rect = self.popupMaskView.frame;
        rect.size.height = 568.f;
        [self.popupMaskView setFrame:rect];
    }
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
    if (textField.tag >= 6  &&  textField.tag <= 8)
        return NO;
    else
        return YES;
}

- (IBAction)textFieldPressed:(id)sender
{
    UITextField *text = (UITextField *)sender;
    
    if (debugBCostsPageVC) NSLog(@"BCostsPageVC textFieldPressed: %d", text.tag);
    
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        if (debugBCostsPageVC) NSLog(@"BCostsPageVC Picker Canceled");
    };
    
    if (text.tag == 6) {
        NSDate *today = [NSDate date];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a Start Date" datePickerMode:UIDatePickerModeDate selectedDate:today target:self action:@selector(dateWasSelected:sender:) origin:sender];
        [actionSheetPicker showActionSheetPicker];
    } else if (text.tag == 7) {
        NSDate *today = [NSDate date];
        actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a End Date" datePickerMode:UIDatePickerModeDate selectedDate:today target:self action:@selector(dateWasSelected:sender:) origin:sender];
        [actionSheetPicker showActionSheetPicker];
    } else if (text.tag == 8) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select a sort" rows:baseVC.model.costSorts initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    }
}

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark- Button Delegate Methods
//==================================================
- (IBAction)buttonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (debugBCostsPageVC) NSLog(@"BCostsPageVC buttonPressed: %d", button.tag);
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    if (button.tag == 1) { // Home button
        [baseVC goToPrevPage];
    } else if (button.tag == 2) { // Show More button
        [self initPopupFilterView];
        
        [self.popupMaskView setHidden:NO];
        [self.popupFilterView setHidden:NO];
    } else if (button.tag == 3) { // Add button
        [baseVC.model backupData];
        baseVC.costPageVC.flag = YES;
        [baseVC goToCostPage];
    } else if (button.tag == 4) { // OK button
        [self.popupFilterView setHidden:YES];
        [self.popupMaskView setHidden:YES];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-costs.php"] forKey:@"url"];
        [dic setObject:@"0" forKey:@"p"];
        if ([self.fromDateText.text length] > 0) [dic setObject:self.fromDateText.text forKey:@"from_date"];
        if ([self.toDateText.text length] > 0) [dic setObject:self.toDateText.text forKey:@"till_date"];
        if ([self.costText.text length] > 0) [dic setObject:self.costText.text forKey:@"cost_head"];
        if ([self.sortText.text length] > 0) [dic setObject:[baseVC.model getCostSortIndex:self.sortText.text] forKey:@"sort"];
        
        baseVC.model.postOpts = dic;
        [baseVC callServer:GET_COST_LIST];
    } else if (button.tag == 5) { // Cancel button
        [self.popupFilterView setHidden:YES];
        [self.popupMaskView setHidden:YES];
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
    if (debugBCostsPageVC) NSLog(@"BCostsPageVC actionSheet clickedButtonAtIndex: %d" , buttonIndex);
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    } else {
        if (buttonIndex == 0) { // edit button
            NSDictionary *data = [baseVC.model.allData objectAtIndex:curItemIndex];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-cost.php"] forKey:@"url"];
            [dic setObject:[data valueForKey:@"c_id"] forKey:@"id"];
            [dic setObject:@"EDIT_COST" forKey:@"target"];
            
            [baseVC.model backupData];
            baseVC.model.postOpts = dic;
            [baseVC callServer:GET_COST_DETAILS];
        } else if (buttonIndex == 1) { // delete button
            UIAlertView *confirmDlg = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure to delete this customer?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [confirmDlg show];
        }
    }
}

// =================================================
// AlertView Delegate Methods
// =================================================
#pragma mark- AlertView Delegate Methods
//==================================================
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [baseVC.model backupData];
        
        NSDictionary *data = [baseVC.model.allData objectAtIndex:curItemIndex];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"del-cost.php"] forKey:@"url"];
        [dic setObject:[data valueForKey:@"c_id"] forKey:@"id"];
        baseVC.model.postOpts = dic;
        [baseVC callServer:DEL_COST];
    }
}

// =================================================
// Custom Methods
// =================================================
#pragma mark- Custom Methods
//==================================================
- (void)initPopupFilterView
{
    if (debugBCostsPageVC) NSLog(@"BCostsPageVC initPopupFilterView");
    
    self.fromDateText.text = @"";
    self.toDateText.text = @"";
    self.sortText.text = [baseVC.model.costSorts objectAtIndex:0];
    self.costText.text = @"";
}

// =================================================
// TableView Delegate Methods
// =================================================
#pragma mark- TableView Delegate Methods
//==================================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return baseVC.model.allData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CostCell";
    CostCell *cell = (CostCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CostCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *data = [baseVC.model.allData objectAtIndex:indexPath.row];
    if (data) {
        cell.dateLabel.text = [data objectForKey:@"date"] != [NSNull null] ? [AppUtils getConvertedDate:[data objectForKey:@"date"]] : @"";
        cell.headLabel.text = [data objectForKey:@"head"] != [NSNull null] ? [data objectForKey:@"head"] : @"";
        cell.amtLabel.text = [data objectForKey:@"amt"] != [NSNull null] ? [data objectForKey:@"amt"] : @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (debugBCostsPageVC) NSLog(@"BCostsPageVC onSelectListItem");
    curItemIndex = indexPath.row;
    [actionsheet showInView:self.view];
}

- (void)tableViewScrollToTop
{
    if ([self numberOfSectionsInTableView:self.tableView] > 0) {
        NSIndexPath* top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
        [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *visibleRows = [self.tableView visibleCells];
    UITableViewCell *lastVisibleCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableView indexPathForCell:lastVisibleCell];
    
    if (baseVC.model.allData.count % MAXROWS == 0) {
        if (path.row == baseVC.model.allData.count-1) {
            int page = [[baseVC.model.postOpts valueForKey:@"p"] intValue] > 0  ?  [[baseVC.model.postOpts valueForKey:@"p"] intValue]  :  1;
            page += 1;
            [baseVC.model.postOpts setObject:[NSString stringWithFormat:@"%d", page] forKey:@"p"];
            [baseVC.model.postOpts setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-costs.php"] forKey:@"url"];
            [baseVC callServer:GET_COST_LIST];
        }
    }
}

@end
