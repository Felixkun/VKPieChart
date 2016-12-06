//
//  ViewController.m
//  arcDemo
//
//  Created by Felix on 2016/12/6.
//  Copyright © 2016年 Felix. All rights reserved.
//

#import "ViewController.h"
#import "VKChart.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *items = @[[VKPieChartDataItem dataItemWithValue:1 color:[UIColor redColor]],
                       [VKPieChartDataItem dataItemWithValue:40 color:[UIColor blueColor] description:@"WWDC"],
                       [VKPieChartDataItem dataItemWithValue:25 color:[UIColor greenColor] description:@"GOOL I/O"],
                       [VKPieChartDataItem dataItemWithValue:25 color:[UIColor orangeColor] description:@"GOOL I/O"],
                       ];
    
    
    
    VKPieChart *pieChart = [[VKPieChart alloc] initWithFrame:CGRectMake(40.0, 155.0, 240.0, 240.0) items:items];
    pieChart.descriptionTextColor = [UIColor whiteColor];
    pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
    
    pieChart.innerCircleRadius = 60;
    pieChart.outerCircleRadius = 120;
   
    [pieChart strokeChart];
    
    [self.view addSubview:pieChart];

    NSRange range;
    NSString *string = @"资产总额\n20,000.88\n(元)";
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:string];
    range = [string rangeOfString:@"20,000.88"];
    [att addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    [att addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:range];
    
    range = [string rangeOfString:@"(元)"];
    
    [att addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
    [att addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:range];
    
    [pieChart setAttriString:att];
    
}





@end
