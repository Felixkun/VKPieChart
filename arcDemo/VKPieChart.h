//
//  VKPieChart.h
//  arcDemo
//
//  Created by Felix on 2016/12/6.
//  Copyright © 2016年 Felix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKPieChartDelegate.h"

typedef NS_ENUM(NSUInteger, PNLegendPosition) {
    PNLegendPositionTop = 0,
    PNLegendPositionBottom = 1,
    PNLegendPositionLeft = 2,
    PNLegendPositionRight = 3
};

typedef NS_ENUM(NSUInteger, PNLegendItemStyle) {
    PNLegendItemStyleStacked = 0,
    PNLegendItemStyleSerial = 1
};

@end

@interface VKPieChart : UIView
    
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;
    
@property (nonatomic, readonly) NSArray	*items;

/** Default is 18-point Avenir Medium. */
@property (nonatomic) UIFont  *descriptionTextFont;

/** Default is white. */
@property (nonatomic) UIColor *descriptionTextColor;

/** Default is black, with an alpha of 0.4. */
@property (nonatomic) UIColor *descriptionTextShadowColor;

/** Default is CGSizeMake(0, 1). */
@property (nonatomic) CGSize   descriptionTextShadowOffset;

/** Default is 1.0. */
@property (nonatomic) NSTimeInterval duration;

/** Show only values, this is useful when legend is present */
@property (nonatomic) BOOL showOnlyValues;

/** Show absolute values not relative i.e. percentages */
@property (nonatomic) BOOL showAbsoluteValues;

/** Hide percentage labels less than cutoff value */
@property (nonatomic, assign) CGFloat labelPercentageCutoff;

/** Default YES. */
@property (nonatomic) BOOL shouldHighlightSectorOnTouch;

/** Current outer radius. Override recompute() to change this. **/
@property (nonatomic) CGFloat outerCircleRadius;

/** Current inner radius. Override recompute() to change this. **/
@property (nonatomic) CGFloat innerCircleRadius;

@property (nonatomic, weak) id<VKPieChartDelegate> delegate;
    
/** Update chart items. Does not update chart itself. */
- (void)updateChartData:(NSArray *)data;
    
/** Multiple selection */
@property (nonatomic, assign) BOOL enableMultipleSelection;

/** show only tiles, not values or percentage */
@property (nonatomic) BOOL hideValues;
    
- (void)strokeChart;
    
- (void)recompute;
    
    
    
#pragma mark - BASE
@property (assign, nonatomic) BOOL hasLegend;
@property (assign, nonatomic) PNLegendPosition legendPosition;
@property (assign, nonatomic) PNLegendItemStyle legendStyle;

@property (assign, nonatomic) UIFont *legendFont;
@property (assign, nonatomic) UIColor *legendFontColor;
@property (assign, nonatomic) NSUInteger labelRowsInSerialMode;

/** Display the chart with or without animation. Default is YES. **/
@property (nonatomic) BOOL displayAnimated;

/**
 *  returns the Legend View, or nil if no chart data is present.
 *  The origin of the legend frame is 0,0 but you can set it with setFrame:(CGRect)
 *
 *  @param mWidth Maximum width of legend. Height will depend on this and font size
 *
 *  @return UIView of Legend
 */
- (UIView*) getLegendWithMaxWidth:(CGFloat)mWidth;


- (void) setupDefaultValues;

    
- (void)setAttriString:(NSAttributedString *)attriStr;
    
@end
