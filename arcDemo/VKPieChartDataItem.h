//
//  VKPieChartDataItem.h
//  arcDemo
//
//  Created by Felix on 2016/12/6.
//  Copyright © 2016年 Felix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VKPieChartDataItem : NSObject
+ (instancetype)dataItemWithValue:(CGFloat)value
                            color:(UIColor*)color;
    
+ (instancetype)dataItemWithValue:(CGFloat)value
                            color:(UIColor*)color
                      description:(NSString *)description;
    
    @property (nonatomic) CGFloat   value;
    @property (nonatomic) UIColor  *color;
    @property (nonatomic) NSString *textDescription;
@end
