//
//  MBMLineChart.m
//  MBMCharts
//
//  Created by Pat Murphy on 12/14/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import "MBMLineChart.h"
#import "UIColorCategory.h"
//#define DEBUG
#import "MBMChartDefines.h"
#import <QuartzCore/QuartzCore.h>
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface LineLayer : CAShapeLayer
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL touched;
@property (nonatomic, assign) NSUInteger section;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, retain) NSString *text;
- (void)createLineAnimationForKey:(NSString *)key fromValue:(NSValue *)from toValue:(NSValue *)to Delegate:(id)delegate;
- (void)createPathAnimationForKey:(NSString *)key fromValue:(CGPathRef)from toValue:(CGPathRef)to Delegate:(id)delegate;
@end

@implementation LineLayer
@synthesize text = _text;
@synthesize value = _value;
@synthesize point = _point;
@synthesize isSelected = _isSelected;
@synthesize touched = _touched;
@synthesize section = _section;
@synthesize index = _index;

- (NSString*)description
{
    return [NSString stringWithFormat:@"LineLayer : [%d,%d] : value = %f : Point : X = %f Y = %f : Touched = %@",_section,_index, _value, _point.x, _point.y,_touched?@"YES":@"NO"];
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"point"] || [key isEqualToString:@"path"]) {
        return YES;
    }
    else {
        return [super needsDisplayForKey:key];
    }
}

- (id)initWithLayer:(id)layer
{
    if (self = [super initWithLayer:layer])
    {
        if ([layer isKindOfClass:[LineLayer class]]) {
            self.point = [(LineLayer *)layer point];
        }
    }
    return self;
}

- (void)createLineAnimationForKey:(NSString *)key fromValue:(NSValue *)from toValue:(NSValue *)to Delegate:(id)delegate
{
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:key];
    CGPoint currentPoint = [[[self presentationLayer] valueForKey:key] CGPointValue];
	CGPoint fromPoint = [from CGPointValue];
	if(!currentPoint.x == 0) currentPoint = fromPoint;
    [lineAnimation setFromValue:[NSValue valueWithCGPoint:currentPoint]];
    [lineAnimation setToValue:to];
    [lineAnimation setDelegate:delegate];
    [lineAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self addAnimation:lineAnimation forKey:key];
    [self setValue:to forKey:key];
}

- (void)createPathAnimationForKey:(NSString *)key fromValue:(CGPathRef)from toValue:(CGPathRef)to Delegate:(id)delegate
{
    CABasicAnimation *linesAnimation = [CABasicAnimation animationWithKeyPath:key];
    NDLog(@"MBMLineChart : createPathAnimationForKey : key = %@ : fromPath = %@ : toPath = %@ ",key,CGPathIsEmpty(from)?@"Bad":@"Good",CGPathIsEmpty(from)?@"Bad":@"Good");
    [linesAnimation setFromValue:(id)from];
    [linesAnimation setToValue:(id)to];
    [linesAnimation setDelegate:delegate];
    [linesAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self addAnimation:linesAnimation forKey:key];
    [self setValue:(id)to forKey:key];
}

- (void)dealloc {
	[_text release];
	[super dealloc];
}

@end


@interface MBMLineChart (Private)
- (void)updateTimerFired:(NSTimer *)timer;
- (LineLayer *)createLineLayer;
- (CGSize)sizeThatFitsString:(NSString *)string;
- (void)updateLabelForLayer:(LineLayer *)LineLayer value:(CGFloat)value;
- (void)notifyDelegateOfSelectionChangeFrom:(NSUInteger)previousSelection to:(NSUInteger)newSelection forSection:(NSUInteger)section andRow:(NSUInteger)row;
@end

@implementation MBMLineChart
{
	NSInteger _selectedLineIndex;
	//line view, contains all lines in the graph
	UIView  *_lineView;
	//animation control
	NSTimer *_animationTimer;
	NSMutableArray *_animations;
}

static NSUInteger kDefaultLineZOrder = 100;
static NSUInteger kDefaultLineZOrderFront = 101;

@synthesize chartDataSource = _chartDataSource;
@synthesize chartDelegate = _chartDelegate;
@synthesize linePoint = _linePoint;
@synthesize animationSpeed = _animationSpeed;
@synthesize lineHeight = _lineHeight;
@synthesize lineRadius = _lineRadius;
@synthesize numberOfLines = _numberOfLines;
@synthesize showLabel = _showLabel;
@synthesize labelFont = _labelFont;
@synthesize labelColor = _labelColor;
@synthesize labelShadowColor = _labelShadowColor;
@synthesize selectedLineStroke = _selectedLineStroke;
@synthesize lineDicArray = _lineDicArray;
@synthesize chartRect;
@synthesize numberOfElements;
@synthesize paddingTop;
@synthesize paddingBotom;
@synthesize leftPadding;
@synthesize stepWidthAxisY;
@synthesize labelSizeAxisY;
@synthesize maxValueAxisY;
@synthesize minValueAxisY;
@synthesize stepValueAxisY;
@synthesize barFullWidth;
@synthesize fontSize;
@synthesize barLabelFontSize;
@synthesize barWidth;
@synthesize barInterval;
@synthesize maxValue;
@synthesize colorAxisY;
@synthesize colorAxis;
@synthesize showAxisY;
@synthesize showAxisX;
@synthesize scaleAxisY;
@synthesize plotVerticalLines;
@synthesize addHorizontalLabels;

