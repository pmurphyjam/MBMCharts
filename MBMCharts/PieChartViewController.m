//
//  PieChartViewController.m
//  MBMCharts
//
//  Created by Pat Murphy on 12/13/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import "PieChartViewController.h"
#import "MBMChartDefines.h"
#import "UIColorCategory.h"
#import <QuartzCore/QuartzCore.h>

@implementation PieChartViewController

@synthesize pieChartRight = _pieChart;
@synthesize pieChartLeft = _pieChartCopy;
@synthesize percentageLabel = _percentageLabel;
@synthesize selectedSliceLabel = _selectedSliceLabel;
@synthesize numOfSlices = _numOfSlices;
@synthesize indexOfSlices = _indexOfSlices;
@synthesize downArrow = _downArrow;
@synthesize pieDicArray = _pieDicArray;
@synthesize pieChartDataArray = _pieChartDataArray;
@synthesize pieChartConfigArray = _pieChartConfigArray;

#pragma mark - View lifecycle

- (void)loadView
{
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
		[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		[[NSBundle mainBundle] loadNibNamed:@"PieChartViewController-iPad" owner:self options:nil];
	}
	else
	{
		[[NSBundle mainBundle] loadNibNamed:@"PieChartViewController" owner:self options:nil];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Pie Charts";
	//rotate up arrow
    self.downArrow.transform = CGAffineTransformMakeRotation(M_PI);

	_pieDicArray = [[NSMutableArray alloc] init];
	_pieChartDataArray = [[NSMutableArray alloc] init];
	_pieChartConfigArray = [[NSMutableArray alloc] init];

    [_selectedSliceLabel setText:@""];

	[self setUpChart];
}

-(NSString*)getRandomColor
{
    NSInteger baseInt = arc4random() % 16777216;
    NSString *hexColor = [NSString stringWithFormat:@"%06X", baseInt];
	return hexColor;
}

-(NSNumber*)getRandomNum:(BOOL)type seed:(int)seed
{
	int seedType = 20;
	if(type)
		seedType = 40;
	
	NSNumber *randomNum = [NSNumber numberWithInt:arc4random()%seed+seedType];
	return randomNum;
}

-(NSMutableArray*)createPieChart:(NSDictionary *)dataDic
{
	int seedInt = [[dataDic objectForKey:@"SEED"] intValue];;
    int slices = [[dataDic objectForKey:@"SLICES"] intValue];
    NDLog(@"PieChartVCtrl : createPieChart : dataDic = %@", dataDic);
    
    NSMutableArray *sliceChartDataArray = [[[NSMutableArray alloc] init] autorelease];
    for (int row = 0; row < slices; row++)
    {
        NSString *color = [self getRandomColor];
        NSNumber *value = [self getRandomNum:NO seed:seedInt];
        NSDictionary *chartData = [NSDictionary dictionaryWithObjectsAndKeys:value,@"Value",color,@"Color",nil];
        [sliceChartDataArray addObject:chartData];
    }
    
    NDLog(@"PieChartVCtrl : createPieChart : sliceChartDataArray = %@", sliceChartDataArray);
	return sliceChartDataArray;
}

- (void) setUpChart
{
	NSDictionary *chartConfigData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"ShowPercentage",@"ff0000",@"LabelColor",@"0000ff",@"ValueShadowColor",nil];
	[_pieChartConfigArray addObject:chartConfigData];
	
    NSDictionary *dataDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:100],@"SEED",[NSNumber numberWithInt:12],@"SLICES",nil];
    [_pieChartDataArray setArray:[self createPieChart:dataDic]];

    for (NSDictionary *pieInfo in self.pieChartDataArray)
	{
		NSNumber *pieValue = [NSNumber numberWithFloat:[[pieInfo objectForKey:@"Value"] floatValue]];
		UIColor *pieColor = [UIColor colorWithHexRGB:[pieInfo objectForKey:@"Color"] AndAlpha:1.0];
		NSDictionary *pieDic = [NSDictionary dictionaryWithObjectsAndKeys:pieValue,@"PieValue",pieColor,@"PieColor",nil];
		[_pieDicArray addObject:pieDic];
	}
	
	[self.pieChartLeft setChartDelegate:self];
    [self.pieChartLeft setChartDataSource:self];
    [self.pieChartLeft setStartPieAngle:M_PI_2];
	[self.pieChartLeft setAnimationSpeed:1.0];
	[self.pieChartLeft setShowPercentage:[[[self.pieChartConfigArray objectAtIndex:0] objectForKey:@"ShowPercentage"] boolValue]];
	[self.pieChartLeft setLabelShadowColor:[UIColor colorWithHexRGB:[[self.pieChartConfigArray objectAtIndex:0] objectForKey:@"ValueShadowColor"] AndAlpha:1]];
	[self.pieChartLeft setPieCenter:CGPointMake(self.pieChartLeft.frame.size.width/2, self.pieChartLeft.frame.size.height/2)];
	
	CGRect percentageFrame = self.percentageLabel.frame;
	percentageFrame.origin.x = self.pieChartLeft.frame.size.width/2 - self.percentageLabel.frame.size.width/2;
	percentageFrame.origin.y = self.pieChartLeft.frame.size.height/2 - self.percentageLabel.frame.size.height/2;
    self.percentageLabel.frame = percentageFrame;
	
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
		[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		[self.pieChartLeft setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:24]];
	}
	else
	{
		[self.pieChartLeft setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:12]];
	}
	
    [self.pieChartRight setChartDelegate:self];
    [self.pieChartRight setChartDataSource:self];
	[self.pieChartRight setStartPieAngle:M_PI_2];
    [self.pieChartRight setAnimationSpeed:1.0];
	[self.pieChartRight setShowPercentage:NO];
	[self.pieChartRight setLabelColor:[UIColor colorWithHexRGB:[[self.pieChartConfigArray objectAtIndex:0] objectForKey:@"LabelColor"] AndAlpha:1]];
	[self.pieChartRight setPieCenter:CGPointMake(self.pieChartRight.frame.size.width/2, self.pieChartRight.frame.size.height/2)];
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
		[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		[self.percentageLabel.layer setCornerRadius:90];
	}
	else
	{
		[self.percentageLabel.layer setCornerRadius:15];
	}

}

