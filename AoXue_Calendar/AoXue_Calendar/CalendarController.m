//
//  CalendarController.m
//
//  Created by yangqijia on 16/6/3.
//  Copyright © 2016年 yangqijia. All rights reserved.
//

#import "CalendarController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "EventListController.h"
#import "CalendarCell.h"
#import "SSLunarDate.h"

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

static int dayCurrect = 1;

@interface CalendarController ()<UICollectionViewDelegate,UICollectionViewDataSource,EKEventEditViewDelegate>
{
    //event实例
    EKEventStore     *_eventStore;
    //自定义日历UI
    UICollectionView *_mainCollectionView;
    //对应的星期
    NSArray          *_timerArray;
    //年
    NSString         *_year;
    //月
    NSString         *_month;
    //日
    NSString         *_day;
    //当前时间
    NSDate           *_date;
    //当前月总天数
    NSInteger        _allDay;
    //总天数数组
    NSMutableArray   *_allArrayDays;
    //事件数组
    NSMutableArray   *_events;
}

@end

@implementation CalendarController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    if (label) {
        [self getCalendarEvent:label.text];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //实例化
    _eventStore = [[EKEventStore alloc]init];
    //实例化
    //星期数组
    _timerArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    
    _date = [NSDate date];
    //当前年
    _year = [NSString stringWithFormat:@"%d",(int)[self currentYear:_date]];
    //当前月
    _month = [NSString stringWithFormat:@"%d",(int)[self currentMonth:_date]];
    //当前日
    _day = [NSString stringWithFormat:@"%d",(int)[self currentDay:_date]];

    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 30)];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@年%@月%@日",_year,_month,_day];
    label.tag = 100;
    [self.view addSubview:label];
    
    //获取日历权限
    [self getCalendarPermission];
    //获取日历信息
    [self currentMessage:_date];
    //创建collectionView
    [self createCollectionView];
    //获取事件
    [self getCalendarEvent:[self firstDay] last:[self lastDay]];
    //创建button
    [self createButton];
}

/**
 *  获取日历权限
 */
-(void)getCalendarPermission
{
    [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            //[self alertView:@"允许访问日历"];
        } else {
            [self alertView:@"禁止访问日历，可在设置中开启"];
        }
    }];
}

/**
 *  alert提示框
 *
 *  @param content 提示内容
 */
