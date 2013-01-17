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

@property(nonatomic, retain) IBOutlet MBMBarChart *barChart;
@property(nonatomic, retain) IBOutlet UILabel *selectedBarLabel;
@property(nonatomic, retain) IBOutlet UITextField *numOfBars;
@property(nonatomic, retain) IBOutlet UISegmentedControl *indexOfBars;
@property(nonatomic, retain) IBOutlet UIButton *downArrow;
@property(nonatomic, retain) NSMutableArray *barDicArray;
@property(nonatomic, retain) NSMutableArray *barChartDataArray;
@property(nonatomic, retain) NSMutableArray *barChartConfigArray;

- (void) setUpChart;

@end