-(UIColor*) getColorFrom:(UIColor*)inputColor add:(CGFloat)addValue
{
	const CGFloat *components = CGColorGetComponents(inputColor.CGColor);
	UIColor *newColor = RGBA(components[0]+addValue, components[1]+addValue, components[2]+addValue, components[3]);
	return newColor;
}

static NSDictionary* trigMethod(CGPoint fromPoint, CGPoint toPoint ,CGFloat radius,CGFloat lineStroke)
{
	CGPoint shorterToPoint = CGPointMake(fromPoint.x, fromPoint.y);
	//Do some Trig
	CGFloat dx = (toPoint.x - fromPoint.x);
    CGFloat dy = (toPoint.y - fromPoint.y);
	CGFloat hyp = sqrtf((dx * dx) + (dy * dy));
	CGFloat angle = 0;
	if(hyp > 0)
		angle = atan2f(dy, dx) + M_PI;
	
	CGFloat obs = sinf(angle)*(hyp - (radius + lineStroke/2));
	CGFloat newY = toPoint.y + obs;
	CGFloat adj = cosf(angle)*(hyp - (radius +lineStroke/2));
	CGFloat newX = toPoint.x + adj;
	
	if(hyp > 0)
	{
		shorterToPoint = CGPointMake(newX, newY);
	}

	NSDictionary *trigDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGPoint:shorterToPoint],@"NewPoint",[NSNumber  numberWithFloat:angle],@"Angle", nil];
	
	return trigDic;
}

