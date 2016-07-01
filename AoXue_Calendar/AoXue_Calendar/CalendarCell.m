//
//  CalendarCell.m
//
//  Created by yangqijia on 16/6/12.
//  Copyright © 2016年 yangqijia. All rights reserved.
//

#import "CalendarCell.h"
#import "ColorUtil.h"

@implementation CalendarCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}
//创建UI
-(void)createUI
{
    if (!_labelDayNumber) {
        _labelDayNumber = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.frame.size.width, self.frame.size.height/2)];
    }
    _labelDayNumber.textAlignment = NSTextAlignmentCenter;
    _labelDayNumber.textColor = [UIColor blackColor];
    _labelDayNumber.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_labelDayNumber];
    
    if (!_labelNongNumber) {
        _labelNongNumber = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/3)];
    }
    _labelNongNumber.textAlignment = NSTextAlignmentCenter;
    _labelNongNumber.textColor = [UIColor lightGrayColor];
    _labelNongNumber.backgroundColor = [UIColor clearColor];
    _labelNongNumber.adjustsFontSizeToFitWidth = YES;
    _labelNongNumber.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_labelNongNumber];
}
//设置显示内容
-(void)setLabelShowText:(int)day month:(NSString *)month nong:(SSLunarDate *)date
{
    NSString *dayStr = nil;
    if (day < 10) {
        dayStr = [NSString stringWithFormat:@"0%d",day];
    }else{
        dayStr = [NSString stringWithFormat:@"%d",day];
    }
    NSString *monthStr = month;
    NSString *festival = [self festivalDay:dayStr month:monthStr];
    if ([festival isEqualToString:@"nil"]) {
        festival = [self festivalDay:[date dayString] month:[date monthString]];
        if ([festival isEqualToString:@"nil"]) {
            festival = [date dayString];
            if ([festival isEqualToString:@"初一"]) {
                festival = [date monthString];
            }
        }
    }
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    [self createUI];
    _labelDayNumber.text = [NSString stringWithFormat:@"%d",day];
    _labelNongNumber.text = festival;
}

//创建节日点
-(void)createDianView
{
    _dianView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 5)];
    _dianView.layer.cornerRadius = 2.5;
    _dianView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height-4);
    if (_isValidEvent) {
        _dianView.backgroundColor = [ColorUtil getColor:@"1BADF8" alpha:1];
    }else{
        _dianView.backgroundColor = [UIColor lightGrayColor];
    }
    [self.contentView addSubview:_dianView];
}

//隐藏显示
-(void)hiddenText
{
    _labelDayNumber.text = @"";
    _labelNongNumber.text = @"";
}
//突出显示今天
-(void)showCueeectDate
{
    _labelDayNumber.textColor = [UIColor whiteColor];
    _labelNongNumber.textColor = [UIColor whiteColor];
}

//排查节日
-(NSString *)festivalDay:(NSString *)day month:(NSString *)month
{
    NSString *festival = @"nil";
    if ([month isEqualToString:@"1"] && [day isEqualToString:@"01"]) {
        festival = @"元旦";
    }else if ([month isEqualToString:@"2"] && [day isEqualToString:@"14"]) {
        festival = @"情人节";
    }else if ([month isEqualToString:@"3"] && [day isEqualToString:@"8"]) {
        festival = @"妇女节";
    }else if ([month isEqualToString:@"3"] && [day isEqualToString:@"12"]) {
        festival = @"植树节";
    }else if ([month isEqualToString:@"4"] && [day isEqualToString:@"01"]) {
        festival = @"愚人节";
    }else if ([month isEqualToString:@"5"] && [day isEqualToString:@"01"]) {
        festival = @"劳动节";
    }else if ([month isEqualToString:@"5"] && [day isEqualToString:@"04"]) {
        festival = @"青年节";
    }else if ([month isEqualToString:@"6"] && [day isEqualToString:@"01"]) {
        festival = @"儿童节";
    }else if ([month isEqualToString:@"7"] && [day isEqualToString:@"01"]) {
        festival = @"建党节";
    }else if ([month isEqualToString:@"8"] && [day isEqualToString:@"01"]) {
        festival = @"建军节";
    }else if ([month isEqualToString:@"9"] && [day isEqualToString:@"10"]) {
        festival = @"教师节";
    }else if ([month isEqualToString:@"10"] && [day isEqualToString:@"01"]) {
        festival = @"国庆节";
    }else if ([month isEqualToString:@"11"] && [day isEqualToString:@"11"]) {
        festival = @"光棍节";
    }else if ([month isEqualToString:@"正月"] && [day isEqualToString:@"初一"]) {
        festival = @"春节";
    }else if ([month isEqualToString:@"正月"] && [day isEqualToString:@"十五"]) {
        festival = @"元宵节";
    }else if ([month isEqualToString:@"四月"] && [day isEqualToString:@"初五"]) {
        festival = @"清明节";
    }else if ([month isEqualToString:@"五月"] && [day isEqualToString:@"初五"]) {
        festival = @"端午节";
    }else if ([month isEqualToString:@"七月"] && [day isEqualToString:@"初七"]) {
        festival = @"七夕";
    }else if ([month isEqualToString:@"七月"] && [day isEqualToString:@"十五"]) {
        festival = @"中元节";
    }else if ([month isEqualToString:@"八月"] && [day isEqualToString:@"十五"]) {
        festival = @"中秋节";
    }else if ([month isEqualToString:@"九月"] && [day isEqualToString:@"初九"]) {
        festival = @"重阳节";
    }else if ([month isEqualToString:@"腊月"] && [day isEqualToString:@"初八"]) {
        festival = @"腊八节";
    }else if ([month isEqualToString:@"腊月"] && [day isEqualToString:@"二十三"]) {
        festival = @"小年";
    }else if ([month isEqualToString:@"腊月"] && [day isEqualToString:@"三十"]) {
        festival = @"除夕";
    }
    return festival;
}






@end
