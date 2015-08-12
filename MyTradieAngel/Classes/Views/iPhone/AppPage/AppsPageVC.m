//
//  AppsPageVC.m
//  MyTradieAngel
//
//  Created by RenZhe Ahn on 3/28/14.
//  Copyright (c) 2014 Softaic. All rights reserved.
//

#import "AppsPageVC.h"

#import "AppConst.h"
#import "Model.h"
#import "BaseVC.h"
#import "AppUtils.h"

#import "AppPageVC.h"

#import "DPCalendarMonthlySingleMonthViewLayout.h"
#import "DPCalendarMonthlyView.h"
#import "DPCalendarEvent.h"
#import "DPCalendarIconEvent.h"
#import "NSDate+DP.h"
#import "DPCalendarTestOptionsViewController.h"

@interface AppsPageVC ()<DPCalendarMonthlyViewDelegate>
{
    BaseVC *baseVC;
}

@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *todayButton;
@property (nonatomic, strong) UIButton *createEventButton;
@property (nonatomic, strong) UIButton *optionsButton;

@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSMutableArray *iconEvents;

@property (nonatomic, strong) DPCalendarMonthlyView *monthlyView;

@property (nonatomic, strong) NSString *completed;

@end

@implementation AppsPageVC

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
    [self commonInit];
    self.completed = @"0";
    
    NSString *boldFontName = @"Optima-ExtraBlack";
    UIColor* darkColor = [UIColor colorWithRed:10.0/255 green:78.0/255 blue:108.0/255 alpha:1.0f];
    
    [baseVC makeButtonUI:self.showBtn FontName:boldFontName FontSize:14.f BackColor:darkColor];
    
    [self updateLabelWithMonth:self.monthlyView.seletedMonth];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithView:(BaseVC *)rootVC
{
    if (debugPaymentsPageVC) NSLog(@"PaymentsPageVC initWithView");
    baseVC = rootVC;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadAppointments];
}

// =================================================
// Button Delegate Methods
// =================================================
#pragma mark- Button Delegate Methods
//==================================================
- (IBAction)buttonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (debugAppsPageVC) NSLog(@"AppsPageVC buttonPressed: %d", button.tag);
    [self.view setBackgroundColor:[UIColor clearColor]];
    if (button.tag == 1) {
        [baseVC goToPrevPage];
    } else if (button.tag == 2) { // getting recurring apps
        [baseVC goToRecurAppsPage];
    } else if (button.tag == 3) {
        if ([self.completed isEqualToString:@"1"]) {
            [button setTitle:@"Show Completed Appointments Only" forState:UIControlStateNormal];
            self.completed = @"0";
        } else {
            [button setTitle:@"Show Current Appointments Only" forState:UIControlStateNormal];
            self.completed = @"1";
        }
        [self loadAppointments];
    }
}

// =================================================
// DPCalendarMonthlyView Methods
// =================================================
#pragma mark- DPCalendarMonthlyView Methods
//==================================================
-(void) commonInit {
    [self generateMonthlyView];
    [self updateLabelWithMonth:self.monthlyView.seletedMonth];
}

