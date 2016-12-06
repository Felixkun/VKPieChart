//
//  VKPieChart.m
//  arcDemo
//
//  Created by Felix on 2016/12/6.
//  Copyright © 2016年 Felix. All rights reserved.
//

#import "VKPieChart.h"
#import "VKPieChartDataItem.h"

//弧度转角度
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
//角度转弧度
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface VKPieChart()

@property (nonatomic) NSArray *items;
@property (nonatomic) NSArray *endPercentages;

@property (nonatomic) UIView         *contentView;
@property (nonatomic) CAShapeLayer   *pieLayer;
@property (nonatomic) NSMutableArray *descriptionLabels;
@property (strong, nonatomic) CAShapeLayer *sectorHighlight;

@property (nonatomic, strong) NSMutableDictionary *selectedItems;
    
@property (nonatomic , strong) UILabel *centerLabel;
    
- (void)loadDefault;
    
- (UILabel *)descriptionLabelForItemAtIndex:(NSUInteger)index;
- (VKPieChartDataItem *)dataItemForIndex:(NSUInteger)index;
- (CGFloat)startPercentageForItemAtIndex:(NSUInteger)index;
- (CGFloat)endPercentageForItemAtIndex:(NSUInteger)index;
- (CGFloat)ratioForItemAtIndex:(NSUInteger)index;
    
- (CAShapeLayer *)newCircleLayerWithRadius:(CGFloat)radius
                               borderWidth:(CGFloat)borderWidth
                                 fillColor:(UIColor *)fillColor
                               borderColor:(UIColor *)borderColor
                           startPercentage:(CGFloat)startPercentage
                             endPercentage:(CGFloat)endPercentage;
    
    
@end


@implementation VKPieChart
    
-(id)initWithFrame:(CGRect)frame items:(NSArray *)items{
    self = [self initWithFrame:frame];
    if(self){
        _items = [NSArray arrayWithArray:items];
        [self baseInit];
    }
    
    return self;
}
    
- (void)awakeFromNib{
    [self baseInit];
}
    
- (void)baseInit{
    _selectedItems = [NSMutableDictionary dictionary];
    //在绘制圆形时,应当考虑矩形的宽和高的大小问题,当宽大于高时,绘制饼图时,会超出整个view的范围,因此建议在此处进行判断
    
    CGFloat minimal = (CGRectGetWidth(self.bounds) < CGRectGetHeight(self.bounds)) ? CGRectGetWidth(self.bounds) : CGRectGetHeight(self.bounds);
    
    _outerCircleRadius  = minimal / 2;
    _innerCircleRadius  = minimal / 6;
    _descriptionTextColor = [UIColor whiteColor];
    _descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:18.0];
    _descriptionTextShadowColor  = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    _descriptionTextShadowOffset =  CGSizeMake(0, 1);
    _duration = 1.0;
    _shouldHighlightSectorOnTouch = YES;
    _enableMultipleSelection = NO;
    _hideValues = NO;
    
    [self setupDefaultValues];
    [self loadDefault];
}
    
- (void)loadDefault{
    __block CGFloat currentTotal = 0;
    CGFloat total = [[self.items valueForKeyPath:@"@sum.value"] floatValue];
    NSMutableArray *endPercentages = [NSMutableArray new];
    [_items enumerateObjectsUsingBlock:^(VKPieChartDataItem *item, NSUInteger idx, BOOL *stop) {
        if (total == 0){
            [endPercentages addObject:@(1.0 / _items.count * (idx + 1))];
        }else{
            currentTotal += item.value;
            [endPercentages addObject:@(currentTotal / total)];
        }
    }];
    self.endPercentages = [endPercentages copy];
    
    [_contentView removeFromSuperview];
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_contentView];
    _descriptionLabels = [NSMutableArray new];
    
    _pieLayer = [CAShapeLayer layer];
    [_contentView.layer addSublayer:_pieLayer];
    
}
    
    /** Override this to change how inner attributes are computed. **/
- (void)recompute {
    
    //同理
    CGFloat minimal = (CGRectGetWidth(self.bounds) < CGRectGetHeight(self.bounds)) ? CGRectGetWidth(self.bounds) : CGRectGetHeight(self.bounds);
    self.outerCircleRadius = minimal / 2;
    self.innerCircleRadius = minimal / 6;
}
    
#pragma mark -