static CGPathRef CGPathCreatePathFromPoint(CGPoint fromPoint, CGPoint toPoint, CGFloat radius,CGFloat lineStroke)
{
    NDLog(@"MBMLineChart : CGPathCreatePathFromPoint : fromPoint : x = %f : y = %f : toPoint : x = %f : y = %f  ",fromPoint.x,fromPoint.y,toPoint.x,toPoint.y);
	NSDictionary *trigDic = trigMethod(fromPoint,toPoint,radius,lineStroke);
	NDLog(@"MBMLineChart : CGPathCreatePathFromPoint : trigDic = %@ ",trigDic);
	CGFloat angle = [[trigDic objectForKey:@"Angle"] floatValue];
	CGPoint shorterToPoint = [[trigDic objectForKey:@"NewPoint"] CGPointValue];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRelativeArc(path, NULL, toPoint.x, toPoint.y, radius, angle, 2 * M_PI);
    if(angle != 0)
        CGPathAddLineToPoint(path, NULL, shorterToPoint.x,shorterToPoint.y);
	
	CGPathCloseSubpath(path);
	return path;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [super setDelegate:self];
        [self setContentSize:frame.size];
        [super setBackgroundColor:[UIColor clearColor]];
        [super setShowsHorizontalScrollIndicator:NO];
        [super setShowsVerticalScrollIndicator:NO];
		[super setScrollEnabled:YES];
        [super setClipsToBounds:YES];
        [super setBouncesZoom:YES];
        [super setMinimumZoomScale:1.0];
        [super setMaximumZoomScale:3.0];
        [super setZoomScale:1.0];
        
		[self setAutoresizesSubviews:YES];
        [self setClipsToBounds:YES];
        [self setClearsContextBeforeDrawing:YES];
        self.backgroundColor = [UIColor clearColor];
        _lineView = [[UIView alloc] initWithFrame:frame];
        [_lineView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_lineView];
        _selectedLineIndex = -1;
        _animations = [[NSMutableArray alloc] init];
        _animationSpeed = 0.5;
		if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
			[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		{
			fontSize = FONT_SIZE_IPAD;
			barLabelFontSize = BAR_LABEL_FONT_SIZE_IPAD;
			stepValueAxisY = STEP_AXIS_Y_IPAD;
			self.lineRadius = LINE_CHART_POINT_RADIUS_IPAD;
			_selectedLineStroke = LINE_STROKE_WIDTH_IPAD;
			self.labelFont = [UIFont boldSystemFontOfSize:15];
		}
		else
		{
			fontSize = FONT_SIZE_IPHONE;
			barLabelFontSize = BAR_LABEL_FONT_SIZE_IPHONE;
			stepValueAxisY = STEP_AXIS_Y_IPHONE;
			self.lineRadius = LINE_CHART_POINT_RADIUS_IPHONE;
			_selectedLineStroke = LINE_STROKE_WIDTH_IPHONE;
			self.labelFont = [UIFont boldSystemFontOfSize:10];
		}
		paddingTop = PLOT_PADDING_TOP;
		paddingBotom = PLOT_PADDING_BOTTOM;
		chartRect = frame;
		self.linePoint = CGPointMake(frame.origin.x, frame.origin.y);
        self.lineHeight = MIN(frame.size.width/2, frame.size.height/2) - 10;
        self.numberOfLines = 2;
        _labelColor = [UIColor whiteColor];
        _labelShadowColor = [UIColor clearColor];
		colorAxisY = [UIColor blackColor];
		colorAxis = [UIColor blackColor];
        _showLabel = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [super setDelegate:self];
        [super setContentSize:self.bounds.size];
        [super setBackgroundColor:[UIColor clearColor]];
        [super setShowsHorizontalScrollIndicator:NO];
        [super setShowsVerticalScrollIndicator:NO];
		[super setScrollEnabled:YES];
        [super setClipsToBounds:YES];
        [super setBouncesZoom:YES];
        [super setMinimumZoomScale:1.0];
        [super setMaximumZoomScale:3.0];
        [super setZoomScale:1.0];
        
        [self setAutoresizesSubviews:YES];
        [self setClipsToBounds:YES];
        [self setClearsContextBeforeDrawing:YES];
        self.backgroundColor = [UIColor clearColor];
        _lineView = [[UIView alloc] initWithFrame:self.bounds];
        [_lineView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_lineView];
        _selectedLineIndex = -1;
        _animations = [[NSMutableArray alloc] init];
        _animationSpeed = 0.5;
		if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
			[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		{
			fontSize = FONT_SIZE_IPAD;
			barLabelFontSize = BAR_LABEL_FONT_SIZE_IPAD;
			stepValueAxisY = STEP_AXIS_Y_IPAD;
			self.lineRadius = LINE_CHART_POINT_RADIUS_IPAD;
			_selectedLineStroke = LINE_STROKE_WIDTH_IPAD;
			self.labelFont = [UIFont boldSystemFontOfSize:15];
		}
		else
		{
			fontSize = FONT_SIZE_IPHONE;
			barLabelFontSize = BAR_LABEL_FONT_SIZE_IPHONE;
			stepValueAxisY = STEP_AXIS_Y_IPHONE;
			self.lineRadius = LINE_CHART_POINT_RADIUS_IPHONE;
			_selectedLineStroke = LINE_STROKE_WIDTH_IPHONE;
			self.labelFont = [UIFont boldSystemFontOfSize:10];
		}
		paddingTop = PLOT_PADDING_TOP;
		paddingBotom = PLOT_PADDING_BOTTOM;
		chartRect = self.bounds;
		CGRect bounds = [[self layer] bounds];
		self.linePoint = CGPointMake(bounds.origin.x, bounds.origin.y);
        self.lineHeight = MIN(bounds.size.width/2, bounds.size.height/2) - 10;
        self.numberOfLines = 2;
        _labelColor = [UIColor whiteColor];
		_labelShadowColor = [UIColor clearColor];
		colorAxisY = [UIColor blackColor];
		colorAxis = [UIColor blackColor];
        _showLabel = YES;
    }
    return self;
}

#pragma mark UIScrollViewDelegate

- (void)centerScrollViewContents {
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = _lineView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    _lineView.frame = contentsFrame;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _lineView;
}

-(void)scrollViewDidZoom:(UIScrollView *)pageScrollView
{
    [self centerScrollViewContents];
}

- (void)setLinePoint:(CGPoint)linePoint
{
	_linePoint = CGPointMake(linePoint.x,linePoint.y);
}

- (void)setLineBackgroundColor:(UIColor *)color
{
    [_lineView setBackgroundColor:color];
}

#pragma mark - manage settings

- (void)setLineSelectedAtIndex:(NSInteger)index
{
	NDLog(@"MBMLineChart : setLineSelectedAtIndex : index = %d  ",index);
    LineLayer *layer = [_lineView.layer.sublayers objectAtIndex:index];
    if (layer) {
        CGPoint currPos = layer.position;
		CALayer *labelLayer = [[layer sublayers] objectAtIndex:0];
		[labelLayer setHidden:NO];
		//Bring Label to Front
		[layer setZPosition:kDefaultLineZOrderFront];
        CGPoint newPos = CGPointMake(currPos.x + 0, currPos.y - 0);
        layer.position = newPos;
        layer.isSelected = YES;
    }
}

- (void)setLineDeselectedAtIndex:(NSInteger)index
{
	NDLog(@"MBMLineChart : setLineDeselectedAtIndex : index = %d  ",index);
    LineLayer *layer = [_lineView.layer.sublayers objectAtIndex:index];
    if (layer) {
		CALayer *labelLayer = [[layer sublayers] objectAtIndex:0];
		//Send Label back to usual position
		[layer setZPosition:kDefaultLineZOrder];
		[labelLayer setHidden:YES];
        layer.position = CGPointMake(0, 0);
        layer.isSelected = NO;
    }
}

#pragma mark - Line Reload Data With Animation

- (void)reloadData
{
    if (_chartDataSource && !_animationTimer)
    {        
        CALayer *parentLayer = [_lineView layer];
        NSArray *lineLayers = [parentLayer sublayers];
        NDLog(@"MBMLineChart : reloadData : lineLayers cnt = %d",[lineLayers count]);
        NSUInteger sectionCount = [_chartDataSource numberOfSectionsInChart:self];
        NDLog(@"MBMLineChart : reloadData : sectionCount = %d",sectionCount);
        int indexN = 0;
        NSMutableArray *layersToRemove = [NSMutableArray arrayWithArray:lineLayers];

        for (int section = 0; section < sectionCount; section++)
        {
            _selectedLineIndex = -1;
            [lineLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LineLayer *layer = (LineLayer *)obj;
                if(layer.isSelected)
                    [self setLineDeselectedAtIndex:idx];
            }];

            NSUInteger lineCount = [_chartDataSource numberOfLinesInChart:self forSection:section];
            NDLog(@"MBMLineChart : reloadData[%d] : lineCount = %d",section,lineCount);
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:_animationSpeed];
            
            [_lineView setUserInteractionEnabled:NO];
            
            [CATransaction setCompletionBlock:^{
                
                [layersToRemove enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [obj removeFromSuperlayer];
                }];
                
                [layersToRemove removeAllObjects];
                
                for(LineLayer *layer in _lineView.layer.sublayers)
                {
                    [layer setZPosition:kDefaultLineZOrder];
                }
                
                [_lineView setUserInteractionEnabled:YES];
            }];
            
            NSInteger diff = (lineCount * sectionCount) - [lineLayers count];
            NDLog(@"MBMLineChart : reloadData[%d] : diff = %d : layersToRemove cnt = %d",section,diff,[layersToRemove count]);

            CGPoint point = CGPointMake(0, 0);
            CGPoint fromPoint = CGPointMake(0, 0);
            CGPoint toScaledPoint = CGPointMake(0, 0);
            CGFloat valueY = self.bounds.size.height-self.paddingBotom;
            
            CGPathRef fromPath = nil;
            CGPathRef toPath = nil;
            
            for(int index = 0; index < lineCount; index ++)
            {
                LineLayer *layer;
                CGFloat value = [_chartDataSource lineChart:self valueForLineAtIndex:index forSection:section];

                if( indexN >= [lineLayers count] )
                {
                    layer = [self createLineLayer];
                    [parentLayer addSublayer:layer];
                    diff--;
                }
                else
                {
                    LineLayer *onelayer = [lineLayers objectAtIndex:indexN];
                    if(diff == 0 || onelayer.value == value)
                    {
                        layer = onelayer;
                        [layersToRemove removeObject:layer];
                    }
                    else if(diff > 0)
                    {
                        layer = [self createLineLayer];
                        [parentLayer insertSublayer:layer atIndex:indexN];
                        diff--;
                    }
                    else if(diff < 0)
                    {
                        while(diff < 0)
                        {
                            [onelayer removeFromSuperlayer];
                            [parentLayer addSublayer:onelayer];
                            diff++;
                            onelayer = [lineLayers objectAtIndex:indexN];
                            if(onelayer.value == value || diff == 0)
                            {
                                layer = onelayer;
                                [layersToRemove removeObject:layer];
                                break;
                            }
                        }
                    }
                }
                
                layer.value = value;
                layer.section = section;
                layer.index = index;

                NDLog(@"MBMLineChart : reloadData[%d,%d]=%d : value = %f",section,index,indexN,value);

                UIColor *color = nil;
                if([_chartDataSource respondsToSelector:@selector(lineChart:colorForLineAtIndex:forSection:)])
                {
                    color = [_chartDataSource lineChart:self colorForLineAtIndex:index forSection:section];
                    [layer setFillColor:[[UIColor clearColor] CGColor]];
                    [layer setStrokeColor:[color CGColor]];
                    [layer setLineWidth:_selectedLineStroke];
                }
                
                if([_chartDataSource respondsToSelector:@selector(lineChart:textForLineAtIndex:forSection:)])
                {
                    //layer.text = [_chartDataSource lineChart:self textForLineAtIndex:index forSection:section];
                    //NDLog(@"MBMLineChart : reloadData #2: layer.text = %@",layer.text);
                }
                
                [self updateLabelForLayer:layer value:value];
                
                if([_chartDataSource respondsToSelector:@selector(lineChart:pointForLineAtIndex:forSection:)])
                {
                    point = [_chartDataSource lineChart:self pointForLineAtIndex:index forSection:section];
                    toScaledPoint = CGPointMake(point.x, self.bounds.size.height-self.paddingBotom-point.y*scaleAxisY);
                    if(index == 0)
                        fromPoint = toScaledPoint;
                }

                fromPath = CGPathCreatePathFromPoint(CGPointMake(fromPoint.x,valueY),CGPointMake(point.x,valueY),_lineRadius,_selectedLineStroke);
                toPath = CGPathCreatePathFromPoint(fromPoint,toScaledPoint,_lineRadius,_selectedLineStroke);
                            
                [layer createLineAnimationForKey:@"point"
                                           fromValue:[NSValue valueWithCGPoint:CGPointMake(point.x,valueY)]
                                             toValue:[NSValue valueWithCGPoint:toScaledPoint]
                                            Delegate:self];
                
                [layer createPathAnimationForKey:@"path"
                                        fromValue:fromPath
                                          toValue:toPath
                                         Delegate:self];
                
                fromPoint = toScaledPoint;
                CFRelease(fromPath);
                CFRelease(toPath);
                
                indexN++;
            }
            [CATransaction commit];

         }//section
                   
        [CATransaction setDisableActions:YES];
        for(LineLayer *layer in layersToRemove)
        {
            [layer setFillColor:[self backgroundColor].CGColor];
            [layer setDelegate:nil];
            [layer setZPosition:0];
            [layer setPath:nil];
            [layer setPoint:CGPointMake(5024,5024)];
            [layer setStrokeColor:[[UIColor clearColor] CGColor]];
            CATextLayer *textLayer = [[layer sublayers] objectAtIndex:0];
            [textLayer setHidden:YES];
        }
        [CATransaction setDisableActions:NO];
        [CATransaction commit];
	}
}