- (void) generateMonthlyView {
    CGFloat width = [self.class currentSize].width;
    CGFloat height = [self.class currentSize].height - 100.f;
    
    [self.previousButton removeFromSuperview];
    [self.nextButton removeFromSuperview];
    [self.monthLabel removeFromSuperview];
    [self.todayButton removeFromSuperview];
    [self.optionsButton removeFromSuperview];
    [self.createEventButton removeFromSuperview];
    
    float headerHeight = 105.f;
    self.monthLabel = [[UILabel alloc] initWithFrame:CGRectMake((width - 150) / 2, headerHeight, 150, 20)];
    [self.monthLabel setTextAlignment:NSTextAlignmentCenter];
    
    self.previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.previousButton setBackgroundImage:[UIImage imageNamed:@"IconArrowPrev"] forState:UIControlStateNormal];
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"IconArrowNext"] forState:UIControlStateNormal];
    self.todayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.optionsButton  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.createEventButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.createEventButton setBackgroundImage:[UIImage imageNamed:@"BtnAddSomething"] forState:UIControlStateNormal];
    self.previousButton.frame = CGRectMake(self.monthLabel.frame.origin.x - 18, headerHeight, 18, 20);
    self.nextButton.frame = CGRectMake(CGRectGetMaxX(self.monthLabel.frame), headerHeight, 18, 20);
    self.todayButton.frame = CGRectMake(width - 60, headerHeight, 60, 21);
    self.optionsButton.frame = CGRectMake(width - 50 * 3, headerHeight, 50, 20);
    self.createEventButton.frame = CGRectMake(10, headerHeight, 20, 20);
    [self.todayButton setTitle:@"Today" forState:UIControlStateNormal];
    [self.optionsButton setTitle:@"Option" forState:UIControlStateNormal];
    
    [self.previousButton addTarget:self action:@selector(previousButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton addTarget:self action:@selector(nextButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.todayButton addTarget:self action:@selector(todayButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.optionsButton addTarget:self action:@selector(optionsButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.createEventButton addTarget:self action:@selector(createEventButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.monthLabel];
    [self.view addSubview:self.previousButton];
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.todayButton];
    //    [self.view addSubview:self.optionsButton];
    [self.view addSubview:self.createEventButton];
    [self.monthlyView removeFromSuperview];
    self.monthlyView = [[DPCalendarMonthlyView alloc] initWithFrame:CGRectMake(0, 130, width, height - 30) delegate:self];
    [self.view addSubview:self.monthlyView];
    
    [self.monthlyView setEvents:self.events complete:nil];
    [self.monthlyView setIconEvents:self.iconEvents complete:nil];
}

- (void) generateData {
    self.events = @[].mutableCopy;
    //self.iconEvents = @[].mutableCopy;
    
    int colorIndex;
    if ([self.completed isEqualToString:@"1"]) colorIndex = 1;
    else colorIndex = 0;
    
    for (NSDictionary *dic in baseVC.model.allData) {
        NSDate *startTime = [AppUtils getDateTimeFromString:[dic objectForKey:@"start_time"]];
        NSDate *endTime = [AppUtils getDateTimeFromString:[dic objectForKey:@"end_time"]];
        NSString *title = [AppUtils getTitleTimeFromDate:startTime];
        title = [NSString stringWithFormat:@"%@ %@", title, [dic objectForKey:@"name"]];
        DPCalendarEvent *event = [[DPCalendarEvent alloc] initWithTitle:title startTime:startTime endTime:endTime colorIndex:colorIndex EventId:[[dic objectForKey:@"event_id"] intValue]];
        [self.events addObject:event];
    }
}

-(void) previousButtonSelected:(id)button {
    [self.monthlyView scrollToPreviousMonthWithComplete:nil];
}

-(void) nextButtonSelected:(id)button {
    [self.monthlyView scrollToNextMonthWithComplete:nil];
}

-(void) todayButtonSelected:(id)button {
    [self.monthlyView clickDate:[NSDate date]];
}

-(void) optionsButtonSelected:(id)button {
    DPCalendarTestOptionsViewController *optionController = [DPCalendarTestOptionsViewController new];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:optionController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"TEST" forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 70, 40 );
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    navController.navigationItem.rightBarButtonItem = rightBarBtn;
    if ([AppUtils isPad]) {
        [self presentViewController:navController animated:YES completion:nil];
    } else {
        
    }
}

- (void) createEventButtonSelected:(id)button {
    if ([self.completed isEqualToString:@"1"]) {
        [baseVC showToastMessage:@"Can't add completed appointments" ForSec:1];
        return;
    }
    [self setYearAndMonthOfAppPage];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"EDIT_APP" forKey:@"target"];
    
    [baseVC.model backupData];
    baseVC.model.postOpts = dic;
    [baseVC callServer:NEW_APP];
}

- (void) updateLabelWithMonth:(NSDate *)month {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM YYYY"];
    NSString *stringFromDate = [formatter stringFromDate:month];
    [self.monthLabel setText:stringFromDate];
}

// =================================================
// DPCalendarMonthlyView Methods
// =================================================
#pragma mark- DPCalendarMonthlyView Delegate Methods
//==================================================
-(void)didScrollToMonth:(NSDate *)month firstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate{
    [self updateLabelWithMonth:month];
    
    [self loadAppointments];
}

-(void)didSkipToMonth:(NSDate *)month firstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    [self updateLabelWithMonth:month];
}

-(void)didTapEvent:(DPCalendarEvent *)event onDate:(NSDate *)date {
    NSLog(@"Touched event %d, %@", event.eventId, self.monthlyView.seletedMonth);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:self.monthlyView.seletedMonth];
    int selectedYear = [comps year];
    int selectedMonth = [comps month];
    
    comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:event.startTime];
    int startedYear = [comps year];
    int startedMonth = [comps month];
    
    if (selectedYear == startedYear  &&  selectedMonth == startedMonth) {
        [self setYearAndMonthOfAppPage];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        for (NSDictionary *data in baseVC.model.allData) {
            if ([[data objectForKey:@"event_id"] intValue] == event.eventId) {
                [dic setObject:data forKey:@"data"];
                break;
            }
        }
        
        [dic setObject:[NSString stringWithFormat:@"%d", event.eventId] forKey:@"id"];
        [dic setObject:@"EDIT_APP" forKey:@"target"];
        
        [baseVC.model backupData];
        baseVC.model.postOpts = dic;
        [baseVC callServer:GET_APP_DETAILS];
    }
}

