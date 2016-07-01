//
//  CalendarCell.h
//
//  Created by yangqijia on 16/6/12.
//  Copyright © 2016年 yangqijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSLunarDate.h"

@interface CalendarCell : UICollectionViewCell

@property(nonatomic, strong)UILabel *labelDayNumber;
@property(nonatomic, strong)UILabel *labelNongNumber;
@property(nonatomic, strong)UIView  *dianView;
@property(nonatomic, assign)BOOL    isValidEvent;
@property(nonatomic, assign)BOOL    isEvent;
//设置显示内容
-(void)setLabelShowText:(int)day month:(NSString *)month nong:(SSLunarDate *)date;
//隐藏显示
-(void)hiddenText;
//突出显示今天
-(void)showCueeectDate;
//创建节日点
-(void)createDianView;
@end
