//
//  RecurAppsPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "RecurAppsPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"
#import "AppUtils.h"

#import "RecurAppCell.h"

@interface RecurAppsPageVC ()<UIActionSheetDelegate>
{
    NSInteger curItemIndex;
    BaseVC *baseVC;
    UIActionSheet *actionsheet;
}

@end

@implementation RecurAppsPageVC

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
    // Create Action Sheet
    NSString *actionSheetTitle = @"Please select a action you want"; //Action Sheet Title
    //NSString *destructiveTitle = @"Destructive Button"; //Action Sheet Button Titles
    NSString *cancelTitle = @"Cancel";
    actionsheet = [[UIActionSheet alloc]
                        initWithTitle:actionSheetTitle
                        delegate:self
                        cancelButtonTitle:cancelTitle
                        destructiveButtonTitle:nil
                        otherButtonTitles:@"Delete this appointment", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugAppPageVC) NSLog(@"AppPageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.itemNumLabel.text = [NSString stringWithFormat:@"    Total Items: %d", baseVC.model.allData.count];
}

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark- Button Delegate Methods
//==================================================
- (IBAction)buttonPressed:(id)sender
{
    if (debugRecurAppsPageVC) NSLog(@"RecurAppsPageVC buttonPressed");
    [baseVC goToPrevPage];
}

// =================================================
// Actionsheet Methods
// =================================================
#pragma mark- Actionsheet Methods
//==================================================
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (debugInvoicesPageVC) NSLog(@"InvoicesPageVC actionSheet clickedButtonAtIndex: %d" , buttonIndex);
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    } else if (buttonIndex == 0) { // delete button
        UIAlertView *confirmDlg = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure to delete this appointment?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmDlg show];
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
        [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"del-recur.php"] forKey:@"url"];
        [dic setObject:[data valueForKey:@"recur_id"] forKey:@"id"];
        baseVC.model.postOpts = dic;
        [baseVC callServer:DEL_RECUR_APP];
    }
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
    return 95.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecurAppCell";
    RecurAppCell *cell = (RecurAppCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecurAppCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *data = [baseVC.model.allData objectAtIndex:indexPath.row];
    if (data) {
        cell.customerNameLabel.text = [data objectForKey:@"cust_name"] != [NSNull null] ? [data objectForKey:@"cust_name"] : @"";
        cell.fromTimeLabel.text = [data objectForKey:@"start_time"] != [NSNull null] ? [data objectForKey:@"start_time"] : @"";
        cell.toTimeLabel.text = [data objectForKey:@"end_time"] != [NSNull null] ? [data objectForKey:@"end_time"] : @"";
        NSString *repeatText;
        if ([[data objectForKey:@"every_week"] intValue] == 1) {
            repeatText = @"Every week";
        } else if ([[data objectForKey:@"every_week"] intValue] > 1) {
            repeatText = [NSString stringWithFormat:@"Every %@ week(s)", [data objectForKey:@"every_week"]];
        } else {
            repeatText = @"";
        }
        cell.repeatLabel.text = repeatText;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (debugRecurAppsPageVC) NSLog(@"RecurAppsPageVC onSelectListItem");
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
            [baseVC.model.postOpts setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-recurring.php"] forKey:@"url"];
            [baseVC.model.postOpts setObject:@"GET_RECUR_APPS_LIST" forKey:@"target"];
            
            [baseVC callServer:GET_RECUR_APPS_LIST];
        }
    }
}
@end
