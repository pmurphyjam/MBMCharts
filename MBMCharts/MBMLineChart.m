//
//  MBMLineChart.m
//  MBMCharts
//
//  Created by Pat Murphy on 12/14/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import "MBMLineChart.h"
#import "UIColorCategory.h"
#import "MBMChartDefines.h"
#import <QuartzCore/QuartzCore.h>
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface LineLayer : CAShapeLayer
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, retain) NSString *text;
- (void)createLineAnimationForKey:(NSString *)key fromValue:(NSValue *)from toValue:(NSValue *)to Delegate:(id)delegate;
- (void)createPathAnimationForKey:(NSString *)key fromValue:(CGPathRef)from toValue:(CGPathRef)to Delegate:(id)delegate;
@end

@implementation LineLayer
@synthesize text = _text;
@synthesize value = _value;
@synthesize point = _point;
@synthesize isSelected = _isSelected;

- (NSString*)description
{
    return [NSString stringWithFormat:@"value:%f, Point X:%f, Y:%f", _value, _point.x, _point.y];
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
- (void)notifyDelegateOfSelectionChangeFrom:(NSUInteger)previousSelection to:(NSUInteger)newSelection;
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

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize linePoint = _linePoint;
@synthesize animationSpeed = _animationSpeed;
@synthesize lineHeight = _lineHeight;
@synthesize lineRadius = _lineRadius;
@synthesize numberOfLines = _numberOfLines;
@synthesize showLabel = _showLabel;
@synthesize lineAnimationType = _lineAnimationType;
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

static CGPathRef CGPathCreateCircle(CGPoint point, CGFloat radius)
{
    NDLog(@"MBMLineChart : CGPathCreateCircle : Point : x = %f : y = %f : r = %f ",point.x,point.y,radius);
    CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddArc(path, NULL, point.x, point.y, radius, 0, 2 * M_PI, 0);
    CGPathCloseSubpath(path);
    return path;
}

static NSDictionary* trigMethod(CGPoint fromPoint, CGPoint toPoint ,CGFloat radius)
{
	CGPoint shorterToPoint = CGPointMake(toPoint.x, toPoint.y);
	//Do some Trig
	CGFloat dx = (toPoint.x - fromPoint.x);
    CGFloat dy = (toPoint.y - fromPoint.y);
	CGFloat hyp = sqrtf((dx * dx) + (dy * dy));
	CGFloat angle = 0;
	if(hyp > 0)
		angle = atan2f(dy, dx);
	
	CGFloat obs = sinf(angle)*(hyp - radius);
	CGFloat newY = fromPoint.y + obs;
	CGFloat adj = cosf(angle)*(hyp - radius);
	CGFloat newX = fromPoint.x + adj;
	
	if(hyp > 0)
	{
		shorterToPoint = CGPointMake(newX, newY);
	}

	NSDictionary *trigDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGPoint:shorterToPoint],@"NewPoint",[NSNumber  numberWithFloat:angle],@"Angle", nil];
	
	return trigDic;
}

static CGPathRef CGPathCreatePathFromPoints(NSMutableArray *points, CGFloat radius)
{
    NDLog(@"MBMLineChart : CGPathCreatePathFromPoints : points = %@ ",points);
    CGMutablePathRef path = CGPathCreateMutable();
	int index = 0;
    for(NSValue *lineValue in points)
    {
		CGPoint point = [lineValue  CGPointValue];
		if(index == 0)
			CGPathMoveToPoint(path, NULL, point.x, point.y);
		else
		{
			CGPathAddLineToPoint(path, NULL, point.x,point.y);

		}
		//NDLog(@"MBMLineChart : CGPathCreatePathFromPoints : point[%d] : x = %f : y = %f",index,point.x,point.y);
		index++;
    }
	return path;
}