#pragma mark - Animation Delegate + Run Loop Timer

- (void)updateTimerFired:(NSTimer *)timer;
{
    CALayer *parentLayer = [_lineView layer];
    NSArray *lineLayers = [parentLayer sublayers];
    [lineLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGPoint presentationLayerPoint = [[[obj presentationLayer] valueForKey:@"point"] CGPointValue];
		CGPathRef presentationLayerPath = (CGPathRef)[[obj presentationLayer] valueForKey:@"path"];
		//NDLog(@"MBMLineChart : updateTimerFired : path = %@",CGPathIsEmpty(presentationLayerPath)?@"Bad":@"Good");
		//NDLog(@"MBMLineChart : updateTimerFired :  presentationLayerFromPoint : x = %f : y = %f",presentationLayerPoint.x,presentationLayerPoint.y);
		[obj setPath:presentationLayerPath];
        {
            CALayer *labelLayer = [[obj sublayers] objectAtIndex:0];
            //Hide the labelLayer so when the user clicks on it, it becomes visible
			[labelLayer setHidden:YES];
            [CATransaction setDisableActions:YES];
			[labelLayer setPosition:CGPointMake(presentationLayerPoint.x, presentationLayerPoint.y-_lineRadius)];
            [CATransaction setDisableActions:NO];
        }
    }];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    if (_animationTimer == nil) {
        static float timeInterval = 1.0/60.0;
        _animationTimer= [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:YES];
    }
    
    [_animations addObject:anim];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)animationCompleted
{
    [_animations removeObject:anim];
    if ([_animations count] == 0) {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
}

#pragma mark - Touch Handing (Selection Notification)

- (NSDictionary*)getCurrentSelectedOnTouch:(CGPoint)point
{
    __block NSUInteger selectedIndex = -1;
    __block NSUInteger section = -1;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CALayer *parentLayer = [_lineView layer];
    NSArray *lineLayers = [parentLayer sublayers];
    [lineLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        LineLayer *lineLayer = (LineLayer *)obj;
        CGPathRef path = [lineLayer path];
		CGRect pathRect = CGPathGetPathBoundingBox(path);
		//Improve touch detection by determining if point is within path's rectangle
		//otherwise iPhone will not detect touch events very well
        //Additionaly set the touched BOOL if a line has been touched so the
        //next touch event will go to the next line
		BOOL withInRect = CGRectContainsPoint(pathRect,point);
        BOOL lineTouched = [lineLayer touched];
        if (!lineTouched && (CGPathContainsPoint(path, &transform, point, 0) || withInRect))
        {
            [lineLayer setLineWidth:_selectedLineStroke];
            [lineLayer setLineJoin:kCALineJoinRound];
            [lineLayer setZPosition:MAXFLOAT];
            [lineLayer setTouched:YES];
            selectedIndex = idx;
            section = lineLayer.section;
            *stop = YES;
        } else {
            [lineLayer setZPosition:kDefaultLineZOrder];
            [lineLayer setTouched:NO];
        }
    }];
    NSUInteger row = selectedIndex - (numberOfElements * section);
    NDLog(@"MBMLineChart : getCurrentSelectedOnTouch[%d,%d] : newSelectedIndex = %d",section,selectedIndex,row);
    NSDictionary *selectedDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:section],@"SEC",[NSNumber numberWithInteger:selectedIndex],@"INDEX",[NSNumber numberWithInteger:row],@"ROW",nil];
    return selectedDic;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_lineView];
    NSDictionary *selectedDic = [self getCurrentSelectedOnTouch:point];
    NSUInteger selectedIndex = [[selectedDic objectForKey:@"INDEX"] integerValue];
    NSUInteger section = [[selectedDic objectForKey:@"SEC"] integerValue];
    NSUInteger row = [[selectedDic objectForKey:@"ROW"] integerValue];
    [self notifyDelegateOfSelectionChangeFrom:_selectedLineIndex to:selectedIndex forSection:section andRow:row];
    [self touchesCancelled:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    CALayer *parentLayer = [_lineView layer];
    NSArray *lineLayers = [parentLayer sublayers];

    for (LineLayer *lineLayer in lineLayers) {
		if(![lineLayer isSelected])
			[lineLayer setZPosition:kDefaultLineZOrder];
    }
}

