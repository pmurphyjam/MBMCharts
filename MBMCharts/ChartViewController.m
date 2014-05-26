//
//  ChartViewController.m
//  MBMCharts
//
//  Created by Pat Murphy on 12/13/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import "ChartViewController.h"
#import "PieChartViewController.h"
#import "BarChartViewController.h"
#import "LineChartViewController.h"

@implementation ChartViewController

@synthesize chartTypeSectionArray = _chartTypeSectionArray;
@synthesize featureListCellArray = _featureListCellArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title=@"Chart Library";
        _chartTypeSectionArray = [[NSArray alloc]initWithObjects:@"Chart Types",nil];
		NSArray *chartTypes = [[NSArray alloc]initWithObjects:@"Pie Charts",@"Bar Charts",@"Line Charts",nil];
        _featureListCellArray = [[NSArray alloc]initWithObjects:chartTypes,nil];

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0)
    {
        UIViewController *chartViewController = nil;
        if(indexPath.row == 0)
        {
            chartViewController = [[PieChartViewController alloc] initWithNibName:@"PieChartViewController" bundle:nil];
        }
        else if(indexPath.row == 1)
        {
            chartViewController = [[BarChartViewController alloc] initWithNibName:@"BarChartViewController" bundle:nil];
        }
        else if(indexPath.row == 2)
        {
            chartViewController = [[LineChartViewController alloc] initWithNibName:@"LineChartViewController" bundle:nil];
        }
        [self.navigationController pushViewController:chartViewController animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return  [self.chartTypeSectionArray count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.chartTypeSectionArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return  [[_featureListCellArray objectAtIndex:section] count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 44)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    [title setMinimumScaleFactor:0.7];
    [title setText:[[_featureListCellArray objectAtIndex:[indexPath section]]objectAtIndex:indexPath.row]];
    [title setTextColor:[UIColor blackColor]];
    [cell.contentView addSubview:title];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
