//
//  PieChartViewController.h
//  MBMCharts
//
//  Created by Pat Murphy on 12/13/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBMPieChart.h"

@interface PieChartViewController : UIViewController <MBMPieChartDelegate, MBMPieChartDataSource>

@property(nonatomic, retain) IBOutlet MBMPieChart *pieChartRight;
@property(nonatomic, retain) IBOutlet MBMPieChart *pieChartLeft;
@property(nonatomic, retain) IBOutlet UILabel *percentageLabel;
@property(nonatomic, retain) IBOutlet UILabel *selectedSliceLabel;
@property(nonatomic, retain) IBOutlet UITextField *numOfSlices;
@property(nonatomic, retain) IBOutlet UISegmentedControl *indexOfSlices;
@property(nonatomic, retain) IBOutlet UIButton *downArrow;
@property(nonatomic, retain) NSMutableArray *pieDicArray;
@property(nonatomic, retain) NSMutableArray *pieChartDataArray;
@property(nonatomic, retain) NSMutableArray *pieChartConfigArray;

- (void) setUpChart;

@end
