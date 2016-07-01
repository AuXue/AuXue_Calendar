//
//  ColorUtil.h
//
//  Created by yangqijia on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ColorUtil : NSObject
/**
 *  获取十六进制颜色
 *
 *  @param hexColor 十六进制
 *  @param alpha    透明度
 *
 *  @return color
 */
+(UIColor *)getColor:(NSString *)hexColor alpha:(CGFloat)alpha;

@end