#pragma mark - Selection Notification

- (void)notifyDelegateOfSelectionChangeFrom:(NSUInteger)previousSelection to:(NSUInteger)newSelection forSection:(NSUInteger)section andRow:(NSUInteger)row
{
    NDLog(@"MBMLineChart : notifyDelegateOfSelectionChangeFrom : section = %d : newSelection = %d : row = %d",section,newSelection,row);
    if (previousSelection != newSelection)
    {
        if (previousSelection != -1 && [_chartDelegate respondsToSelector:@selector(lineChart:willDeselectLineAtIndex:)])
        {
            [_chartDelegate lineChart:self willDeselectLineAtIndex:previousSelection forSection:section];
        }
        
        _selectedLineIndex = newSelection;
        
        if (newSelection != -1)
        {
            if([_chartDelegate respondsToSelector:@selector(lineChart:willSelectLineAtIndex:forSection:)])
                [_chartDelegate lineChart:self willSelectLineAtIndex:row forSection:section];
            if(previousSelection != -1 && [_chartDelegate respondsToSelector:@selector(lineChart:didDeselectLineAtIndex:forSection:)])
                [_chartDelegate lineChart:self didDeselectLineAtIndex:previousSelection forSection:section];
            if([_chartDelegate respondsToSelector:@selector(lineChart:didSelectLineAtIndex:forSection:)])
                [_chartDelegate lineChart:self didSelectLineAtIndex:row forSection:section];
            [self setLineSelectedAtIndex:newSelection];
        }
        
        if(previousSelection != -1)
        {
            [self setLineDeselectedAtIndex:previousSelection];
            if([_chartDelegate respondsToSelector:@selector(lineChart:didDeselectLineAtIndex:forSection:)])
                [_chartDelegate lineChart:self didDeselectLineAtIndex:previousSelection forSection:section];
        }
    }
    else if (newSelection != -1)
    {
        LineLayer *layer = [_lineView.layer.sublayers objectAtIndex:newSelection];
        if(layer){
            
            if (layer.isSelected) {
                if ([_chartDelegate respondsToSelector:@selector(lineChart:willDeselectLineAtIndex:forSection:)])
                    [_chartDelegate lineChart:self willDeselectLineAtIndex:row forSection:section];
                [self setLineDeselectedAtIndex:newSelection];
                if (row != -1 && [_chartDelegate respondsToSelector:@selector(lineChart:didDeselectLineAtIndex:forSection:)])
                    [_chartDelegate lineChart:self didDeselectLineAtIndex:row forSection:section];
            }
            else {
                if ([_chartDelegate respondsToSelector:@selector(lineChart:willSelectLineAtIndex:forSection:)])
                    [_chartDelegate lineChart:self willSelectLineAtIndex:row forSection:section];
                [self setLineSelectedAtIndex:newSelection];
                if (row != -1 && [_chartDelegate respondsToSelector:@selector(lineChart:didSelectLineAtIndex:forSection:)])
                    [_chartDelegate lineChart:self didSelectLineAtIndex:row forSection:section];
            }
        }
    }
}

