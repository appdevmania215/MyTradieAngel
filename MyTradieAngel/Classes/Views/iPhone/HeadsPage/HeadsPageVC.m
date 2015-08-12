//
//  HeadsPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/27/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "HeadsPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"

#import "HeadCell.h"

@interface HeadsPageVC ()<UIActionSheetDelegate>
{
    int curItemIndex;
    NSString *headId;

    BaseVC *baseVC;
    UIActionSheet *actionsheet;
}
@end

@implementation HeadsPageVC

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
    
    [baseVC makeButtonUI:self.saveBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    [baseVC makeButtonUI:self.closeBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    
    self.popupMaskView = [[UIView alloc] init];
    [self.popupMaskView setFrame:self.view.frame];
    [self.view addSubview:self.popupMaskView];
    [self.popupMaskView setBackgroundColor:[UIColor blackColor]];
    [self.popupMaskView setAlpha:0.5f];
    [self.popupMaskView setHidden:YES];
    
    [self.view addSubview:self.popupEditView];
    self.popupEditView.layer.cornerRadius = 10.0f;
    self.popupEditView.center = self.view.center;
    [self.popupEditView setHidden:YES];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.popupTitle.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10.0f, 10.0f)];
    maskLayer.path = maskPath.CGPath;
    self.popupTitle.layer.mask = maskLayer;
    
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

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark- Button Delegate Methods
//==================================================
- (IBAction)buttonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (debugHeadsPageVC) NSLog(@"HeadsPageVC buttonPressed: %d", button.tag);
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    if (button.tag == 1) { // Home button
        [baseVC goToPrevPage];
    } else if (button.tag == 2) { // Add new Item button
        [self initPopupEditView];
        
        [self.popupMaskView setHidden:NO];
        [self.popupEditView setHidden:NO];
    } else if (button.tag == 3) { // Save button
        if ([self.headText.text isEqualToString:@""]) {
            [baseVC showToastMessage:@"Enter the head text" ForSec:1];
            return;
        }
        [self.popupEditView setHidden:YES];
        [self.popupMaskView setHidden:YES];
        
        [baseVC.model backupData];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"update-head.php"] forKey:@"url"];
        [dic setObject:headId forKey:@"id"];
        [dic setObject:self.headText.text forKey:@"head"];
        baseVC.model.postOpts = dic;
        [baseVC callServer:UPDATE_HEAD];
    } else if (button.tag == 4) { // Close button
        [self.popupEditView setHidden:YES];
        [self.popupMaskView setHidden:YES];
    }
}

// =================================================
// Actionsheet Methods
// =================================================
#pragma mark- Actionsheet Methods
//==================================================
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (debugHeadsPageVC) NSLog(@"HeadsPageVC actionSheet clickedButtonAtIndex: %d" , buttonIndex);
    
    NSString *buttonTitle = [actionsheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    } else {
        if (buttonIndex == 0) { // edit button
            [self fillPopupEditView];
            
            [self.popupMaskView setHidden:NO];
            [self.popupEditView setHidden:NO];
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
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"del-head.php"] forKey:@"url"];
        [dic setObject:[data valueForKey:@"head_id"] forKey:@"id"];
        baseVC.model.postOpts = dic;
        [baseVC callServer:DEL_HEAD];
    }
}

// =================================================
// Custom Methods
// =================================================
#pragma mark- Custom Methods
//==================================================
- (void)initPopupEditView
{
    if (debugHeadsPageVC) NSLog(@"HeadsPageVC initPopupEditView");
    
    headId = @"0";
    self.headText.text = @"";
}

- (void)fillPopupEditView
{
    if (debugHeadsPageVC) NSLog(@"HeadsPageVC fillPopupEditView");
    
    NSDictionary *data = [baseVC.model.allData objectAtIndex:curItemIndex];
    headId = [data valueForKey:@"head_id"];
    self.headText.text = [data valueForKey:@"head"];
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
    return 35.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HeadCell";
    HeadCell *cell = (HeadCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeadCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *data = [baseVC.model.allData objectAtIndex:indexPath.row];
    if (data) {
        cell.headLabel.text = [data objectForKey:@"head"] != [NSNull null] ? [data objectForKey:@"head"] : @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (debugHeadsPageVC) NSLog(@"HeadsPageVC onSelectListItem");
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
    
    if (baseVC.model.allData.count % (MAXROWS*2) == 0) {
        if (path.row == baseVC.model.allData.count-1) {
            int page = [[baseVC.model.postOpts valueForKey:@"p"] intValue] > 0  ?  [[baseVC.model.postOpts valueForKey:@"p"] intValue]  :  1;
            page += 1;
            [baseVC.model.postOpts setObject:[NSString stringWithFormat:@"%d", page] forKey:@"p"];
            [baseVC.model.postOpts setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-heads.php"] forKey:@"url"];
            [baseVC callServer:GET_HEAD_LIST];
        }
    }
}
@end
