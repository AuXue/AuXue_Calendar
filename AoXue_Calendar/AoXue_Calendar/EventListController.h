//
//  EventListController.h
//  AoXue_Calendar
//
//  Created by yangqijia on 16/6/30.
//  Copyright © 2016年 yangqijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventListController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView        *_tableView;
    NSMutableArray     *_dataArray;
    NSDate             *_date;
    NSDate             *_end;
}

-(id)initWithData:(NSArray *)array date:(NSDate *)date end:(NSDate *)end;

@end