#pragma mark - Line Layer Creation Method

- (LineLayer *)createLineLayer
{
	NDLog(@"MBMLineChart : createLineLayer ");
    LineLayer *lineLayer = [LineLayer layer];
	
	[lineLayer setPath:nil];
    [lineLayer setZPosition:0];
    [lineLayer setStrokeColor:NULL];
    CATextLayer *textLayer = [CATextLayer layer];
	[textLayer setHidden:YES];
    textLayer.contentsScale = [[UIScreen mainScreen] scale];
    CGFontRef font = CGFontCreateWithFontName((CFStringRef)[self.labelFont fontName]);
    [textLayer setFont:font];
    CFRelease(font);
    [textLayer setFontSize:self.labelFont.pointSize];
    [textLayer setAnchorPoint:CGPointMake(0.5,1.0)];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [textLayer setForegroundColor:self.labelColor.CGColor];
    if (self.labelShadowColor) {
        [textLayer setShadowColor:self.labelShadowColor.CGColor];
        [textLayer setShadowOffset:CGSizeZero];
        [textLayer setShadowOpacity:1.0f];
        [textLayer setShadowRadius:2.0f];
    }
    CGSize size = [@"0" sizeWithFont:self.labelFont];
    [CATransaction setDisableActions:YES];
    [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
	[CATransaction setDisableActions:NO];
    [lineLayer insertSublayer:textLayer atIndex:0];
    return lineLayer;
}

- (void)updateLabelForLayer:(LineLayer *)lineLayer value:(CGFloat)value
{
    CATextLayer *textLayer = [[lineLayer sublayers] objectAtIndex:0];
    if(!_showLabel) return;
	NSString *label = (lineLayer.text)?lineLayer.text:[NSString stringWithFormat:@"%0.0f", value];
    CGSize size = [label sizeWithFont:self.labelFont];
    [CATransaction setDisableActions:YES];
	[textLayer setString:label];
	[textLayer setBounds:CGRectMake(0, 0, size.width, size.height)];
    [CATransaction setDisableActions:NO];
}

- (void) calculateChartFrame
{
	stepWidthAxisY = chartRect.size.width/STROKE_AXIS_Y_SCALE;
	labelSizeAxisY = CGSizeMake(50, 30);
	
	CGSize maxStringSize = [[NSString stringWithFormat:@"%i", (int)maxValue] sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_IPHONE]];
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
		[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		maxStringSize = [[NSString stringWithFormat:@"%i", (int)maxValue] sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_IPAD]];
	if (showAxisY)
		leftPadding = chartRect.size.width/STROKE_AXIS_Y_SCALE + maxStringSize.width;
	else
		leftPadding = 0.0f;
	
	barInterval = ((chartRect.size.width - leftPadding - labelSizeAxisY.width) / numberOfElements) * 0.20;
	barWidth = ((chartRect.size.width - leftPadding - labelSizeAxisY.width) / numberOfElements) * 0.80;
	NDLog(@"MBMLineChart : calculateChartFrame : barWidth = %f : barInterval = %f : leftPadding = %f ",barWidth,barInterval,leftPadding);
}

