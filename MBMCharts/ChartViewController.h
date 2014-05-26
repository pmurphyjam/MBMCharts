//
//  ChartViewController.m
//  MBMCharts
//
//  Created by Pat Murphy on 12/13/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *myTableView;
    NSArray *chartTypeSectionArray;
    NSArray *featureListCellArray;
}

@property(nonatomic, strong) NSArray  *chartTypeSectionArray;
@property(nonatomic, strong) NSArray  *featureListCellArray;

@end
