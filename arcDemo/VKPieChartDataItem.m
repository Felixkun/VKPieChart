//
//  VKPieChartDataItem.m
//  arcDemo
//
//  Created by Felix on 2016/12/6.
//  Copyright © 2016年 Felix. All rights reserved.
//

#import "VKPieChartDataItem.h"

@implementation VKPieChartDataItem

    
+ (instancetype)dataItemWithValue:(CGFloat)value
                            color:(UIColor*)color{
    VKPieChartDataItem *item = [VKPieChartDataItem new];
    item.value = value;
    item.color  = color;
    return item;
}
    
+ (instancetype)dataItemWithValue:(CGFloat)value
                            color:(UIColor*)color
                      description:(NSString *)description {
    VKPieChartDataItem *item = [VKPieChartDataItem dataItemWithValue:value color:color];
    item.textDescription = description;
    return item;
}
    
- (void)setValue:(CGFloat)value{
    NSAssert(value >= 0, @"value should >= 0");
    if (value != _value){
        _value = value;
    }
}
    
    
@end