- (void)drawChart:(NSMutableArray*)lineDicArray
{
	[self setLineDicArray:lineDicArray];
	[self setMaxValueAxisY:0];
	[self setMinValueAxisY:0];
    for (int section = 0; section < [self.lineDicArray count]; section++) {
        for (NSDictionary *barDic in [_lineDicArray objectAtIndex:section])
        {
            CGFloat barValue = [[barDic objectForKey:@"LineValue"] floatValue];
            if(barValue > maxValueAxisY)
                [self setMaxValueAxisY:barValue];
            
            if(barValue < minValueAxisY)
                [self setMinValueAxisY:barValue];
        }
    }
	float range = maxValueAxisY - minValueAxisY;
	float exponent = floor(log10f(range));
	float base = pow(10, (exponent - 1));
	[self setMaxValueAxisY:(ceilf(range / base) * base)];
	NDLog(@"MBMLineChart : drawChart : maxValueAxisY = %f ",maxValueAxisY);
	NDLog(@"MBMLineChart : drawChart : maxValueAxisY = %f ",minValueAxisY);
	double height = self.frame.size.height;
	[self setScaleAxisY:((height - paddingTop - paddingBotom) / maxValueAxisY)];
	NDLog(@"MBMLineChart : drawChart : scaleAxisY = %f ",scaleAxisY);	
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	NDLog(@"MBMLineChart : drawRect ");
	CGContextRef context = UIGraphicsGetCurrentContext();
	rect = CGRectMake(0.0f, paddingTop, rect.size.width, rect.size.height - paddingTop - paddingBotom);
	CGFloat leftPaddingAxisY = stepWidthAxisY + labelSizeAxisY.width;
	NSUInteger stepCountAxisY = maxValueAxisY/stepValueAxisY;
	CGFloat stepHeightAxisY = rect.size.height/stepCountAxisY;
	
	barFullWidth = (rect.size.width - leftPaddingAxisY)/numberOfElements;
	
	CGContextSetLineWidth(context, 1.0f);
	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHexRGB:@"e8ebee" AndAlpha:1.0] CGColor]);
	
	for (NSUInteger i = 0; i < stepCountAxisY; i++)
	{
		if (i % 2)
		{
			CGContextSetFillColorWithColor(context, [[UIColor colorWithHexRGB:@"e8ebee" AndAlpha:1.0] CGColor]);
		}
		else
		{
			CGContextSetFillColorWithColor(context, [[UIColor colorWithHexRGB:@"e3e5e7" AndAlpha:1.0] CGColor]);
		}
		
		CGContextBeginPath(context);
		CGContextAddRect(context, CGRectMake(CGRectGetMinX(rect) + leftPaddingAxisY,  CGRectGetMinY(rect) + i*stepHeightAxisY, CGRectGetMaxX(rect) + leftPaddingAxisY, stepHeightAxisY));
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathFill);
	}
	
	CGContextSetFillColorWithColor(context, [colorAxisY CGColor]);
	CGContextSetStrokeColorWithColor(context, [colorAxisY CGColor]);
	
	if (!CGSizeEqualToSize(labelSizeAxisY, CGSizeZero))
	{
		for (NSUInteger i = 0; i <= stepCountAxisY; i++)
		{
			NSString *textX = [NSString stringWithFormat:@"%i",(NSUInteger)(maxValueAxisY - i*stepValueAxisY)];
			CGRect textRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + i*stepHeightAxisY - labelSizeAxisY.height/2, labelSizeAxisY.width, labelSizeAxisY.height);
			
			[textX drawInRect:textRect withFont:[UIFont systemFontOfSize:fontSize] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
			
			CGContextBeginPath(context);
			CGContextMoveToPoint(context, CGRectGetMinX(rect) + labelSizeAxisY.width, CGRectGetMinY(rect) + i*stepHeightAxisY);
			CGContextAddLineToPoint(context, CGRectGetMinX(rect) + leftPaddingAxisY, CGRectGetMinY(rect) + i*stepHeightAxisY);
			CGContextClosePath(context);
			CGContextDrawPath(context, kCGPathStroke);
		}
	}
	
	if (plotVerticalLines)
	{
		CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHexRGB:@"dadadb" AndAlpha:1.0] CGColor]);
        CGFloat xPos = self.leftPadding + self.labelSizeAxisY.width + self.barWidth/2;
        for (NSUInteger i = 1; i <= numberOfElements; i++)
		{
			CGContextBeginPath(context);
			CGContextMoveToPoint(context, xPos, CGRectGetMinY(rect));
			CGContextAddLineToPoint(context, xPos, CGRectGetMaxY(rect));
			xPos = xPos + self.barWidth + self.barInterval;
			CGContextClosePath(context);
			CGContextDrawPath(context, kCGPathStroke);
		}
	}
	
	if (addHorizontalLabels)
	{
		CGFloat xPos = self.leftPadding + self.labelSizeAxisY.width;
		for (NSDictionary *barDic in [_lineDicArray objectAtIndex:0])
		{
			NSString *barLabel = [NSString stringWithFormat:@"%@",[barDic objectForKey:@"LineLabel"]];
			UIColor *barLabelColor = (UIColor*)[barDic objectForKey:@"LabelColor"];
			CGFloat offset = (self.barWidth - labelSizeAxisY.width)/2;
			CGRect barLabelRect = CGRectMake(xPos+offset, rect.size.height+paddingBotom, labelSizeAxisY.width, labelSizeAxisY.height);
			xPos = xPos + self.barWidth + self.barInterval;
			CGContextSetFillColorWithColor(context, barLabelColor.CGColor);
			[barLabel drawInRect:barLabelRect withFont:[UIFont systemFontOfSize:barLabelFontSize] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
		}
	}
	
	CGContextSetStrokeColorWithColor(context, [colorAxis CGColor]);
	CGContextStrokeRect(context, CGRectMake(CGRectGetMinX(rect) + leftPaddingAxisY,  CGRectGetMinY(rect), CGRectGetMaxX(rect) - leftPaddingAxisY - 1.0f, rect.size.height));
}

- (void)dealloc {
    [_labelFont release];
	[_labelColor release];
	[_labelShadowColor release];
    [_lineDicArray release];
	[colorAxisY release];
	[colorAxis release];
	[super dealloc];
}

@end
