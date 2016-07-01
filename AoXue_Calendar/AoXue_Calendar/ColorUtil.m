//
//  ColorUtil.m
//  
//
//  Created by yangqijia on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ColorUtil.h"

@implementation ColorUtil

/**
 *  获取十六进制颜色
 *
 *  @param hexColor 十六进制
 *  @param alpha    透明度
 *
 *  @return color
 */
+ (UIColor *)getColor:(NSString *)hexColor alpha:(CGFloat)alpha
{
	unsigned int red, green, blue;
	NSRange range;
	range.length = 2;
	
	range.location = 0; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
	range.location = 2; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
	range.location = 4; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];	
	
	return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:alpha];
}


@end
