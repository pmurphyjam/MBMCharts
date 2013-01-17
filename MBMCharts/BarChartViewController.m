//
//  BarChartViewController.m
//  MBMCharts
//
//  Created by Pat Murphy on 12/14/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import "BarChartViewController.h"
#import "MBMChartDefines.h"
#import "MBMBarChart.h"
#import "UIColorCategory.h"

@interface BarChartViewController ()

@end

@implementation BarChartViewController

@synthesize barChart = _barChart;
@synthesize selectedBarLabel = _selectedBarLabel;
@synthesize numOfBars = _numOfBars;
@synthesize indexOfBars = _indexOfBars;
@synthesize downArrow = _downArrow;
@synthesize barDicArray = _barDicArray;
@synthesize barChartDataArray = _barChartDataArray;
@synthesize barChartConfigArray = _barChartConfigArray;

- (void)loadView
{
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
		[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		[[NSBundle mainBundle] loadNibNamed:@"BarChartViewController-iPad" owner:self options:nil];
	}
	else
	{
		[[NSBundle mainBundle] loadNibNamed:@"BarChartViewController" owner:self options:nil];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Bar Chart";
	_barDicArray = [[NSMutableArray alloc] init];
	_barChartDataArray = [[NSMutableArray alloc] init];
	_barChartConfigArray = [[NSMutableArray alloc] init];

	//rotate up arrow
    self.downArrow.transform = CGAffineTransformMakeRotation(M_PI);
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	//View is sized properly so set chartRect
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
		[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		[self.barChart setChartRect:self.view.frame];
	[self setUpChart];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.barChart reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void) setUpChart
{
	
	NSDictionary *chartConfigData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"showAxisY",[NSNumber numberWithBool:YES],@"showAxisX",@"2ca095",@"ColorAxisY",@"0110ad",@"ColorAxis",[NSNumber numberWithBool:YES],@"PlotVerticalLines",[NSNumber numberWithBool:YES],@"AddHorizontalLabels",@"ff0000",@"ValueColor",@"0000ff",@"ValueShadowColor",nil];
	[self.barChartConfigArray addObject:chartConfigData];
	
	NSDictionary *chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Jan",@"Label",@"3e5273",@"LabelColor",@"19",@"Value",@"3e5273",@"Color",nil];
	[_barChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Feb",@"Label",@"2ca095",@"LabelColor",@"34",@"Value",@"2ca095",@"Color",nil];
	[_barChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Mar",@"Label",@"566967",@"LabelColor",@"40",@"Value",@"566967",@"Color",nil];
	[_barChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Apr",@"Label",@"016fad",@"LabelColor",@"80",@"Value",@"016fad",@"Color",nil];
	[_barChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"May",@"Label",@"47a939",@"LabelColor",@"87",@"Value",@"47a939",@"Color",nil];
	[_barChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Jun",@"Label",@"336981",@"LabelColor",@"100",@"Value",@"336981",@"Color",nil];
	[_barChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Jul",@"Label",@"b8a23d",@"LabelColor",@"160",@"Value",@"b8a23d",@"Color",nil];
	[_barChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Aug",@"Label",@"2ca095",@"LabelColor",@"267",@"Value",@"2ca095",@"Color",nil];
	[_barChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Sep",@"Label",@"566967",@"LabelColor",@"276",@"Value",@"566967",@"Color",nil];
	[_barChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Oct",@"Label",@"016fad",@"LabelColor",@"303",@"Value",@"016fad",@"Color",nil];
	[_barChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Nov",@"Label",@"b8a23d",@"LabelColor",@"356",@"Value",@"b8a23d",@"Color",nil];
	[_barChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Dec",@"Label",@"3e5273",@"LabelColor",@"436",@"Value",@"3e5273",@"Color",nil];
	[_barChartDataArray addObject:chartData];
	
	
	[self.barChart setShowAxisX:[[[self.barChartConfigArray objectAtIndex:0] objectForKey:@"showAxisX"] boolValue]];
	[self.barChart setShowAxisY:[[[self.barChartConfigArray objectAtIndex:0] objectForKey:@"showAxisY"] boolValue]];
	[self.barChart setNumberOfElements:[self.barChartDataArray count]];
	[self.barChart setPlotVerticalLines:[[[self.barChartConfigArray objectAtIndex:0] objectForKey:@"PlotVerticalLines"] boolValue]];
	[self.barChart setAddHorizontalLabels:[[[self.barChartConfigArray objectAtIndex:0] objectForKey:@"AddHorizontalLabels"] boolValue]];
	[self.barChart setColorAxisY:[UIColor colorWithHexRGB:[[self.barChartConfigArray objectAtIndex:0] objectForKey:@"ColorAxisY"] AndAlpha:1]];
	[self.barChart setColorAxis:[UIColor colorWithHexRGB:[[self.barChartConfigArray objectAtIndex:0] objectForKey:@"ColorAxis"] AndAlpha:1]];
	[self.barChart setValueColor:[UIColor colorWithHexRGB:[[self.barChartConfigArray objectAtIndex:0] objectForKey:@"ValueColor"] AndAlpha:1]];
	[self.barChart setValueShadowColor:[UIColor colorWithHexRGB:[[self.barChartConfigArray objectAtIndex:0] objectForKey:@"ValueShadowColor"] AndAlpha:1]];

	[self.barChart calculateChartFrame];

	CGFloat xPos = self.barChart.leftPadding + self.barChart.labelSizeAxisY.width;
	CGFloat yPos = self.barChart.frame.size.height - self.barChart.paddingBotom;

	CGFloat barWidth = self.barChart.barWidth;
	CGFloat barHeight = 0;
	for (NSDictionary *barInfo in self.barChartDataArray)
	{
		barHeight = [[barInfo objectForKey:@"Value"] floatValue] * -1;
		UIColor *barColor = [UIColor colorWithHexRGB:[barInfo objectForKey:@"Color"] AndAlpha:1.0];
		UIColor *barLabelColor = [UIColor colorWithHexRGB:[barInfo objectForKey:@"LabelColor"] AndAlpha:1.0];
		NSValue *rectValue = [NSValue valueWithCGRect:CGRectMake(xPos, yPos, barWidth, barHeight)];
		NSString *label = [barInfo objectForKey:@"Label"];
		xPos = xPos + self.barChart.barWidth + self.barChart.barInterval;
		[self.barChart setDelegate:self];
		[self.barChart setDataSource:self];
		[self.barChart setNumberOfBars:[self.barChartDataArray count]];
		[self.barChart setAnimationSpeed:1.0];
		[self.barChart setUserInteractionEnabled:YES];
		NSNumber *value = [NSNumber numberWithDouble:barHeight * -1];
		NSDictionary *barDic = [NSDictionary dictionaryWithObjectsAndKeys:value,@"BarValue",rectValue,@"BarRect",barColor,@"BarColor",barLabelColor,@"LabelColor",label,@"BarLabel",nil];
		[_barDicArray addObject:barDic];
	}
	[self.barChart drawChart:_barDicArray];	
}

- (IBAction)barNumChanged:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSInteger num = self.numOfBars.text.intValue;
    if(btn.tag == 100 && num > -10)
        num = num - ((num == 1)?2:1);
    if(btn.tag == 101 && num < 10)
        num = num + ((num == -1)?2:1);
    
    self.numOfBars.text = [NSString stringWithFormat:@"%d",num];
}

- (IBAction)clearBars {
	for(int index = 0; index < _barDicArray.count; index ++)
	{
		NSMutableDictionary *barDic = [[_barDicArray objectAtIndex:index] mutableCopy];
		CGRect barRectInst = [[barDic objectForKey:@"BarRect"] CGRectValue];
		NSValue *barRectValue = [NSValue valueWithCGRect:CGRectMake(barRectInst.origin.x, barRectInst.origin.y, barRectInst.size.width, -10)];
		[barDic setObject:barRectValue forKey:@"BarRect"];
		[_barDicArray replaceObjectAtIndex:index withObject:barDic];
		[barDic release];
	}
	[self.barChart reloadData];
}

- (IBAction)addBarBtnClicked:(id)sender
{
	NSInteger num = [self.numOfBars.text intValue];
	NSArray *monthNames = [NSArray arrayWithObjects:@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec",nil];
	if (num > 0) {
        for (int n=0; n < abs(num); n++)
		{
			NSNumber *barHeightNum = [NSNumber numberWithInt:arc4random()%300+20];
			NSInteger baseInt = arc4random() % 16777216;
			NSString *hexColor = [NSString stringWithFormat:@"%06X", baseInt];
			
			NSInteger index = self.barChartDataArray.count;
            if(self.barChartDataArray.count > 0)
            {
                switch (self.indexOfBars.selectedSegmentIndex) {
                    case 1:
                        index = rand()%self.barChartDataArray.count;
                        break;
                    case 2:
                        index = 0;
                        break;
                }
				NSString *monthLabel = [monthNames objectAtIndex:index % 12];
				NSDictionary *chartData = [NSDictionary dictionaryWithObjectsAndKeys:monthLabel,@"Label",hexColor,@"LabelColor",barHeightNum,@"Value",hexColor,@"Color",nil];
				[self.barChartDataArray insertObject:chartData atIndex:index];
            }
		}
		//Reorder month names
		for(int index = 0; index < _barChartDataArray.count; index ++)
		{
			NSMutableDictionary *barDic = [[_barChartDataArray objectAtIndex:index] mutableCopy];
			NSString *monthLabel = [monthNames objectAtIndex:index % 12];
			[barDic setObject:monthLabel forKey:@"Label"];
			[_barChartDataArray replaceObjectAtIndex:index withObject:barDic];
			[barDic release];
		}
	}
	else if (num < 0)
    {
        if(self.barChartDataArray.count <= 0) return;
        for (int n=0; n < abs(num); n++)
        {
			NSInteger index = self.barChartDataArray.count - 1;
            if(self.barChartDataArray.count > 0)
            {
                switch (self.indexOfBars.selectedSegmentIndex) {
                    case 1:
                        index = rand()%self.barChartDataArray.count;
                        break;
                    case 2:
                        index = 0;
                        break;
                }
                [self.barChartDataArray removeObjectAtIndex:index];
            }
		}
	}

	[_barDicArray removeAllObjects];
	[self.barChart setNumberOfElements:[self.barChartDataArray count]];
	[self.barChart calculateChartFrame];

	CGFloat xPos = self.barChart.leftPadding + self.barChart.labelSizeAxisY.width;
	CGFloat yPos = self.barChart.frame.size.height - self.barChart.paddingBotom;
	CGFloat barWidth = self.barChart.barWidth;
	CGFloat barHeight = 0;
	for (NSDictionary *barInfo in self.barChartDataArray)
	{
		barHeight = [[barInfo objectForKey:@"Value"] floatValue] * -1;
		UIColor *barColor = [UIColor colorWithHexRGB:[barInfo objectForKey:@"Color"] AndAlpha:1.0];
		UIColor *barLabelColor = [UIColor colorWithHexRGB:[barInfo objectForKey:@"LabelColor"] AndAlpha:1.0];
		NSValue *rectValue = [NSValue valueWithCGRect:CGRectMake(xPos, yPos, barWidth, barHeight)];
		NSString *label = [barInfo objectForKey:@"Label"];
		xPos = xPos + self.barChart.barWidth + self.barChart.barInterval;
		[self.barChart setDelegate:self];
		[self.barChart setDataSource:self];
		[self.barChart setNumberOfBars:[self.barChartDataArray count]];
		[self.barChart setAnimationSpeed:1.0];
		[self.barChart setUserInteractionEnabled:YES];
		NSNumber *value = [NSNumber numberWithDouble:barHeight * -1];
		NSDictionary *barDic = [NSDictionary dictionaryWithObjectsAndKeys:value,@"BarValue",rectValue,@"BarRect",barColor,@"BarColor",barLabelColor,@"LabelColor",label,@"BarLabel",nil];
		[_barDicArray addObject:barDic];
	}
	[self.barChart drawChart:_barDicArray];

	[self.barChart reloadData];
}

- (IBAction)updateBars
{
	for(int index = 0; index < _barDicArray.count; index ++)
	{
		NSMutableDictionary *barDic = [[_barDicArray objectAtIndex:index] mutableCopy];
		CGRect barRectInst = [[barDic objectForKey:@"BarRect"] CGRectValue];
		CGFloat barHeight = [[barDic objectForKey:@"BarValue"] floatValue] * -1;
		NSValue *barRectValue = [NSValue valueWithCGRect:CGRectMake(barRectInst.origin.x, barRectInst.origin.y, barRectInst.size.width, barHeight)];
		[barDic setObject:barRectValue forKey:@"BarRect"];
		[_barDicArray replaceObjectAtIndex:index withObject:barDic];
		[barDic release];
	}
	[self.barChart reloadData];
}

#pragma mark - MBMBarChart Data Source

- (NSUInteger)numberOfBarsInChart:(MBMBarChart *)barChart
{
    return self.barDicArray.count;
}

- (CGFloat)barChart:(MBMBarChart *)barChart valueForBarAtIndex:(NSUInteger)index
{
	return [[[self.barDicArray objectAtIndex:index] objectForKey:@"BarValue"] intValue];
}

- (CGRect)barChart:(MBMBarChart *)barChart rectForBarAtIndex:(NSUInteger)index
{
	return [[[self.barDicArray objectAtIndex:index] objectForKey:@"BarRect"] CGRectValue];
}

- (UIColor *)barChart:(MBMBarChart *)barChart colorForBarAtIndex:(NSUInteger)index
{
	return [[self.barDicArray objectAtIndex:index] objectForKey:@"BarColor"];
}

- (NSString *)barChart:(MBMBarChart *)barChart textForBarAtIndex:(NSUInteger)index
{
	return [[self.barDicArray objectAtIndex:index] objectForKey:@"BarLabel"];
}

#pragma mark - MBMBarChart Delegate
- (void)barChart:(MBMBarChart *)barChart didSelectBarAtIndex:(NSUInteger)index
{
	int value = [[[self.barDicArray objectAtIndex:index] objectForKey:@"BarValue"] intValue];
    self.selectedBarLabel.text = [NSString stringWithFormat:@"%d",value];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[_barChart release];
	[_selectedBarLabel release];
	[_numOfBars release];
	[_indexOfBars release];
	[_downArrow release];
    [_barDicArray release];
	[_barChartDataArray release];
    [_barChartConfigArray release];
	[super dealloc];
}

@end