- (void)loadCenterLabel{
    if (_centerLabel == nil) {
        _centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.innerCircleRadius * 2, self.innerCircleRadius * 2)];
        
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_centerLabel];
        _centerLabel.text = @"标题\n内容\n单位";
        _centerLabel.font = [UIFont systemFontOfSize:16];
        _centerLabel.numberOfLines = 0;
        _centerLabel.textColor = [UIColor blackColor];
        _centerLabel.center =   CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds));;
        _centerLabel.layer.cornerRadius = self.innerCircleRadius;
        _centerLabel.layer.masksToBounds = YES;
    }
   
}

- (void)setAttriString:(NSAttributedString *)attriStr{
    _centerLabel.attributedText = attriStr;
    [self setNeedsLayout];
}
    
- (void)strokeChart{
    
    [self loadCenterLabel];
    VKPieChartDataItem *currentItem;
    for (int i = 0; i < _items.count; i++) {
        currentItem = [self dataItemForIndex:i];
        
        
        CGFloat startPercentage = [self startPercentageForItemAtIndex:i];
        CGFloat endPercentage   = [self endPercentageForItemAtIndex:i];
        
        CGFloat radius = _innerCircleRadius + (_outerCircleRadius - _innerCircleRadius) / 2;
        CGFloat borderWidth = _outerCircleRadius - _innerCircleRadius;
        
        CAShapeLayer *currentPieLayer =	[self newCircleLayerWithRadius:radius
                                                           borderWidth:borderWidth
                                                             fillColor:[UIColor clearColor]
                                                           borderColor:currentItem.color
                                                       startPercentage:startPercentage
                                                         endPercentage:endPercentage];
        [_pieLayer addSublayer:currentPieLayer];
    }
    
    [self maskChart];
    
    for (int i = 0; i < _items.count; i++) {
        UILabel *descriptionLabel =  [self descriptionLabelForItemAtIndex:i];
        [_contentView addSubview:descriptionLabel];
        [_descriptionLabels addObject:descriptionLabel];
    }
    
    [self addAnimationIfNeeded];
}
    
- (UILabel *)descriptionLabelForItemAtIndex:(NSUInteger)index{
    VKPieChartDataItem *currentDataItem = [self dataItemForIndex:index];
    CGFloat distance = _innerCircleRadius + (_outerCircleRadius - _innerCircleRadius) / 2;
    CGFloat centerPercentage = ([self startPercentageForItemAtIndex:index] + [self endPercentageForItemAtIndex:index])/ 2;
    CGFloat rad = centerPercentage * 2 * M_PI;
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
    NSString *titleText = currentDataItem.textDescription;
    
    NSString *titleValue;
    
    if (self.showAbsoluteValues) {
        titleValue = [NSString stringWithFormat:@"%.0f",currentDataItem.value];
    }else{
        titleValue = [NSString stringWithFormat:@"%.0f%%",[self ratioForItemAtIndex:index] * 100];
    }
    
    if (self.hideValues)
    descriptionLabel.text = titleText;
    else if(!titleText || self.showOnlyValues)
    descriptionLabel.text = titleValue;
    else {
        NSString* str = [titleValue stringByAppendingString:[NSString stringWithFormat:@"\n%@",titleText]];
        descriptionLabel.text = str ;
    }
    
    //If value is less than cutoff, show no label
    if ([self ratioForItemAtIndex:index] < self.labelPercentageCutoff )
    {
        descriptionLabel.text = nil;
    }
    
    CGPoint center = CGPointMake(_outerCircleRadius + distance * sin(rad),
                                 _outerCircleRadius - distance * cos(rad));
    
    descriptionLabel.font = _descriptionTextFont;
    CGSize labelSize = [descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:descriptionLabel.font}];
    descriptionLabel.frame = CGRectMake(descriptionLabel.frame.origin.x, descriptionLabel.frame.origin.y,
                                        descriptionLabel.frame.size.width, labelSize.height);
    descriptionLabel.numberOfLines   = 0;
    descriptionLabel.textColor       = _descriptionTextColor;
    descriptionLabel.shadowColor     = _descriptionTextShadowColor;
    descriptionLabel.shadowOffset    = _descriptionTextShadowOffset;
    descriptionLabel.textAlignment   = NSTextAlignmentCenter;
    descriptionLabel.center          = center;
    descriptionLabel.alpha           = 0;
    descriptionLabel.backgroundColor = [UIColor clearColor];
    return descriptionLabel;
}
    
- (void)updateChartData:(NSArray *)items {
    self.items = items;
}
    
- (VKPieChartDataItem *)dataItemForIndex:(NSUInteger)index{
    return self.items[index];
}
    
- (CGFloat)startPercentageForItemAtIndex:(NSUInteger)index{
    if(index == 0){
        return 0;
    }
    
    return [_endPercentages[index - 1] floatValue];
}
    
