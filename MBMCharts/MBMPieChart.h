//
//  MBMPieChart
//  MBMCharts
//
//  Created by Pat Murphy on 12/13/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBMPieChart;
@protocol MBMPieChartDataSource <NSObject>
@required
- (NSUInteger)numberOfSlicesInPieChart:(MBMPieChart *)pieChart;
- (CGFloat)pieChart:(MBMPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index;
@optional
- (UIColor *)pieChart:(MBMPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index;
- (NSString *)pieChart:(MBMPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index;
@end

@protocol MBMPieChartDelegate <NSObject>
@optional
- (void)pieChart:(MBMPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(MBMPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(MBMPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(MBMPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index;
@end

@interface MBMPieChart : UIView
@property(nonatomic, weak) id<MBMPieChartDataSource> chartDataSource;
@property(nonatomic, weak) id<MBMPieChartDelegate> chartDelegate;
@property(nonatomic, assign) CGFloat startPieAngle;
@property(nonatomic, assign) CGFloat animationSpeed;
@property(nonatomic, assign) CGPoint pieCenter;
@property(nonatomic, assign) CGFloat pieRadius;
@property(nonatomic, assign) BOOL    showLabel;
@property(nonatomic, strong) UIFont  *labelFont;
@property(nonatomic, strong) UIColor *labelColor;
@property(nonatomic, strong) UIColor *labelShadowColor;
@property(nonatomic, assign) CGFloat labelRadius;
@property(nonatomic, assign) CGFloat selectedSliceStroke;
@property(nonatomic, assign) CGFloat selectedSliceOffsetRadius;
@property(nonatomic, assign) BOOL    showPercentage;
- (id)initWithFrame:(CGRect)frame Center:(CGPoint)center Radius:(CGFloat)radius;
- (void)reloadData;
- (void)setPieBackgroundColor:(UIColor *)color;
@end;