static CGPathRef CGPathCreatePathFromPoint(CGPoint fromPoint, CGPoint toPoint, CGFloat radius)
{
    NDLog(@"MBMLineChart : CGPathCreatePathFromPoint : fromPoint : x = %f : y = %f : toPoint : x = %f : y = %f  ",fromPoint.x,fromPoint.y,toPoint.x,toPoint.y);
	NSDictionary *trigDic = trigMethod(fromPoint,toPoint,radius);
	NDLog(@"MBMLineChart : CGPathCreatePathFromPoint : trigDic = %@ ",trigDic);
	CGFloat angle = [[trigDic objectForKey:@"Angle"] floatValue];
	CGPoint shorterToPoint = [[trigDic objectForKey:@"NewPoint"] CGPointValue];
    CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRelativeArc(path, NULL, fromPoint.x, fromPoint.y, radius, angle, 2 * M_PI);
	CGPathAddLineToPoint(path, NULL, shorterToPoint.x,shorterToPoint.y);
	return path;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
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
        _selectedLineStroke = 3.0;
		if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
			[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		{
			fontSize = FONT_SIZE_IPAD;
			barLabelFontSize = BAR_LABEL_FONT_SIZE_IPAD;
			stepValueAxisY = STEP_AXIS_Y_IPAD;
		}
		else
		{
			fontSize = FONT_SIZE_IPHONE;
			barLabelFontSize = BAR_LABEL_FONT_SIZE_IPHONE;
			stepValueAxisY = STEP_AXIS_Y_IPHONE;
		}
		paddingTop = PLOT_PADDING_TOP;
		paddingBotom = PLOT_PADDING_BOTTOM;
		self.lineRadius = LINE_CHART_POINT_RADIUS;
		self.linePoint = CGPointMake(frame.origin.x, frame.origin.y);
        self.lineHeight = MIN(frame.size.width/2, frame.size.height/2) - 10;
        self.numberOfLines = 2;
        self.labelFont = [UIFont boldSystemFontOfSize:MAX((int)10, 5)];
        _labelColor = [UIColor whiteColor];
        _labelShadowColor = [UIColor clearColor];
		colorAxisY = [UIColor blackColor];
		colorAxis = [UIColor blackColor];
        _showLabel = YES;
		_lineAnimationType = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
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
        _selectedLineStroke = 3.0;
		if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
			[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		{
			fontSize = FONT_SIZE_IPAD;
			barLabelFontSize = BAR_LABEL_FONT_SIZE_IPAD;
			stepValueAxisY = STEP_AXIS_Y_IPAD;
		}
		else
		{
			fontSize = FONT_SIZE_IPHONE;
			barLabelFontSize = BAR_LABEL_FONT_SIZE_IPHONE;
			stepValueAxisY = STEP_AXIS_Y_IPHONE;
		}
		paddingTop = PLOT_PADDING_TOP;
		paddingBotom = PLOT_PADDING_BOTTOM;
		self.lineRadius = LINE_CHART_POINT_RADIUS;
		chartRect = self.bounds;
		CGRect bounds = [[self layer] bounds];
		self.linePoint = CGPointMake(bounds.origin.x, bounds.origin.y);
        self.lineHeight = MIN(bounds.size.width/2, bounds.size.height/2) - 10;
        self.numberOfLines = 2;
        self.labelFont = [UIFont boldSystemFontOfSize:MAX((int)10, 5)];
        _labelColor = [UIColor whiteColor];
		_labelShadowColor = [UIColor clearColor];
		colorAxisY = [UIColor blackColor];
		colorAxis = [UIColor blackColor];
        _showLabel = YES;
		_lineAnimationType = NO;
    }
    return self;
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
		[labelLayer setHidden:YES];
        layer.position = CGPointMake(0, 0);
        layer.isSelected = NO;
    }
}

#pragma mark - Line Reload Data With Animation