- (CGFloat)endPercentageForItemAtIndex:(NSUInteger)index{
    return [_endPercentages[index] floatValue];
}
    
- (CGFloat)ratioForItemAtIndex:(NSUInteger)index{
    return [self endPercentageForItemAtIndex:index] - [self startPercentageForItemAtIndex:index];
}
    
#pragma mark private methods
    
- (CAShapeLayer *)newCircleLayerWithRadius:(CGFloat)radius
                               borderWidth:(CGFloat)borderWidth
                                 fillColor:(UIColor *)fillColor
                               borderColor:(UIColor *)borderColor
                           startPercentage:(CGFloat)startPercentage
                             endPercentage:(CGFloat)endPercentage{
    
    
    
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds));
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:-M_PI_2
                                                      endAngle:M_PI_2 * 3
                                                     clockwise:YES];
    
        CAShapeLayer *lay1 = [[CAShapeLayer alloc] init];
        lay1.fillColor = fillColor.CGColor;;
        lay1.strokeColor = borderColor.CGColor;;
        lay1.lineWidth = borderWidth;
        lay1.strokeStart = startPercentage;
        lay1.strokeEnd = endPercentage;
        lay1.path = path.CGPath;
    
        [shapeLayer addSublayer:lay1];
    
        CAShapeLayer *lay2 = [[CAShapeLayer alloc] init];
        UIBezierPath *subPath1 = [[UIBezierPath alloc] init];
   
    
        CGPoint startPoint1 = CGPointMake(cos(DEGREES_TO_RADIANS(startPercentage * 360) - M_PI_2) * self.innerCircleRadius + center.x, sin(DEGREES_TO_RADIANS(startPercentage * 360) - M_PI_2)*self.innerCircleRadius + center.y);
        CGPoint endPoint1 = CGPointMake(cos(DEGREES_TO_RADIANS(startPercentage * 360)- M_PI_2)* (self.innerCircleRadius + radius) + center.x, sin(DEGREES_TO_RADIANS(startPercentage * 360)- M_PI_2)*(self.innerCircleRadius + radius) + center.y);
        [subPath1 moveToPoint:startPoint1];
        [subPath1 addLineToPoint:endPoint1];
    
        lay2.fillColor = [UIColor blueColor].CGColor;
        lay2.strokeColor = [UIColor whiteColor].CGColor;
        lay2.lineWidth = 2;
        lay2.path = subPath1.CGPath;
        [shapeLayer addSublayer:lay2];
    
    
    CAShapeLayer *lay3 = [[CAShapeLayer alloc] init];
    UIBezierPath *subPath2 = [[UIBezierPath alloc] init];
    CGPoint startPoint2 = CGPointMake(cos(DEGREES_TO_RADIANS(endPercentage * 360) - M_PI_2) * self.innerCircleRadius + center.x, sin(DEGREES_TO_RADIANS(endPercentage * 360) - M_PI_2)*self.innerCircleRadius + center.y);
    CGPoint endPoint2 = CGPointMake(cos(DEGREES_TO_RADIANS(endPercentage * 360) - M_PI_2)* (self.innerCircleRadius + radius) + center.x, sin(DEGREES_TO_RADIANS(endPercentage * 360) - M_PI_2)*(self.innerCircleRadius + radius) + center.y);
    [subPath2 moveToPoint:startPoint2];
    [subPath2 addLineToPoint:endPoint2];
    
    lay3.fillColor = [UIColor blueColor].CGColor;
    lay3.strokeColor = [UIColor whiteColor].CGColor;
    lay3.lineWidth = 2;
    lay3.path = subPath2.CGPath;
    [shapeLayer addSublayer:lay3];

    
    
    
    
    return shapeLayer;
    
    
    
    
    
    
    

}
    
- (void)maskChart{
    CGFloat radius = _innerCircleRadius + (_outerCircleRadius - _innerCircleRadius) / 2;
    CGFloat borderWidth = _outerCircleRadius - _innerCircleRadius;
    CAShapeLayer *maskLayer = [self newCircleLayerWithRadius:radius
                                                 borderWidth:borderWidth
                                                   fillColor:[UIColor clearColor]
                                                 borderColor:[UIColor blackColor]
                                             startPercentage:0
                                               endPercentage:1];
    
    _pieLayer.mask = maskLayer;
}
    
