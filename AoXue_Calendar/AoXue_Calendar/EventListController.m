//
//  EventListController.m
//  AoXue_Calendar
//
//  Created by yangqijia on 16/6/30.
//  Copyright © 2016年 yangqijia. All rights reserved.
//

#import "EventListController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
@interface EventListController ()<EKEventViewDelegate>
{
    //event实例
    EKEventStore     *_eventStore;
}
@end

@implementation EventListController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

-(id)initWithData:(NSArray *)array date:(NSDate *)date end:(NSDate *)end
{
    self = [super init];
    if (self) {
        _dataArray = [[NSMutableArray alloc]initWithArray:array];
        _date = date;
        _end = end;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.hidden = NO;
    self.title = @"EVENT";
    
    //实例化
    _eventStore = [[EKEventStore alloc]init];

    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"eventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }else{
        cell.textLabel.text = @" ";
        cell.detailTextLabel.text = @" ";
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    EKEvent *event = [_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = event.title;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+8"]];
    NSString *startDate = [formatter stringFromDate:event.startDate];
    NSString *endDate = [formatter stringFromDate:event.endDate];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@--%@",startDate,endDate];
    return cell;
}

/**
 *  点击列表进入事件编辑界面
 *
 *  @param tableView
 *  @param indexPath
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EKEventViewController *editEvent = [[EKEventViewController alloc] init];
    editEvent.delegate = self;
    editEvent.event = [_dataArray objectAtIndex:indexPath.row];
    editEvent.allowsEditing = YES;
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:editEvent];
    [self presentViewController:nav animated:YES completion:nil];
}



#pragma mark - EKEventEditViewDelegate
- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action
{
    controller.tabBarController.tabBar.hidden = YES;
    EventListController * __weak weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
         [weakSelf getCalendarEvent:_date last:_end];
     }];
}

/**
 *  获取日历事件刷新列表
 *
 *  @param start 开始时间
 *  @param end   结束时间
 */
-(void)getCalendarEvent:(NSDate *)start last:(NSDate *)end
{
    //移除数据
    [_dataArray removeAllObjects];
    //获取事件时间段内的事件
    NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:start
                                                                  endDate:end
                                                                calendars:nil];
    NSArray *array = [_eventStore eventsMatchingPredicate:predicate];
    for (EKEvent *event in array) {
        EKCalendar *calendar = event.calendar;
        if (calendar.type == EKCalendarTypeLocal) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy/MM/dd"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+8"]];
            NSString *start = [formatter stringFromDate:event.startDate];
            NSString *date = [formatter stringFromDate:_date];
            if ([start isEqualToString:date]) {
                [_dataArray addObject:event];
            }
        }
    }
    [_tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