-(void)alertView:(NSString *)content
{
    
    __block CalendarController *weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:content preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//获取日历信息
-(void)currentMessage:(NSDate *)date
{
    [_allArrayDays removeAllObjects];
    //获取本月总天数
    _allDay = [self currentMonthOfDay:date];
    //获取本月第一天星期几
    NSInteger weekInteger = [self currentFirstDay:date];
    if (weekInteger == 6) {
        for (int i = 0; i < _allDay; i++) {
            if (!_allArrayDays) {
                _allArrayDays = [[NSMutableArray alloc]init];
            }
            [_allArrayDays addObject:@"1"];
        }
    }else{
        for (int i = 0; i < (_allDay + weekInteger + 1); i++) {
            if (!_allArrayDays) {
                _allArrayDays = [[NSMutableArray alloc]init];
            }
            if (i <= weekInteger) {
                [_allArrayDays addObject:@"0"];
            }else{
                [_allArrayDays addObject:@"1"];
            }
        }
    }
}

/**
 *  创建collectionView
 */
-(void)createCollectionView
{
    //设置流水布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(SCREEN_WIDTH / 7, SCREEN_WIDTH / 7);
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    
    //创建collectionView
    _mainCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 60, SCREEN_WIDTH, SCREEN_WIDTH) collectionViewLayout:layout];
    _mainCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainCollectionView];
    //注册cell
    [_mainCollectionView registerClass:[CalendarCell class] forCellWithReuseIdentifier:@"cell"];
    //指定代理
    _mainCollectionView.delegate = self;
    _mainCollectionView.dataSource = self;
    //注册heaerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    [_mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cell"];
}
//创建button
-(void)createButton
{
    for (int i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat space = (SCREEN_WIDTH-270)/3;
        button.frame = CGRectMake(space*(i+1)+90*i, _mainCollectionView.frame.size.height+_mainCollectionView.frame.origin.y+10, 90, 30);
        button.tag = 12345+i;
        if (i == 0) {
            [button setTitle:@"上个月" forState:UIControlStateNormal];
        }else if (i == 2) {
            [button setTitle:@"下个月" forState:UIControlStateNormal];
        }else{
            [button setTitle:@"今天" forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"返回首页" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    backBtn.frame = CGRectMake(0, SCREEN_HEIGHT - 30, 120, 30);
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setTitle:@"添加事件" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    addBtn.frame = CGRectMake(SCREEN_WIDTH - 120, SCREEN_HEIGHT - 30, 120, 30);
    [addBtn addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    
}

//切换月份
-(void)button:(UIButton *)sender
{
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    [_events removeAllObjects];
    dayCurrect = 1;
    int year    = [_year intValue];
    int month   = [_month intValue];
    int day     = 1;
    if (sender.tag == 12345) {
        month -= 1;
        if (month == 0) {
            month = 12;
            year -= 1;
        }
        NSDateComponents * components = [[NSDateComponents alloc] init];
        components.year = year;
        components.month = month;
        components.day = day;
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDate *date = [calendar dateFromComponents:components];
        //当前年
        _year = [NSString stringWithFormat:@"%d",year];
        //当前月
        _month = [NSString stringWithFormat:@"%d",month];
        if ([_month integerValue] == [self currentMonth:_date]) {
            _day = [NSString stringWithFormat:@"%d",(int)[self currentDay:_date]];
            label.text = [NSString stringWithFormat:@"%@年%@月%@日",_year,_month,_day];
        }else{
            label.text = [NSString stringWithFormat:@"%@年%@月1日",_year,_month];
        }
        [self currentMessage:date];
    }else if (sender.tag == 12347) {
        month += 1;
        if (month > 12) {
            month = 1;
            year += 1;
        }
        NSDateComponents * components = [[NSDateComponents alloc] init];
        components.year = year;
        components.month = month;
        components.day = day;
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDate *date = [calendar dateFromComponents:components];
        //当前年
        _year = [NSString stringWithFormat:@"%d",year];
        //当前月
        _month = [NSString stringWithFormat:@"%d",month];
        if ([_month integerValue] == [self currentMonth:_date]) {
            _day = [NSString stringWithFormat:@"%d",(int)[self currentDay:_date]];
            label.text = [NSString stringWithFormat:@"%@年%@月%@日",_year,_month,_day];
        }else{
            label.text = [NSString stringWithFormat:@"%@年%@月1日",_year,_month];
        }
        [self currentMessage:date];
    }else{
        //当前年
        _year = [NSString stringWithFormat:@"%d",(int)[self currentYear:_date]];
        //当前月
        _month = [NSString stringWithFormat:@"%d",(int)[self currentMonth:_date]];
        //当前日
        _day = [NSString stringWithFormat:@"%d",(int)[self currentDay:_date]];
        label.text = [NSString stringWithFormat:@"%@年%@月%@日",_year,_month,_day];

        [self currentMessage:_date];
    }
    //通过时间段获取日历事件
    [self getCalendarEvent:label.text];
}

/**
 *  通过时间段获取日历事件
 *
 *  @param time 时间
 */
-(void)getCalendarEvent:(NSString *)time
{
    NSString *string = nil;
    if (![time hasSuffix:@"1日"]) {
        NSArray *array = [time componentsSeparatedByString:@"月"];
        string = [time stringByReplacingOccurrencesOfString:[array objectAtIndex:1] withString:@"1日"];
    }else{
        string = time;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *selectDate = [formatter dateFromString:string];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:selectDate];
    NSDate *startDate = [selectDate dateByAddingTimeInterval:interval];
    
    NSDateComponents *tomorrowDateComponents = [[NSDateComponents alloc] init];
    tomorrowDateComponents.day = [self currentMonthOfDay:startDate];
    
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                    toDate:startDate
                                                                   options:0];
    //获取事件
    [self getCalendarEvent:startDate last:endDate];}

/**
 *  获取当前月的年份
 */
- (NSInteger)currentYear:(NSDate *)date{
    
    NSDateComponents *componentsYear = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [componentsYear year];
}
/**
 *  获取当前月的月份
 */
- (NSInteger)currentMonth:(NSDate *)date{
    
    NSDateComponents *componentsMonth = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [componentsMonth month];
}
/**
 *  获取当前是哪一天
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
- (NSInteger)currentDay:(NSDate *)date{
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}
/**
 *  本月又几天
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
- (NSInteger)currentMonthOfDay:(NSDate *)date{
    
    NSRange totaldaysInMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return totaldaysInMonth.length;
}
/**
 *  本月第一天是星期几
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
- (NSInteger)currentFirstDay:(NSDate *)date{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//1.mon
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}

/**
 *  获取对应的农历
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
- (SSLunarDate *)lunarDaysIntDay:(int)nowIndex{
    
    NSDateComponents * components = [[NSDateComponents alloc] init];
    components.year = [_year integerValue];//[self currentYear:_date];
    components.month = [_month integerValue];//[self currentMonth:_date];
    components.day = nowIndex;
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:components];
    SSLunarDate *lunar = [[SSLunarDate alloc] initWithDate:date];
    return lunar;
}


#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _allArrayDays.count;
}
//设置item及其显示内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarCell *cell = (CalendarCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (cell) {
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    if (_allArrayDays.count > 0) {
        
        if ([[_allArrayDays objectAtIndex:indexPath.item] isEqualToString:@"1"]) {            SSLunarDate *sdate = [self lunarDaysIntDay:dayCurrect];
            //设置item显示内容
            [cell setLabelShowText:dayCurrect month:_month nong:sdate];
            //判断是否有事件 有则创建点
            NSString *dayNumber = [NSString stringWithFormat:@"%d",dayCurrect];
            if ([_events containsObject:dayNumber]) {
                cell.isEvent = YES;
                if (dayCurrect < [_day intValue]) {
                    cell.isValidEvent = NO;
                }else{
                    cell.isValidEvent = YES;
                }
                [cell createDianView];
            }else{
                cell.isEvent = NO;
            }
            dayCurrect++;
            if ([_year integerValue]  == [self currentYear:_date] &&
                [_month integerValue] == [self currentMonth:_date] &&
                indexPath.item-[self currentFirstDay:_date]   == [self currentDay:_date]) {
                cell.layer.cornerRadius = cell.frame.size.height/2;
                cell.backgroundColor = [UIColor redColor];
                [cell showCueeectDate];
            }
        }else{
            [cell hiddenText];
        }
    }
    return cell;
}
//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(SCREEN_WIDTH/7, SCREEN_WIDTH/7);
}
//设置headerView的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH/7);
}
//设置headerView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cell" forIndexPath:indexPath];
    headerView.backgroundColor =[UIColor blackColor];
    
    for (int i = 0; i < 7; i++) {
        UILabel *weekLabel = [[UILabel alloc]initWithFrame:CGRectMake(i*(SCREEN_WIDTH/7), 0, SCREEN_WIDTH/7, SCREEN_WIDTH/7)];
        weekLabel.textAlignment = NSTextAlignmentCenter;
        weekLabel.textColor = [UIColor whiteColor];
        weekLabel.text = [_timerArray objectAtIndex:i];
        [headerView addSubview:weekLabel];
    }
    return headerView;
}
//点击item执行时间
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarCell *cell = (CalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isEvent) {
        UILabel *label = (UILabel *)[self.view viewWithTag:100];
        NSArray *array = [label.text componentsSeparatedByString:@"月"];
        NSString *string = [NSString stringWithFormat:@"%@月%@日",[array objectAtIndex:0],cell.labelDayNumber.text];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        NSDate *selectDate = [formatter dateFromString:string];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate:selectDate];
        NSDate *startDate = [selectDate dateByAddingTimeInterval:interval];
        
        NSDateComponents *tomorrowDateComponents = [[NSDateComponents alloc] init];
        tomorrowDateComponents.day = 1;
        
        NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                        toDate:startDate
                                                                       options:0];
        //获取事件时间段内的事件
        NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:endDate
                                                                    calendars:nil];
        NSArray *arrayEvents = [_eventStore eventsMatchingPredicate:predicate];
        NSMutableArray *eventArrays = [[NSMutableArray alloc]init];
        for (EKEvent *event in arrayEvents) {
            EKCalendar *calendar = event.calendar;
            if (calendar.type == EKCalendarTypeLocal) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"dd"];
                [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+8"]];
                NSString *str = [formatter stringFromDate:event.startDate];
                if ([str intValue] <= [cell.labelDayNumber.text intValue]) {
                    [eventArrays addObject:event];
                }
            }
        }
        EventListController *eventVC = [[EventListController alloc]initWithData:eventArrays date:startDate end:endDate];
        [self.navigationController pushViewController:eventVC animated:YES];
    }else{
        [self add];
    }
}

//当前天日期
-(NSString *)getToday:(int)dayCurrect
{
    if (_month.length == 1) {
        _month = [NSString stringWithFormat:@"0%@",_month];
    }
    NSString *day = nil;
    if (dayCurrect < 10) {
        day = [NSString stringWithFormat:@"0%d",dayCurrect];
    }else{
        day = [NSString stringWithFormat:@"%d",dayCurrect];
    }
    NSString *today = [NSString stringWithFormat:@"%@/%@/%@",_year,_month,day];
    return today;
}

//当月最后一天
-(NSDate *)lastDay
{
    //当月最后一天
    NSString *string = [NSString stringWithFormat:@"%@年%@月%d日 23:59:59",_year,_month,(int)_allDay];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    NSDate *selectDate = [formatter dateFromString:string];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:selectDate];
    NSDate *endDate = [selectDate dateByAddingTimeInterval:interval];
    return endDate;
}

//当月第一天
-(NSDate *)firstDay
{
    //当月第一天
    NSString *string = [NSString stringWithFormat:@"%@年%@月%@日",_year,_month,@"1"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *selectDate = [formatter dateFromString:string];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:selectDate];
    NSDate *startDate = [selectDate dateByAddingTimeInterval:interval];
    return startDate;
}

/**
 *  返回
 */
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  添加事件
 */
-(void)add
{
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
    addController.eventStore = _eventStore;
    addController.editViewDelegate = self;
    [self presentViewController:addController animated:YES completion:nil];
}

#pragma mark - EKEventEditViewDelegate
- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    CalendarController * __weak weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^
     {
         if (action != EKEventEditViewActionCanceled)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 UILabel *label = (UILabel *)[self.view viewWithTag:100];
                 [weakSelf getCalendarEvent:label.text];
             });
         }
     }];
}