- (void)viewDidUnload
{
    [self setPieChartLeft:nil];
    [self setPieChartRight:nil];
    [self setPercentageLabel:nil];
    [self setSelectedSliceLabel:nil];
    [self setIndexOfSlices:nil];
    [self setNumOfSlices:nil];
    [self setDownArrow:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.pieChartLeft reloadData];
    [self.pieChartRight reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)SliceNumChanged:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSInteger num = self.numOfSlices.text.intValue;
    if(btn.tag == 100 && num > -10)
        num = num - ((num == 1)?2:1);
    if(btn.tag == 101 && num < 10)
        num = num + ((num == -1)?2:1);
    
    self.numOfSlices.text = [NSString stringWithFormat:@"%d",num];
}

- (IBAction)clearSlices {
	[_pieDicArray removeAllObjects];
    [_selectedSliceLabel setText:@""];
    [self.pieChartLeft reloadData];
    [self.pieChartRight reloadData];
}

- (IBAction)addSliceBtnClicked:(id)sender
{
    NSInteger num = [self.numOfSlices.text intValue];
    if (num > 0) {
        for (int n=0; n < abs(num); n++)
        {
            NSNumber *pieValue = [self getRandomNum:NO seed:100];
            NSString *hexColor = [self getRandomColor];
            
			NSDictionary *pieDic = [NSDictionary dictionaryWithObjectsAndKeys:pieValue,@"Value",hexColor,@"Color",nil];
            NSInteger index = 0;
            if(self.pieChartDataArray.count > 0) 
            {
                switch (self.indexOfSlices.selectedSegmentIndex) {
                    case 1:
                        index = rand()%self.pieChartDataArray.count; 
                        break;
                    case 2:
                        index = self.pieChartDataArray.count - 1; 
                        break;
                }
            }
			[_pieChartDataArray insertObject:pieDic atIndex:index]; 
        }
    }
    else if (num < 0)
    {
        if(self.pieChartDataArray.count <= 0) return; 
        for (int n=0; n < abs(num); n++)
        {
            NSInteger index = 0;
            if(self.pieChartDataArray.count > 0) 
            {
                switch (self.indexOfSlices.selectedSegmentIndex) {
                    case 1:
                        index = rand()%self.pieChartDataArray.count; 
                        break;
                    case 2:
                        index = self.pieChartDataArray.count - 1; 
                        break;
                }
                [_pieChartDataArray removeObjectAtIndex:index]; 
            }
        }
    }
	[_pieDicArray removeAllObjects];
	for (NSDictionary *pieInfo in self.pieChartDataArray)
	{
		NSNumber *pieValue = [NSNumber numberWithFloat:[[pieInfo objectForKey:@"Value"] floatValue]];
		UIColor *pieColor = [UIColor colorWithHexRGB:[pieInfo objectForKey:@"Color"] AndAlpha:1.0];
		NSDictionary *pieDic = [NSDictionary dictionaryWithObjectsAndKeys:pieValue,@"PieValue",pieColor,@"PieColor",nil];
		[_pieDicArray addObject:pieDic];
	}
    [self.pieChartLeft reloadData];
    [self.pieChartRight reloadData];
}

- (IBAction)updateSlices
{
	[_pieDicArray removeAllObjects];
	for (NSDictionary *pieInfo in self.pieChartDataArray)
	{
		NSNumber *pieValue = [NSNumber numberWithFloat:[[pieInfo objectForKey:@"Value"] floatValue]];
		UIColor *pieColor = [UIColor colorWithHexRGB:[pieInfo objectForKey:@"Color"] AndAlpha:1.0];
		NSDictionary *pieDic = [NSDictionary dictionaryWithObjectsAndKeys:pieValue,@"PieValue",pieColor,@"PieColor",nil];
		[_pieDicArray addObject:pieDic];
	}
    [self.pieChartLeft reloadData];
    [self.pieChartRight reloadData];
}

- (IBAction)showSlicePercentage:(id)sender {
    UISwitch *perSwitch = (UISwitch *)sender;
    [self.pieChartRight setShowPercentage:perSwitch.isOn];
}

#pragma mark - MBMPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(MBMPieChart *)pieChart
{
    return self.pieDicArray.count;
}

- (CGFloat)pieChart:(MBMPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
	return [[[self.pieDicArray objectAtIndex:index] objectForKey:@"PieValue"] floatValue];
}

- (UIColor *)pieChart:(MBMPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
	return [[self.pieDicArray objectAtIndex:index] objectForKey:@"PieColor"];
}

#pragma mark - MBMPieChart Delegate
- (void)pieChart:(MBMPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
	int value = [[[self.pieDicArray objectAtIndex:index] objectForKey:@"PieValue"] intValue];
    self.selectedSliceLabel.text = [NSString stringWithFormat:@"%d",value];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[_pieChart release];
	[_pieChartCopy release];
	[_percentageLabel release];
	[_selectedSliceLabel release];
	[_numOfSlices release];
	[_indexOfSlices release];
	[_downArrow release];
	[super dealloc];
}

@end
