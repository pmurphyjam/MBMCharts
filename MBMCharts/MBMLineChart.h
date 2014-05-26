//
//  MBMLineChart.h
//  MBMCharts
//
//  Created by Pat Murphy on 12/14/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBMLineChart;
@protocol MBMLineChartDataSource <NSObject>
@required
- (NSUInteger)numberOfSectionsInChart:(MBMLineChart *)lineChart;
- (NSUInteger)numberOfLinesInChart:(MBMLineChart *)lineChart forSection:(NSUInteger)section;
- (CGFloat)lineChart:(MBMLineChart *)lineChart valueForLineAtIndex:(NSUInteger)index forSection:(NSUInteger)section;
- (CGPoint)lineChart:(MBMLineChart *)lineChart pointForLineAtIndex:(NSUInteger)index forSection:(NSUInteger)section;
@optional
- (UIColor *)lineChart:(MBMLineChart *)lineChart colorForLineAtIndex:(NSUInteger)index forSection:(NSUInteger)section;
- (NSString *)lineChart:(MBMLineChart *)lineChart textForLineAtIndex:(NSUInteger)index forSection:(NSUInteger)section;
@end

@protocol MBMLineChartDelegate <NSObject>
@optional
- (void)lineChart:(MBMLineChart *)lineChart willSelectLineAtIndex:(NSUInteger)index forSection:(NSUInteger)section;
- (void)lineChart:(MBMLineChart *)lineChart didSelectLineAtIndex:(NSUInteger)index forSection:(NSUInteger)section
;
- (void)lineChart:(MBMLineChart *)lineChart willDeselectLineAtIndex:(NSUInteger)index forSection:(NSUInteger)section;
- (void)lineChart:(MBMLineChart *)lineChart didDeselectLineAtIndex:(NSUInteger)index forSection:(NSUInteger)section;
@end

@interface MBMLineChart : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, weak) id<MBMLineChartDataSource> chartDataSource;
@property (nonatomic, weak) id<MBMLineChartDelegate> chartDelegate;
@property (nonatomic, assign) CGPoint linePoint;
@property (nonatomic, assign) CGFloat animationSpeed;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat lineRadius;
@property (nonatomic, assign) CGFloat numberOfLines;
@property (nonatomic, assign) NSUInteger numberOfElements;
@property (nonatomic, assign) BOOL    showLabel;
@property (nonatomic, strong) UIFont  *labelFont;
@property (nonatomic, strong) UIColor *labelColor;
@property (nonatomic, strong) UIColor *labelShadowColor;
@property (nonatomic, assign) CGFloat selectedLineStroke;
@property (nonatomic, strong) NSMutableArray *lineDicArray;
@property (nonatomic, assign) CGRect chartRect;
@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, assign) CGFloat paddingBotom;
@property (nonatomic, assign) CGFloat leftPadding;
@property (nonatomic, assign) CGFloat stepWidthAxisY;
@property (nonatomic, assign) CGSize labelSizeAxisY;
@property (nonatomic, assign) CGFloat maxValueAxisY;
@property (nonatomic, assign) CGFloat minValueAxisY;
@property (nonatomic, assign) CGFloat stepValueAxisY;
@property (nonatomic, assign) CGFloat barFullWidth;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat barLabelFontSize;
@property (nonatomic, assign) CGFloat barWidth;
@property (nonatomic, assign) CGFloat barInterval;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat scaleAxisY;
@property (nonatomic, strong) UIColor *colorAxisY;
@property (nonatomic, strong) UIColor *colorAxis;
@property (nonatomic, assign) BOOL showAxisY;
@property (nonatomic, assign) BOOL showAxisX;
@property (nonatomic, assign) BOOL plotVerticalLines;
@property (nonatomic, assign) BOOL addHorizontalLabels;

- (void)reloadData;
- (void)setLineBackgroundColor:(UIColor *)color;
- (void)calculateChartFrame;
- (void)drawChart:(NSMutableArray*)lineDicArray;

@end