- (void)addAnimationIfNeeded{
    if (self.displayAnimated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration  = _duration;
        animation.fromValue = @0;
        animation.toValue   = @1;
        animation.delegate  = self;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.removedOnCompletion = YES;
        [_pieLayer.mask addAnimation:animation forKey:@"circleAnimation"];
    }
    else {
        // Add description labels since no animation is required
        [_descriptionLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setAlpha:1];
        }];
    }
}
    
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [_descriptionLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [UIView animateWithDuration:0.2 animations:^(){
            [obj setAlpha:1];
        }];
    }];
}
    
- (void)didTouchAt:(CGPoint)touchLocation
    {
        CGPoint circleCenter = CGPointMake(_contentView.bounds.size.width/2, _contentView.bounds.size.height/2);
        
        CGFloat distanceFromCenter = sqrtf(powf((touchLocation.y - circleCenter.y),2) + powf((touchLocation.x - circleCenter.x),2));
        
        if (distanceFromCenter < _innerCircleRadius) {
            if ([self.delegate respondsToSelector:@selector(didUnselectPieItem)]) {
                [self.delegate didUnselectPieItem];
            }
            [self.sectorHighlight removeFromSuperlayer];
            return;
        }
        
        CGFloat percentage = [self findPercentageOfAngleInCircle:circleCenter fromPoint:touchLocation];
        int index = 0;
        while (percentage > [self endPercentageForItemAtIndex:index]) {
            index ++;
        }
        
        if ([self.delegate respondsToSelector:@selector(userClickedOnPieIndexItem:)]) {
            [self.delegate userClickedOnPieIndexItem:index];
        }
        
        if (self.shouldHighlightSectorOnTouch)
        {
            if (!self.enableMultipleSelection)
            {
                if (self.sectorHighlight)
                [self.sectorHighlight removeFromSuperlayer];
            }
            
            VKPieChartDataItem *currentItem = [self dataItemForIndex:index];
            
            CGFloat red,green,blue,alpha;
            UIColor *old = currentItem.color;
            [old getRed:&red green:&green blue:&blue alpha:&alpha];
            alpha /= 2;
            UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            
            CGFloat startPercentage = [self startPercentageForItemAtIndex:index];
            CGFloat endPercentage   = [self endPercentageForItemAtIndex:index];
            
            self.sectorHighlight = [self newCircleLayerWithRadius:_outerCircleRadius + 5
                                                      borderWidth:10
                                                        fillColor:[UIColor clearColor]
                                                      borderColor:newColor
                                                  startPercentage:startPercentage
                                                    endPercentage:endPercentage];
            
            if (self.enableMultipleSelection)
            {
                NSString *dictIndex = [NSString stringWithFormat:@"%d", index];
                CAShapeLayer *indexShape = [self.selectedItems valueForKey:dictIndex];
                if (indexShape)
                {
                    [indexShape removeFromSuperlayer];
                    [self.selectedItems removeObjectForKey:dictIndex];
                }
                else
                {
                    [self.selectedItems setObject:self.sectorHighlight forKey:dictIndex];
                    [_contentView.layer addSublayer:self.sectorHighlight];
                }
            }
            else
            {
                [_contentView.layer addSublayer:self.sectorHighlight];
            }
        }
    }
    
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
    {
        for (UITouch *touch in touches) {
            CGPoint touchLocation = [touch locationInView:_contentView];
            [self didTouchAt:touchLocation];
        }
    }
    
- (CGFloat) findPercentageOfAngleInCircle:(CGPoint)center fromPoint:(CGPoint)reference{
    //Find angle of line Passing In Reference And Center
    CGFloat angleOfLine = atanf((reference.y - center.y) / (reference.x - center.x));
    CGFloat percentage = (angleOfLine + M_PI /2)/(2 * M_PI) ;
    return (reference.x - center.x) > 0 ? percentage : percentage + .5;
}
    
