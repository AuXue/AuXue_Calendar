//
//  ViewController.m
//  AoXue_Calendar
//
//  Created by yangqijia on 16/6/29.
//  Copyright © 2016年 yangqijia. All rights reserved.
//

#import "ViewController.h"
#import "CalendarController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *goCalendarVC = [UIButton buttonWithType:UIButtonTypeCustom];
    [goCalendarVC setTitle:@"前往日历" forState:UIControlStateNormal];
    [goCalendarVC setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [goCalendarVC setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    goCalendarVC.titleLabel.font = [UIFont systemFontOfSize:25];
    goCalendarVC.frame = CGRectMake(0, 0, 200, 50);
    goCalendarVC.center = self.view.center;
    [goCalendarVC addTarget:self action:@selector(goCalendar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goCalendarVC];
    
}

-(void)goCalendar
{
    CalendarController *calendarVC = [[CalendarController alloc]init];
    [self.navigationController pushViewController:calendarVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