-(BOOL)shouldHighlightItemWithDate:(NSDate *)date {
    return YES;
}

-(BOOL)shouldSelectItemWithDate:(NSDate *)date {
    return YES;
}

-(void)didSelectItemWithDate:(NSDate *)date {
    NSLog(@"Select date %@ with \n events %@ \n and icon events %@", date, [self.monthlyView eventsForDay:date], [self.monthlyView iconEventsForDay:date]);
}

-(NSDictionary *) ipadMonthlyViewAttributes {
    return @{
             DPCalendarMonthlyViewAttributeCellRowHeight: @23,
             //             DPCalendarMonthlyViewAttributeEventDrawingStyle: [NSNumber numberWithInt:DPCalendarMonthlyViewEventDrawingStyleUnderline],
             DPCalendarMonthlyViewAttributeStartDayOfWeek: @0,
             DPCalendarMonthlyViewAttributeWeekdayFont: [UIFont systemFontOfSize:18],
             DPCalendarMonthlyViewAttributeDayFont: [UIFont systemFontOfSize:14],
             DPCalendarMonthlyViewAttributeEventFont: [UIFont systemFontOfSize:14],
             DPCalendarMonthlyViewAttributeMonthRows:@5,
             DPCalendarMonthlyViewAttributeIconEventBkgColors: @[[UIColor clearColor], [UIColor colorWithRed:239/255.f green:239/255.f blue:244/255.f alpha:1]]
             };
}

-(NSDictionary *) iphoneMonthlyViewAttributes {
    return @{
             DPCalendarMonthlyViewAttributeEventDrawingStyle: [NSNumber numberWithInt:DPCalendarMonthlyViewEventDrawingStyleUnderline],
             DPCalendarMonthlyViewAttributeCellNotInSameMonthSelectable: @YES,
             DPCalendarMonthlyViewAttributeMonthRows:@3
             };
    
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self commonInit];
}

-(NSDictionary *)monthlyViewAttributes {
    if ([AppUtils isPad]) {
        return [self ipadMonthlyViewAttributes];
    } else {
        return [self iphoneMonthlyViewAttributes];
    }
}

+(CGSize) currentSize
{
    return [self sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    return size;
}

#pragma mark - DPCalendarTestCreateEventViewControllerDelegate
-(void)eventCreated:(DPCalendarEvent *)event {
    [self.events addObject:event];
    [self.monthlyView setEvents:self.events complete:nil];
    
}

// =================================================
// Custom Methods
// =================================================
#pragma mark- Custom Methods
//==================================================
- (void)loadAppointments
{
    if (debugAppsPageVC) NSLog(@"loadAppointments: @%@", self.monthlyView.seletedMonth);
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSString stringWithFormat:@"%@%@", API_BASE_URL, @"get-apps.php"] forKey:@"url"];
    [dic setObject:@"MONTH" forKey:@"t"];
    [dic setObject:self.completed forKey:@"comp"];
    
    NSDate *date = self.monthlyView.seletedMonth;
    NSDate *startDate = [AppUtils convertGMTtoLocal:[AppUtils getStartDateOfMonthCalendar:date]];
    NSDate *lastDate = [AppUtils convertGMTtoLocal:[AppUtils getLastDateOfMonthCalendar:date]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:startDate];
    int year = [comps year];
    int month = [comps month];
    int day = [comps day];
    
    comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:lastDate];
    int year2 = [comps year];
    int month2 = [comps month];
    int day2 = [comps day];
    
    [dic setObject:[NSString stringWithFormat:@"%d", year] forKey:@"y"];
    [dic setObject:[NSString stringWithFormat:@"%02d", month] forKey:@"m"];
    [dic setObject:[NSString stringWithFormat:@"%02d", day] forKey:@"d"];
    [dic setObject:[NSString stringWithFormat:@"%d", year2] forKey:@"y2"];
    [dic setObject:[NSString stringWithFormat:@"%02d", month2] forKey:@"m2"];
    [dic setObject:[NSString stringWithFormat:@"%02d", day2] forKey:@"d2"];
    
    baseVC.model.postOpts = dic;
    [baseVC callServer:GET_APPS_LIST];
    
    [self generateData];
    [self.monthlyView setEvents:self.events complete:nil];
    [self.monthlyView setIconEvents:self.iconEvents complete:nil];
}

- (void)setYearAndMonthOfAppPage
{
    if (debugAppsPageVC) NSLog(@"AppsPageVC setYearAndMonthOfAppPage");
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:self.monthlyView.seletedMonth];
    int selectedYear = [comps year];
    int selectedMonth = [comps month];
    
    baseVC.appPageVC.selectedYear = selectedYear;
    baseVC.appPageVC.selectedMonth = selectedMonth;
}

@end
