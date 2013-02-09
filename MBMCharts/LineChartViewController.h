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
@property (retain, nonatomic) IBOutlet UILabel *lineStatusLabel;
@property (retain, nonatomic) IBOutlet UILabel *segmentsLabel;
@property (retain, nonatomic) IBOutlet UILabel *linesLabel;
@property (retain, nonatomic) IBOutlet UITextField *numOfLines;
@property (retain, nonatomic) IBOutlet UISegmentedControl *indexOfLines;
@property (retain, nonatomic) IBOutlet UIButton *downArrow;
@property (retain, nonatomic) IBOutlet UISwitch *lineSegmentSwitch;
@property(nonatomic, retain) NSMutableArray *lineDicArray;
@property(nonatomic, retain) NSMutableArray *lineChartDataArray;
@property(nonatomic, retain) NSMutableArray *lineChartConfigArray;
@property(nonatomic, assign) NSUInteger numberOfSections;

- (void) setUpChart;
- (IBAction)lineNumChanged:(id)sender;
- (IBAction)clearLines:(id)sender;
- (IBAction)addLineBtnClicked:(id)sender;
- (IBAction)updateLines:(id)sender;
- (IBAction)lineSegmentSwitchAction:(id)sender;

@end