- (void)reloadData
{
    if (_dataSource && !_animationTimer)
    {
		CALayer *parentLayer = [_lineView layer];
        NSArray *lineLayers = [parentLayer sublayers];
		NDLog(@"MBMLineChart : reloadData : lineLayers cnt = %d",[lineLayers count]);
		
        _selectedLineIndex = -1;
        [lineLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LineLayer *layer = (LineLayer *)obj;
            if(layer.isSelected)
                [self setLineDeselectedAtIndex:idx];
        }];
        
		NSUInteger lineCount = [_dataSource numberOfLinesInChart:self];
		NDLog(@"MBMLineChart : reloadData : lineCount = %d",lineCount);
		
		double values[lineCount];
		
		for (int index = 0; index < lineCount; index++) {
            values[index] = [_dataSource lineChart:self valueForLineAtIndex:index];
        }
		
        [CATransaction begin];
        [CATransaction setAnimationDuration:_animationSpeed];
        
        [_lineView setUserInteractionEnabled:NO];
        
		NSMutableArray *layersToRemove = [[NSMutableArray alloc] init];
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
        
        layersToRemove = [NSMutableArray arrayWithArray:lineLayers];
		
        NSInteger diff = lineCount - [lineLayers count];
        CGPoint point = CGPointMake(0, 0);
		CGPoint fromPoint = CGPointMake(0, 0);
        CGPoint toScaledPoint = CGPointMake(0, 0);
		CGFloat valueY = self.bounds.size.height-self.paddingBotom;
		NSMutableArray *fromLineArray = [[NSMutableArray alloc] init];
		NSMutableArray *toLineArray = [[NSMutableArray alloc] init];
		
		CGPathRef fromPath = nil;
		CGPathRef toPath = nil;
		
		if(!_lineAnimationType)
		{
			for (NSDictionary *lineDic in _lineDicArray)
			{
				CGPoint linePoint = [[lineDic objectForKey:@"LinePoint"] CGPointValue];
				NSValue *fromScaledValue = [NSValue valueWithCGPoint:CGPointMake(linePoint.x, self.bounds.size.height-self.paddingBotom)];
				NSValue *toScaledValue = [NSValue valueWithCGPoint:CGPointMake(linePoint.x, self.bounds.size.height-self.paddingBotom-linePoint.y*scaleAxisY)];
				[toLineArray addObject:toScaledValue];
				[fromLineArray addObject:fromScaledValue];
			}
			//Path along the bottom X axis of the graph
			fromPath = CGPathCreatePathFromPoints(fromLineArray,_lineRadius);
			//Path along the points of the graph
			toPath = CGPathCreatePathFromPoints(toLineArray,_lineRadius);
			[fromLineArray release];
			[toLineArray release];
		}
		
		for(int index = 0; index < lineCount; index ++)
		{
			LineLayer *layer;
			
			if( index >= [lineLayers count] )
            {
                layer = [self createLineLayer];
                [parentLayer addSublayer:layer];
                diff--;
            }
			else
            {
                LineLayer *onelayer = [lineLayers objectAtIndex:index];
				if(diff == 0 || onelayer.value == (CGFloat)values[index])
                {
                    layer = onelayer;
                    [layersToRemove removeObject:layer];
                }
				else if(diff > 0)
                {
                    layer = [self createLineLayer];
                    [parentLayer insertSublayer:layer atIndex:index];
                    diff--;
                }
				else if(diff < 0)
                {
					while(diff < 0)
                    {
                        [onelayer removeFromSuperlayer];
                        [parentLayer addSublayer:onelayer];
                        diff++;
                        onelayer = [lineLayers objectAtIndex:index];
                        if(onelayer.value == (CGFloat)values[index] || diff == 0)
                        {
                            layer = onelayer;
                            [layersToRemove removeObject:layer];
                            break;
                        }
                    }
					
				}
				
			}
			
			layer.value = values[index];
			
			UIColor *color = nil;
			if([_dataSource respondsToSelector:@selector(lineChart:colorForLineAtIndex:)])
			{
				color = [_dataSource lineChart:self colorForLineAtIndex:index];
				[layer setFillColor:[[UIColor clearColor] CGColor]];
                [layer setStrokeColor:[color CGColor]];
                [layer setLineWidth:_selectedLineStroke];
			}
			
			if([_dataSource respondsToSelector:@selector(lineChart:textForLineAtIndex:)])
            {
                //layer.text = [_dataSource lineChart:self textForLineAtIndex:index];
				//NDLog(@"MBMLineChart : reloadData #2: layer.text = %@",layer.text);
            }
			
            [self updateLabelForLayer:layer value:values[index]];
			
			if([_dataSource respondsToSelector:@selector(lineChart:pointForLineAtIndex:)])
			{
				point = [_dataSource lineChart:self pointForLineAtIndex:index];
                NDLog(@"MBMLineChart : reloadData : point : x = %f : y = %f",point.x,point.y);
				toScaledPoint = CGPointMake(point.x, self.bounds.size.height-self.paddingBotom-point.y*scaleAxisY);
				if(index == 0)
                    fromPoint = toScaledPoint;
			}

			if(_lineAnimationType)
			{
				fromPath = CGPathCreatePathFromPoint(CGPointMake(fromPoint.x,valueY),CGPointMake(point.x,valueY),_lineRadius);
				toPath = CGPathCreatePathFromPoint(fromPoint,toScaledPoint,_lineRadius);
			}
			else
			{
				
				[layer createLineAnimationForKey:@"point"
									   fromValue:[NSValue valueWithCGPoint:CGPointMake(point.x,valueY)]
										 toValue:[NSValue valueWithCGPoint:toScaledPoint]
										Delegate:self];
			}
			[layer createPathAnimationForKey:@"path"
									fromValue:fromPath
									  toValue:toPath
									 Delegate:self];
			
			fromPoint = toScaledPoint;

			if(_lineAnimationType)
			{
				CFRelease(fromPath);
				CFRelease(toPath);
			}

		}
		if(!_lineAnimationType)
		{
			CFRelease(fromPath);
			CFRelease(toPath);
		}
		
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
		NDLog(@"MBMLineChart : updateTimerFired : path = %@",CGPathIsEmpty(presentationLayerPath)?@"Bad":@"Good");
		NDLog(@"MBMLineChart : updateTimerFired :  presentationLayerFromPoint : x = %f : y = %f",presentationLayerPoint.x,presentationLayerPoint.y);
		CGPathRef path = CGPathCreateCircle(presentationLayerPoint, _lineRadius);
		CGMutablePathRef combinedPath = CGPathCreateMutableCopy(path);
		CGPathAddPath(combinedPath,NULL,presentationLayerPath);
        [obj setPath:combinedPath];
        {
            CALayer *labelLayer = [[obj sublayers] objectAtIndex:0];
            //Hide the labelLayer so when the user clicks on it, it becomes visible
			[labelLayer setHidden:YES];
            [CATransaction setDisableActions:YES];
			[labelLayer setPosition:CGPointMake(presentationLayerPoint.x, presentationLayerPoint.y-_lineRadius)];
            [CATransaction setDisableActions:NO];
        }
        CFRelease(path);
		CFRelease(combinedPath);
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

- (NSInteger)getCurrentSelectedOnTouch:(CGPoint)point
{
    __block NSUInteger selectedIndex = -1;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CALayer *parentLayer = [_lineView layer];
    NSArray *lineLayers = [parentLayer sublayers];
    
    [lineLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        LineLayer *lineLayer = (LineLayer *)obj;
        CGPathRef path = [lineLayer path];
        
        if (CGPathContainsPoint(path, &transform, point, 0)) {
            [lineLayer setLineWidth:_selectedLineStroke];
            [lineLayer setLineJoin:kCALineJoinRound];
            [lineLayer setZPosition:MAXFLOAT];
            selectedIndex = idx;
        } else {
            [lineLayer setZPosition:kDefaultLineZOrder];
        }
    }];
    return selectedIndex;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_lineView];
    [self getCurrentSelectedOnTouch:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_lineView];
    NSInteger selectedIndex = [self getCurrentSelectedOnTouch:point];
    [self notifyDelegateOfSelectionChangeFrom:_selectedLineIndex to:selectedIndex];
    [self touchesCancelled:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    CALayer *parentLayer = [_lineView layer];
    NSArray *lineLayers = [parentLayer sublayers];
    
    for (LineLayer *lineLayer in lineLayers) {
        [lineLayer setZPosition:kDefaultLineZOrder];
    }
}