/**
 *  获取日历事件
 *
 *  @param start 开始时间
 *  @param end   结束时间
 */
-(void)getCalendarEvent:(NSDate *)start last:(NSDate *)end
{
    //获取事件时间段内的事件
    NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:start
                                                                  endDate:end
                                                                calendars:nil];
    NSArray *array = [_eventStore eventsMatchingPredicate:predicate];
    for (EKEvent *event in array) {
        EKCalendar *calendar = event.calendar;
        if (calendar.type == EKCalendarTypeLocal) {
            if (!_events) {
                _events = [[NSMutableArray alloc]init];
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy/MM/dd"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+8"]];
            NSString *start = [formatter stringFromDate:event.startDate];
            NSString *end = [formatter stringFromDate:event.endDate];
            NSArray *array = [self dateNumber:start string:end];
            for (int i = 0; i < array.count; i++) {
                if (![_events containsObject:[array objectAtIndex:i]]) {
                    [_events addObject:[array objectAtIndex:i]];
                }
            }
        }
    }
    dayCurrect = 1;
    [_mainCollectionView reloadData];
}

/**
 *  获取带有事件的天
 *
 *  @param start 开始时间
 *  @param end   结束时间
 *
 *  @return 返回数组
 */
-(NSArray *)dateNumber:(NSString *)start string:(NSString *)end
{
    NSArray *startArray = [start componentsSeparatedByString:@"/"];
    NSArray *endArray = [end componentsSeparatedByString:@"/"];
    NSString *string = [NSString stringWithFormat:@"%d",[[startArray objectAtIndex:1] intValue]];
    int startDay = [[startArray objectAtIndex:2] intValue];
    int endDay   = [[endArray objectAtIndex:2] intValue];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (int i = startDay; i <= endDay; i++) {
        if ([string isEqualToString:_month]) {
            [array addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return array;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_events removeAllObjects];
    dayCurrect = 1;
}

/**
 *  随机颜色
 *
 *  @return 返回颜色
 */
-(UIColor *)randomColor
{
    CGFloat r = arc4random()%256/255.0;
    CGFloat g = arc4random()%256/255.0;
    CGFloat b = arc4random()%256/255.0;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    return color;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
