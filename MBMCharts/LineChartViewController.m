//
//  LineChartViewController.m
//  MBMCharts
//
//  Created by Pat Murphy on 12/14/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import "LineChartViewController.h"
#import "MBMChartDefines.h"
#import "MBMLineChart.h"
#import "UIColorCategory.h"

@interface LineChartViewController ()

@end

@implementation LineChartViewController

@synthesize lineChart = _lineChart;
@synthesize selectedLineLabel = _selectedLineLabel;
@synthesize numOfLines = _numOfLines;
@synthesize indexOfLines = _indexOfLines;
@synthesize downArrow = _downArrow;
@synthesize lineDicArray = _lineDicArray;
@synthesize lineChartDataArray = _lineChartDataArray;
@synthesize lineChartConfigArray = _lineChartConfigArray;

- (void)loadView
{
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
		[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		[[NSBundle mainBundle] loadNibNamed:@"LineChartViewController-iPad" owner:self options:nil];
	}
	else
	{
		[[NSBundle mainBundle] loadNibNamed:@"LineChartViewController" owner:self options:nil];
		NSLog(@"LineChartVCtrl : loadView : iPhone Nib");
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Line Chart";
    _lineDicArray = [[NSMutableArray alloc] init];
	_lineChartDataArray = [[NSMutableArray alloc] init];
	_lineChartConfigArray = [[NSMutableArray alloc] init];
	
    //rotate up arrow
    self.downArrow.transform = CGAffineTransformMakeRotation(M_PI);
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	//View is sized properly so set chartRect
	[self.lineChart setChartRect:self.view.frame];
	[self setUpChart];
}

- (void) setUpChart
{
	
	NSDictionary *chartConfigData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"showAxisY",[NSNumber numberWithBool:YES],@"showAxisX",@"2ca095",@"ColorAxisY",@"0110ad",@"ColorAxis",[NSNumber numberWithBool:YES],@"PlotVerticalLines",[NSNumber numberWithBool:YES],@"AddHorizontalLabels",@"ff0000",@"ValueColor",@"0000ff",@"ValueShadowColor",nil];
	[self.lineChartConfigArray addObject:chartConfigData];
	
	NSDictionary *chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Jan",@"Label",@"3e5273",@"LabelColor",@"19",@"Value",@"3e5273",@"Color",nil];
	[_lineChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Feb",@"Label",@"2ca095",@"LabelColor",@"34",@"Value",@"2ca095",@"Color",nil];
	[_lineChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Mar",@"Label",@"566967",@"LabelColor",@"40",@"Value",@"566967",@"Color",nil];
	[_lineChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Apr",@"Label",@"016fad",@"LabelColor",@"80",@"Value",@"016fad",@"Color",nil];
	[_lineChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"May",@"Label",@"47a939",@"LabelColor",@"87",@"Value",@"47a939",@"Color",nil];
	[_lineChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Jun",@"Label",@"336981",@"LabelColor",@"100",@"Value",@"336981",@"Color",nil];
	[_lineChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Jul",@"Label",@"b8a23d",@"LabelColor",@"160",@"Value",@"b8a23d",@"Color",nil];
	[_lineChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Aug",@"Label",@"2ca095",@"LabelColor",@"267",@"Value",@"2ca095",@"Color",nil];
	[_lineChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Sep",@"Label",@"566967",@"LabelColor",@"276",@"Value",@"566967",@"Color",nil];
	[_lineChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Oct",@"Label",@"016fad",@"LabelColor",@"303",@"Value",@"016fad",@"Color",nil];
	[_lineChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Nov",@"Label",@"b8a23d",@"LabelColor",@"356",@"Value",@"b8a23d",@"Color",nil];
	[_lineChartDataArray addObject:chartData];
	chartData = [NSDictionary dictionaryWithObjectsAndKeys:@"Dec",@"Label",@"3e5273",@"LabelColor",@"436",@"Value",@"3e5273",@"Color",nil];
	[_lineChartDataArray addObject:chartData];
		
	[self.lineChart setShowAxisX:[[[self.lineChartConfigArray objectAtIndex:0] objectForKey:@"showAxisX"] boolValue]];
	[self.lineChart setShowAxisY:[[[self.lineChartConfigArray objectAtIndex:0] objectForKey:@"showAxisY"] boolValue]];
	[self.lineChart setNumberOfElements:[self.lineChartDataArray count]];
	[self.lineChart setPlotVerticalLines:[[[self.lineChartConfigArray objectAtIndex:0] objectForKey:@"PlotVerticalLines"] boolValue]];
	[self.lineChart setAddHorizontalLabels:[[[self.lineChartConfigArray objectAtIndex:0] objectForKey:@"AddHorizontalLabels"] boolValue]];
	[self.lineChart setColorAxisY:[UIColor colorWithHexRGB:[[self.lineChartConfigArray objectAtIndex:0] objectForKey:@"ColorAxisY"] AndAlpha:1]];
	[self.lineChart setColorAxis:[UIColor colorWithHexRGB:[[self.lineChartConfigArray objectAtIndex:0] objectForKey:@"ColorAxis"] AndAlpha:1]];
	[self.lineChart setLabelColor:[UIColor colorWithHexRGB:[[self.lineChartConfigArray objectAtIndex:0] objectForKey:@"ValueColor"] AndAlpha:1]];
	[self.lineChart setLabelShadowColor:[UIColor colorWithHexRGB:[[self.lineChartConfigArray objectAtIndex:0] objectForKey:@"ValueShadowColor"] AndAlpha:1]];
	
	[self.lineChart calculateChartFrame];
	
	CGFloat xPos = self.lineChart.leftPadding + self.lineChart.labelSizeAxisY.width + self.lineChart.barWidth/2;

	CGFloat barHeight = 0;
	for (NSDictionary *lineInfo in self.lineChartDataArray)
	{
		barHeight = [[lineInfo objectForKey:@"Value"] floatValue];
		UIColor *lineColor = [UIColor colorWithHexRGB:[lineInfo objectForKey:@"Color"] AndAlpha:1.0];
		UIColor *lineLabelColor = [UIColor colorWithHexRGB:[lineInfo objectForKey:@"LabelColor"] AndAlpha:1.0];
        NSValue *pointValue = [NSValue valueWithCGPoint:CGPointMake(xPos, barHeight)];
		NSString *label = [lineInfo objectForKey:@"Label"];
		xPos = xPos + self.lineChart.barWidth + self.lineChart.barInterval;
		[self.lineChart setDelegate:self];
		[self.lineChart setDataSource:self];
		[self.lineChart setNumberOfLines:[self.lineChartDataArray count]];
		[self.lineChart setAnimationSpeed:1.0];
		[self.lineChart setUserInteractionEnabled:YES];
		NSNumber *value = [NSNumber numberWithDouble:barHeight];
		NSDictionary *lineDic = [NSDictionary dictionaryWithObjectsAndKeys:value,@"LineValue",pointValue,@"LinePoint",lineColor,@"LineColor",lineLabelColor,@"LabelColor",label,@"LineLabel",nil];
		[_lineDicArray addObject:lineDic];
	}
	[self.lineChart drawChart:_lineDicArray];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.lineChart reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (IBAction)lineNumChanged:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSInteger num = self.numOfLines.text.intValue;
    if(btn.tag == 100 && num > -10)
        num = num - ((num == 1)?2:1);
    if(btn.tag == 101 && num < 10)
        num = num + ((num == -1)?2:1);
    
    self.numOfLines.text = [NSString stringWithFormat:@"%d",num];
}

- (IBAction)clearLines {
	for(int index = 0; index < _lineDicArray.count; index ++)
	{
		NSMutableDictionary *lineDic = [[_lineDicArray objectAtIndex:index] mutableCopy];
        CGPoint linePointInst = [[lineDic objectForKey:@"LinePoint"] CGPointValue];
		NSValue *linePointValue = [NSValue valueWithCGPoint:CGPointMake(linePointInst.x, 0)];
		[lineDic setObject:linePointValue forKey:@"LinePoint"];
		[_lineDicArray replaceObjectAtIndex:index withObject:lineDic];
		[lineDic release];
	}
	[self.lineChart reloadData];
}

- (IBAction)addLineBtnClicked:(id)sender
{
    NSInteger num = [self.numOfLines.text intValue];
	NSArray *monthNames = [NSArray arrayWithObjects:@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec",nil];
	if (num > 0) {
        for (int n=0; n < abs(num); n++)
		{
			NSNumber *barHeightNum = [NSNumber numberWithInt:arc4random()%300+20];
			NSInteger baseInt = arc4random() % 16777216;
			NSString *hexColor = [NSString stringWithFormat:@"%06X", baseInt];
			
			NSInteger index = self.lineChartDataArray.count;
            if(self.lineChartDataArray.count > 0)
            {
                switch (self.indexOfLines.selectedSegmentIndex) {
                    case 1:
                        index = rand()%self.lineChartDataArray.count;
                        break;
                    case 2:
                        index = 0;
                        break;
                }
				NSString *monthLabel = [monthNames objectAtIndex:index % 12];
				NSDictionary *chartData = [NSDictionary dictionaryWithObjectsAndKeys:monthLabel,@"Label",hexColor,@"LabelColor",barHeightNum,@"Value",hexColor,@"Color",nil];
				[self.lineChartDataArray insertObject:chartData atIndex:index];
            }
		}
		//Reorder month names
		for(int index = 0; index < _lineChartDataArray.count; index ++)
		{
			NSMutableDictionary *barDic = [[_lineChartDataArray objectAtIndex:index] mutableCopy];
			NSString *monthLabel = [monthNames objectAtIndex:index % 12];
			[barDic setObject:monthLabel forKey:@"Label"];
			[_lineChartDataArray replaceObjectAtIndex:index withObject:barDic];
			[barDic release];
		}
	}
	else if (num < 0)
    {
        if(self.lineChartDataArray.count <= 0) return;
        for (int n=0; n < abs(num); n++)
        {
			NSInteger index = self.lineChartDataArray.count - 1;
            if(self.lineChartDataArray.count > 0)
            {
                switch (self.indexOfLines.selectedSegmentIndex) {
                    case 1:
                        index = rand()%self.lineChartDataArray.count;
                        break;
                    case 2:
                        index = 0;
                        break;
                }
                [self.lineChartDataArray removeObjectAtIndex:index];
            }
		}
	}
    
	[_lineDicArray removeAllObjects];
	[self.lineChart setNumberOfElements:[self.lineChartDataArray count]];
	[self.lineChart calculateChartFrame];
    
	CGFloat xPos = self.lineChart.leftPadding + self.lineChart.labelSizeAxisY.width + self.lineChart.barWidth/2;
	CGFloat barHeight = 0;
	for (NSDictionary *lineInfo in self.lineChartDataArray)
	{
		barHeight = [[lineInfo objectForKey:@"Value"] floatValue];
		UIColor *lineColor = [UIColor colorWithHexRGB:[lineInfo objectForKey:@"Color"] AndAlpha:1.0];
		UIColor *lineLabelColor = [UIColor colorWithHexRGB:[lineInfo objectForKey:@"LabelColor"] AndAlpha:1.0];
        NSValue *pointValue = [NSValue valueWithCGPoint:CGPointMake(xPos, barHeight)];
		NSString *label = [lineInfo objectForKey:@"Label"];
		xPos = xPos + self.lineChart.barWidth + self.lineChart.barInterval;
		[self.lineChart setDelegate:self];
		[self.lineChart setDataSource:self];
		[self.lineChart setNumberOfLines:[self.lineChartDataArray count]];
		[self.lineChart setAnimationSpeed:1.0];
		[self.lineChart setUserInteractionEnabled:YES];
		NSNumber *value = [NSNumber numberWithDouble:barHeight];
		NSDictionary *barDic = [NSDictionary dictionaryWithObjectsAndKeys:value,@"LineValue",pointValue,@"LinePoint",lineColor,@"LineColor",lineLabelColor,@"LabelColor",label,@"LineLabel",nil];
		[_lineDicArray addObject:barDic];
	}
	[self.lineChart drawChart:_lineDicArray];
    [self.lineChart reloadData];
}

- (IBAction)updateLines
{
	for(int index = 0; index < _lineDicArray.count; index ++)
	{
		NSMutableDictionary *lineDic = [[_lineDicArray objectAtIndex:index] mutableCopy];
		CGPoint linePointInst = [[lineDic objectForKey:@"LinePoint"] CGPointValue];
		CGFloat lineHeight = [[lineDic objectForKey:@"LineValue"] floatValue];
        NSValue *linePointValue = [NSValue valueWithCGPoint:CGPointMake(linePointInst.x, lineHeight)];
		[lineDic setObject:linePointValue forKey:@"LinePoint"];
		[_lineDicArray replaceObjectAtIndex:index withObject:lineDic];
		[lineDic release];
	}
	[self.lineChart reloadData];
}

#pragma mark - MBMLineChart Data Source

- (NSUInteger)numberOfLinesInChart:(MBMLineChart *)lineChart
{
    return self.lineChartDataArray.count;
}

- (CGFloat)lineChart:(MBMLineChart *)lineChart valueForLineAtIndex:(NSUInteger)index
{
    return [[[self.lineDicArray objectAtIndex:index] objectForKey:@"LineValue"] floatValue];
}

- (CGPoint)lineChart:(MBMLineChart *)lineChart pointForLineAtIndex:(NSUInteger)index
{
	return [[[self.lineDicArray objectAtIndex:index] objectForKey:@"LinePoint"] CGPointValue];
}

- (UIColor *)lineChart:(MBMLineChart *)lineChart colorForLineAtIndex:(NSUInteger)index
{
	return [[self.lineDicArray objectAtIndex:index] objectForKey:@"LineColor"];
}

#pragma mark - MBMLineChart Delegate
- (void)lineChart:(MBMLineChart *)lineChart didSelectLineAtIndex:(NSUInteger)index
{
    int value = [[[self.lineDicArray objectAtIndex:index] objectForKey:@"LineValue"] intValue];
    self.selectedLineLabel.text = [NSString stringWithFormat:@"%d",value];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[_lineChart release];
	[_selectedLineLabel release];
	[_numOfLines release];
	[_indexOfLines release];
	[_downArrow release];
	[super dealloc];
}

@end