#pragma mark - Selection Notification

- (void)notifyDelegateOfSelectionChangeFrom:(NSUInteger)previousSelection to:(NSUInteger)newSelection
{
    if (previousSelection != newSelection)
    {
        if (previousSelection != -1 && [_delegate respondsToSelector:@selector(lineChart:willDeselectLineAtIndex:)])
        {
            [_delegate lineChart:self willDeselectLineAtIndex:previousSelection];
        }
        
        _selectedLineIndex = newSelection;
        
        if (newSelection != -1)
        {
            if([_delegate respondsToSelector:@selector(lineChart:willSelectLineAtIndex:)])
                [_delegate lineChart:self willSelectLineAtIndex:newSelection];
            if(previousSelection != -1 && [_delegate respondsToSelector:@selector(lineChart:didDeselectLineAtIndex:)])
                [_delegate lineChart:self didDeselectLineAtIndex:previousSelection];
            if([_delegate respondsToSelector:@selector(lineChart:didSelectLineAtIndex:)])
                [_delegate lineChart:self didSelectLineAtIndex:newSelection];
            [self setLineSelectedAtIndex:newSelection];
        }
        
        if(previousSelection != -1)
        {
            [self setLineDeselectedAtIndex:previousSelection];
            if([_delegate respondsToSelector:@selector(lineChart:didDeselectLineAtIndex:)])
                [_delegate lineChart:self didDeselectLineAtIndex:previousSelection];
        }
    }
    else if (newSelection != -1)
    {
        LineLayer *layer = [_lineView.layer.sublayers objectAtIndex:newSelection];
        if(layer){
            
            if (layer.isSelected) {
                if ([_delegate respondsToSelector:@selector(lineChart:willDeselectLineAtIndex:)])
                    [_delegate lineChart:self willDeselectLineAtIndex:newSelection];
                [self setLineDeselectedAtIndex:newSelection];
                if (newSelection != -1 && [_delegate respondsToSelector:@selector(lineChart:didDeselectLineAtIndex:)])
                    [_delegate lineChart:self didDeselectLineAtIndex:newSelection];
            }
            else {
                if ([_delegate respondsToSelector:@selector(lineChart:willSelectLineAtIndex:)])
                    [_delegate lineChart:self willSelectLineAtIndex:newSelection];
                [self setLineSelectedAtIndex:newSelection];
                if (newSelection != -1 && [_delegate respondsToSelector:@selector(lineChart:didSelectLineAtIndex:)])
                    [_delegate lineChart:self didSelectLineAtIndex:newSelection];
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
	
	for (NSDictionary *barDic in _lineDicArray)
	{
		CGFloat barValue = [[barDic objectForKey:@"LineValue"] floatValue];
		if(barValue > maxValueAxisY)
			[self setMaxValueAxisY:barValue];
		
		if(barValue < minValueAxisY)
			[self setMinValueAxisY:barValue];
		
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
		for (NSUInteger i = 1; i <= numberOfElements; i++)
		{
			CGContextBeginPath(context);
			CGContextMoveToPoint(context, CGRectGetMinX(rect) + leftPaddingAxisY + (barFullWidth/2)*(2*i - 1), CGRectGetMinY(rect));
			CGContextAddLineToPoint(context, CGRectGetMinX(rect) + leftPaddingAxisY + (barFullWidth/2)*(2*i - 1), CGRectGetMaxY(rect));
			CGContextClosePath(context);
			CGContextDrawPath(context, kCGPathStroke);
		}
	}
	
	if (addHorizontalLabels)
	{
		CGFloat xPos = self.leftPadding + self.labelSizeAxisY.width;
		for (NSDictionary *barDic in _lineDicArray)
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
