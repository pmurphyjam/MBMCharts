//
//  LineChartViewController.h
//  MBMCharts
//
//  Created by Pat Murphy on 12/14/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBMLineChart.h"

@interface LineChartViewController : UIViewController <MBMLineChartDelegate, MBMLineChartDataSource>
@property (retain, nonatomic) IBOutlet MBMLineChart *lineChart;
@property (retain, nonatomic) IBOutlet UILabel *selectedLineLabel;
@property (retain, nonatomic) IBOutlet UITextField *numOfLines;
@property (retain, nonatomic) IBOutlet UISegmentedControl *indexOfLines;
@property (retain, nonatomic) IBOutlet UIButton *downArrow;
@property(nonatomic, retain) NSMutableArray *lineDicArray;
@property(nonatomic, retain) NSMutableArray *lineChartDataArray;
@property(nonatomic, retain) NSMutableArray *lineChartConfigArray;

- (void) setUpChart;

@end
