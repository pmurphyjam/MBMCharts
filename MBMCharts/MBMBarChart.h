//
//  MBMbarChart.h
//  MBMCharts
//
//  Created by Pat Murphy on 12/13/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBMBarChart;
@protocol MBMBarChartDataSource <NSObject>
@required
- (NSUInteger)numberOfBarsInChart:(MBMBarChart *)barChart;
- (CGFloat)barChart:(MBMBarChart *)barChart valueForBarAtIndex:(NSUInteger)index;
- (CGRect)barChart:(MBMBarChart *)barChart rectForBarAtIndex:(NSUInteger)index;
@optional
- (UIColor *)barChart:(MBMBarChart *)barChart colorForBarAtIndex:(NSUInteger)index;
- (NSString *)barChart:(MBMBarChart *)barChart textForBarAtIndex:(NSUInteger)index;
@end

@protocol MBMBarChartDelegate <NSObject>
@optional
- (void)barChart:(MBMBarChart *)barChart willSelectBarAtIndex:(NSUInteger)index;
- (void)barChart:(MBMBarChart *)barChart didSelectBarAtIndex:(NSUInteger)index;
- (void)barChart:(MBMBarChart *)barChart willDeselectBarAtIndex:(NSUInteger)index;
- (void)barChart:(MBMBarChart *)barChart didDeselectBarAtIndex:(NSUInteger)index;
@end

@interface MBMBarChart : UIScrollView <UIScrollViewDelegate>
@property(nonatomic, weak) id<MBMBarChartDataSource> chartDataSource;
@property(nonatomic, weak) id<MBMBarChartDelegate> chartDelegate;
@property(nonatomic, assign) CGRect barRect;
@property(nonatomic, assign) CGFloat animationSpeed;
@property(nonatomic, assign) CGPoint barPoint;
@property(nonatomic, assign) CGSize  barSize;
@property(nonatomic, assign) CGFloat numberOfBars;
@property(nonatomic, assign) NSUInteger numberOfElements;
@property(nonatomic, assign) BOOL    showLabel;
@property(nonatomic, strong) UIFont  *labelFont;
@property(nonatomic, strong) UIColor *valueColor;
@property(nonatomic, strong) UIColor *valueShadowColor;
@property(nonatomic, assign) CGFloat selectedBarStroke;
@property(nonatomic, strong) NSMutableArray  *barDicArray;
@property(nonatomic, assign) CGRect chartRect;
@property(nonatomic, assign) CGFloat paddingTop;
@property(nonatomic, assign) CGFloat paddingBotom;
@property(nonatomic, assign) CGFloat leftPadding;
@property(nonatomic, assign) CGFloat stepWidthAxisY;
@property(nonatomic, assign) CGSize labelSizeAxisY;
@property(nonatomic, assign) CGFloat maxValueAxisY;
@property(nonatomic, assign) CGFloat minValueAxisY;
@property(nonatomic, assign) CGFloat stepValueAxisY;
@property(nonatomic, assign) CGFloat barFullWidth;
@property(nonatomic, assign) CGFloat fontSize;
@property(nonatomic, assign) CGFloat barLabelFontSize;
@property(nonatomic, assign) CGFloat barWidth;
@property(nonatomic, assign) CGFloat barInterval;
@property(nonatomic, assign) CGFloat maxValue;
@property(nonatomic, assign) CGFloat scaleAxisY;
@property(nonatomic, strong) UIColor *colorAxisY;
@property(nonatomic, strong) UIColor *colorAxis;
@property(nonatomic, assign) BOOL showAxisY;
@property(nonatomic, assign) BOOL showAxisX;
@property(nonatomic, assign) BOOL plotVerticalLines;
@property(nonatomic, assign) BOOL addHorizontalLabels;

- (void)reloadData;
- (void)setBarBackgroundColor:(UIColor *)color;
- (void)calculateChartFrame;
- (void)drawChart:(NSMutableArray*)barDicArray;

@end