- (UIView*) getLegendWithMaxWidth:(CGFloat)mWidth{
    if ([self.items count] < 1) {
        return nil;
    }
    
    /* This is a small circle that refers to the chart data */
    CGFloat legendCircle = 16;
    
    CGFloat hSpacing = 0;
    
    CGFloat beforeLabel = legendCircle + hSpacing;
    
    /* x and y are the coordinates of the starting point of each legend item */
    CGFloat x = 0;
    CGFloat y = 0;
    
    /* accumulated width and height */
    CGFloat totalWidth = 0;
    CGFloat totalHeight = 0;
    
    NSMutableArray *legendViews = [[NSMutableArray alloc] init];
    
    /* Determine the max width of each legend item */
    CGFloat maxLabelWidth;
    if (self.legendStyle == PNLegendItemStyleStacked) {
        maxLabelWidth = mWidth - beforeLabel;
    }else{
        maxLabelWidth = MAXFLOAT;
    }
    
    /* this is used when labels wrap text and the line
     * should be in the middle of the first row */
    CGFloat singleRowHeight = [self sizeOfString:@"Test"
                                              withWidth:MAXFLOAT
                                                   font:self.legendFont ? self.legendFont : [UIFont systemFontOfSize:12.0f]].height;
    
    NSUInteger counter = 0;
    NSUInteger rowWidth = 0;
    NSUInteger rowMaxHeight = 0;
    
    for (VKPieChartDataItem *pdata in self.items) {
        /* Expected label size*/
        CGSize labelsize = [self sizeOfString:pdata.textDescription
                                           withWidth:maxLabelWidth
                                                font:self.legendFont ? self.legendFont : [UIFont systemFontOfSize:12.0f]];
        
        if ((rowWidth + labelsize.width + beforeLabel > mWidth)&&(self.legendStyle == PNLegendItemStyleSerial)) {
            rowWidth = 0;
            x = 0;
            y += rowMaxHeight;
            rowMaxHeight = 0;
        }
        rowWidth += labelsize.width + beforeLabel;
        totalWidth = self.legendStyle == PNLegendItemStyleSerial ? fmaxf(rowWidth, totalWidth) : fmaxf(totalWidth, labelsize.width + beforeLabel);
        // Add inflexion type
        [legendViews addObject:[self drawInflexion:legendCircle * .6
                                            center:CGPointMake(x + legendCircle / 2, y + singleRowHeight / 2)
                                          andColor:pdata.color]];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x + beforeLabel, y, labelsize.width, labelsize.height)];
        label.text = pdata.textDescription;
        label.textColor = self.legendFontColor ? self.legendFontColor : [UIColor blackColor];
        label.font = self.legendFont ? self.legendFont : [UIFont systemFontOfSize:12.0f];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        
        
        rowMaxHeight = fmaxf(rowMaxHeight, labelsize.height);
        x += self.legendStyle == PNLegendItemStyleStacked ? 0 : labelsize.width + beforeLabel;
        y += self.legendStyle == PNLegendItemStyleStacked ? labelsize.height : 0;
        
        
        totalHeight = self.legendStyle == PNLegendItemStyleSerial ? fmaxf(totalHeight, rowMaxHeight + y) : totalHeight + labelsize.height;
        [legendViews addObject:label];
        counter ++;
    }
    
    UIView *legend = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalWidth, totalHeight)];
    
    for (UIView* v in legendViews) {
        [legend addSubview:v];
    }
    return legend;
}
    
    
- (CGSize)sizeOfString:(NSString *)text withWidth:(float)width font:(UIFont *)font {
    CGSize size = CGSizeMake(width, MAXFLOAT);
    
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        size = [text boundingRectWithSize:size
                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                               attributes:tdic
                                  context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
#pragma clang diagnostic pop
    }
    
    return size;
}
    
- (UIImageView*)drawInflexion:(CGFloat)size center:(CGPoint)center andColor:(UIColor*)color
    {
        //Make the size a little bigger so it includes also border stroke
        CGSize aSize = CGSizeMake(size, size);
        
        
        UIGraphicsBeginImageContextWithOptions(aSize, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextAddArc(context, size/2, size/ 2, size/2, 0, M_PI*2, YES);
        
        
        //Set some fill color
        CGContextSetFillColorWithColor(context, color.CGColor);
        
        //Finally draw
        CGContextDrawPath(context, kCGPathFill);
        
        //now get the image from the context
        UIImage *squareImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        //// Translate origin
        CGFloat originX = center.x - (size) / 2.0;
        CGFloat originY = center.y - (size) / 2.0;
        
        UIImageView *squareImageView = [[UIImageView alloc]initWithImage:squareImage];
        [squareImageView setFrame:CGRectMake(originX, originY, size, size)];
        return squareImageView;
    }
    
    /* Redraw the chart on autolayout */
-(void)layoutSubviews {
    [super layoutSubviews];
    [self strokeChart];
}

    
    
- (void) setupDefaultValues{
    self.hasLegend = YES;
    self.legendPosition = PNLegendPositionBottom;
    self.legendStyle = PNLegendItemStyleStacked;
    self.labelRowsInSerialMode = 1;
    self.displayAnimated = YES;
}
    
    
    

    
- (void) setLabelRowsInSerialMode:(NSUInteger)num{
    if (self.legendStyle == PNLegendItemStyleSerial) {
        _labelRowsInSerialMode = num;
    }else{
        _labelRowsInSerialMode = 1;
    }
}
@end
