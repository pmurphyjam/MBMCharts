//
//  BarChartViewController.h
//  MBMCharts
//
//  Created by Pat Murphy on 12/14/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBMBarChart.h"

@interface BarChartViewController : UIViewController <MBMBarChartDelegate, MBMBarChartDataSource>

@property(nonatomic, strong) IBOutlet MBMBarChart *barChart;
@property(nonatomic, strong) IBOutlet UILabel *selectedBarLabel;
@property(nonatomic, strong) IBOutlet UITextField *numOfBars;
@property(nonatomic, strong) IBOutlet UISegmentedControl *indexOfBars;
@property(nonatomic, strong) IBOutlet UIButton *downArrow;
@property(nonatomic, strong) NSMutableArray *barDicArray;
@property(nonatomic, strong) NSMutableArray *barChartDataArray;
@property(nonatomic, strong) NSMutableArray *barChartConfigArray;

- (void) setUpChart;

@end
