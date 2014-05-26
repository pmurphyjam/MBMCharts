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
@property (strong, nonatomic) IBOutlet MBMLineChart *lineChart;
@property (strong, nonatomic) IBOutlet UILabel *selectedLineLabel;
@property (strong, nonatomic) IBOutlet UILabel *lineStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *segmentsLabel;
@property (strong, nonatomic) IBOutlet UILabel *linesLabel;
@property (strong, nonatomic) IBOutlet UITextField *numOfLines;
@property (strong, nonatomic) IBOutlet UISegmentedControl *indexOfLines;
@property (strong, nonatomic) IBOutlet UIButton *downArrow;
@property (strong, nonatomic) IBOutlet UISwitch *lineSegmentSwitch;
@property(nonatomic, strong) NSMutableArray *lineDicArray;
@property(nonatomic, strong) NSMutableArray *lineChartDataArray;
@property(nonatomic, strong) NSMutableArray *lineChartConfigArray;
@property(nonatomic, assign) NSUInteger numberOfSections;

- (void) setUpChart;
- (IBAction)lineNumChanged:(id)sender;
- (IBAction)clearLines:(id)sender;
- (IBAction)addLineBtnClicked:(id)sender;
- (IBAction)updateLines:(id)sender;
- (IBAction)lineSegmentSwitchAction:(id)sender;

@end
