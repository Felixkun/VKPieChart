//
//  VKPieChartDelegate.h
//  arcDemo
//
//  Created by Felix on 2016/12/6.
//  Copyright © 2016年 Felix. All rights reserved.
//

@protocol VKPieChartDelegate <NSObject>
    @optional
    /**
     * Callback method that gets invoked when the user taps on the chart line.
     */
- (void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex;
    
    /**
     * Callback method that gets invoked when the user taps on a chart line key point.
     */
- (void)userClickedOnLineKeyPoint:(CGPoint)point
                        lineIndex:(NSInteger)lineIndex
                       pointIndex:(NSInteger)pointIndex;
    
    /**
     * Callback method that gets invoked when the user taps on a chart bar.
     */
- (void)userClickedOnBarAtIndex:(NSInteger)barIndex;
    
    
- (void)userClickedOnPieIndexItem:(NSInteger)pieIndex;
- (void)didUnselectPieItem;
