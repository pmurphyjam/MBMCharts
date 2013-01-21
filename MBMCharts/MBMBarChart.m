//
//  MBMBarChart.m
//  MBMCharts
//
//  Created by Pat Murphy on 12/13/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#import "MBMBarChart.h"
#import "UIColorCategory.h"
#import "MBMChartDefines.h"
#import <QuartzCore/QuartzCore.h>
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface BarLayer : CAShapeLayer
@property (nonatomic, assign) CGFloat   value;
@property (nonatomic, assign) CGRect    barRect;
@property (nonatomic, assign) CGPoint   point;
@property (nonatomic, assign) BOOL      isSelected;
@property (nonatomic, retain) NSString  *text;

- (void)createBarAnimationForKey:(NSString *)key fromValue:(NSValue*)fromRectValue toValue:(NSValue*)toRectValue Delegate:(id)delegate;
@end

@implementation BarLayer
@synthesize text = _text;
@synthesize value = _value;
@synthesize barRect = _barRect;
@synthesize point = _point;
@synthesize isSelected = _isSelected;

- (NSString*)description
{
    return [NSString stringWithFormat:@"value:%f, x:%f, y:%f, w:%f, h:%f", _value, _barRect.origin.x, _barRect.origin.y, _barRect.size.width, _barRect.size.height];
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"barRect"]) {
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
        if ([layer isKindOfClass:[BarLayer class]]) {
            self.barRect = [(BarLayer *)layer barRect];
        }
    }
    return self;
}

- (void)createBarAnimationForKey:(NSString *)key fromValue:(NSValue*)fromRectValue toValue:(NSValue*)toRectValue Delegate:(id)delegate
{
    CABasicAnimation *barAnimation = [CABasicAnimation animationWithKeyPath:key];
    CGRect currentRect = [[[self presentationLayer] valueForKey:key] CGRectValue];
    CGRect fromRect = [fromRectValue CGRectValue];
    if(!currentRect.size.width == 0) currentRect = fromRect;
    [barAnimation setFromValue:[NSValue valueWithCGRect:currentRect]];
    [barAnimation setToValue:toRectValue];
    [barAnimation setDelegate:delegate];
    [barAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self addAnimation:barAnimation forKey:key];
    [self setValue:toRectValue forKey:key];
}

- (void)dealloc {
	[_text release];
	[super dealloc];
}

@end


@interface MBMBarChart (Private)
- (void)updateTimerFired:(NSTimer *)timer;
- (BarLayer *)createBarLayer;
- (CGSize)sizeThatFitsString:(NSString *)string;
- (void)updateLabelForLayer:(BarLayer *)barLayer value:(CGFloat)value;
- (void)notifyDelegateOfSelectionChangeFrom:(NSUInteger)previousSelection to:(NSUInteger)newSelection;
@end

@implementation MBMBarChart
{
	NSInteger _selectedBarIndex;
	//bar view, contains all bars in the graph
	UIView  *_barView;
	//animation control
	NSTimer *_animationTimer;
	NSMutableArray *_animations;
}

static NSUInteger kDefaultBarZOrder = 100;

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize barRect = _barRect;
@synthesize barPoint = _barPoint;
@synthesize animationSpeed = _animationSpeed;
@synthesize numberOfBars = _numberOfBars;
@synthesize showLabel = _showLabel;
@synthesize labelFont = _labelFont;
@synthesize valueColor = _valueColor;
@synthesize valueShadowColor = _valueShadowColor;
@synthesize selectedBarStroke = _selectedBarStroke;
@synthesize barDicArray = _barDicArray;
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

static CGPathRef CGPathCreateBar(CGRect barRect)
{
    NDLog(@"MBMBarChart : CGPathCreateBar");
    CGMutablePathRef path = CGPathCreateMutable();
	CGFloat radius = 4.0;
	CGPathMoveToPoint(path, NULL, CGRectGetMidX(barRect), CGRectGetMinY(barRect));
	//Top Right
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(barRect), CGRectGetMinY(barRect), CGRectGetMaxX(barRect), CGRectGetMaxY(barRect), radius);
	CGPathAddLineToPoint(path, NULL,CGRectGetMaxX(barRect), CGRectGetMaxY(barRect) );
	CGPathAddLineToPoint(path, NULL,CGRectGetMinX(barRect), CGRectGetMaxY(barRect) );
	//Top Left
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(barRect), CGRectGetMinY(barRect), CGRectGetMaxX(barRect), CGRectGetMinY(barRect), radius);	
    CGPathCloseSubpath(path);
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
        _barView = [[UIView alloc] initWithFrame:frame];
        [_barView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_barView];
		_selectedBarIndex = -1;
        _animations = [[NSMutableArray alloc] init];
        _animationSpeed = 0.5;
        _selectedBarStroke = 3.0;
		if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
			[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		{
			fontSize = FONT_SIZE_IPAD;
			barLabelFontSize = BAR_LABEL_FONT_SIZE_IPAD;
			stepValueAxisY = STEP_AXIS_Y_IPAD;
			self.labelFont = [UIFont boldSystemFontOfSize:15];
		}
		else
		{
			fontSize = FONT_SIZE_IPHONE;
			barLabelFontSize = BAR_LABEL_FONT_SIZE_IPHONE;
			stepValueAxisY = STEP_AXIS_Y_IPHONE;
			self.labelFont = [UIFont boldSystemFontOfSize:10];
		}
		paddingTop = PLOT_PADDING_TOP;
		paddingBotom = PLOT_PADDING_BOTTOM;
        self.barRect = frame;
		self.barPoint = CGPointMake(frame.origin.x, frame.origin.y);
        _valueColor = [UIColor blackColor];
		_valueShadowColor = [UIColor clearColor];
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
        [self setAutoresizesSubviews:YES];
        [self setClipsToBounds:YES];
        [self setClearsContextBeforeDrawing:YES];
        self.backgroundColor = [UIColor clearColor];
        _barView = [[UIView alloc] initWithFrame:self.bounds];
        [_barView setBackgroundColor:[UIColor clearColor]];
        [self insertSubview:_barView atIndex:0];
        _selectedBarIndex = -1;
        _animations = [[NSMutableArray alloc] init];
        _animationSpeed = 0.5;
        _selectedBarStroke = 3.0;
		if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] &&
			[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		{
			fontSize = FONT_SIZE_IPAD;
			barLabelFontSize = BAR_LABEL_FONT_SIZE_IPAD;
			stepValueAxisY = STEP_AXIS_Y_IPAD;
			self.labelFont = [UIFont boldSystemFontOfSize:15];
		}
		else
		{
			fontSize = FONT_SIZE_IPHONE;
			barLabelFontSize = BAR_LABEL_FONT_SIZE_IPHONE;
			stepValueAxisY = STEP_AXIS_Y_IPHONE;
			self.labelFont = [UIFont boldSystemFontOfSize:10];
		}
		paddingTop = PLOT_PADDING_TOP;
		paddingBotom = PLOT_PADDING_BOTTOM;
		chartRect = self.bounds;
        CGRect bounds = [[self layer] bounds];
        self.barRect = bounds;
		self.barPoint = CGPointMake(bounds.origin.x, bounds.origin.y);
        _valueColor = [UIColor blackColor];
		_valueShadowColor = [UIColor clearColor];
		colorAxisY = [UIColor blackColor];
		colorAxis = [UIColor blackColor];
        _showLabel = YES;
    }
    return self;
}

- (void)setBarPoint:(CGPoint)barPoint
{
	_barPoint = CGPointMake(barPoint.x,barPoint.y);
}

- (void)setBarRect:(CGRect)barRectInst
{
    [_barView setFrame:barRectInst];
    _barRect = CGRectMake(_barView.frame.origin.x,_barView.frame.origin.y,_barView.frame.size.width, _barView.frame.size.height);
}

- (void)setBarBackgroundColor:(UIColor *)color
{
    [_barView setBackgroundColor:color];
}

#pragma mark - manage settings

- (void)setBarSelectedAtIndex:(NSInteger)index
{
	NDLog(@"MBMBarChart : setBarSelectedAtIndex : index = %d  ",index);
    BarLayer *layer = [_barView.layer.sublayers objectAtIndex:index];
    if (layer) {
        CGPoint currPos = layer.position;
		CALayer *labelLayer = [[layer sublayers] objectAtIndex:0];
		[labelLayer setHidden:NO];
        CGPoint newPos = CGPointMake(currPos.x + 0, currPos.y - 5);
        layer.position = newPos;
        layer.isSelected = YES;
    }
}

- (void)setBarDeselectedAtIndex:(NSInteger)index
{
	NDLog(@"MBMBarChart : setBarDeselectedAtIndex : index = %d  ",index);
    BarLayer *layer = [_barView.layer.sublayers objectAtIndex:index];
    if (layer) {
		CALayer *labelLayer = [[layer sublayers] objectAtIndex:0];
		[labelLayer setHidden:YES];
        layer.position = CGPointMake(0, 0);
        layer.isSelected = NO;
    }
}

#pragma mark - Bar Reload Data With Animation

- (void)reloadData
{
	NDLog(@"MBMBarChart : reloadData ");
    if (_dataSource && !_animationTimer)
    {
        CALayer *parentLayer = [_barView layer];
        NSArray *barLayers = [parentLayer sublayers];
		NDLog(@"MBMBarChart : reloadData : barLayers cnt = %d",[barLayers count]);

        _selectedBarIndex = -1;
        [barLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BarLayer *layer = (BarLayer *)obj;
            if(layer.isSelected)
                [self setBarDeselectedAtIndex:idx];
        }];
        
        
		NSUInteger barCount = [_dataSource numberOfBarsInChart:self];
		NDLog(@"MBMBarChart : reloadData : barCount = %d",barCount);

		double values[barCount];

		for (int index = 0; index < barCount; index++) {
            values[index] = [_dataSource barChart:self valueForBarAtIndex:index];
        }

        [CATransaction begin];
        [CATransaction setAnimationDuration:_animationSpeed];
        
        [_barView setUserInteractionEnabled:NO];
        
		NSMutableArray *layersToRemove = [[NSMutableArray alloc] init];
        [CATransaction setCompletionBlock:^{
            
            [layersToRemove enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [obj removeFromSuperlayer];
            }];
            
            [layersToRemove removeAllObjects];

            for(BarLayer *layer in _barView.layer.sublayers)
            {
                [layer setZPosition:kDefaultBarZOrder];
            }
            
            [_barView setUserInteractionEnabled:YES];
        }];
        
        layersToRemove = [NSMutableArray arrayWithArray:barLayers];

        NSInteger diff = barCount - [barLayers count];

		for(int index = 0; index < barCount; index ++)
		{
			BarLayer *layer;
			
			if( index >= [barLayers count] )
            {
                layer = [self createBarLayer];
                [parentLayer addSublayer:layer];
                diff--;
            }
			else
            {
                BarLayer *onelayer = [barLayers objectAtIndex:index];
				if(diff == 0 || onelayer.value == (CGFloat)values[index])
                {
                    layer = onelayer;
                    [layersToRemove removeObject:layer];
                }
				else if(diff > 0)
                {
                    layer = [self createBarLayer];
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
                        onelayer = [barLayers objectAtIndex:index];
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
			if([_dataSource respondsToSelector:@selector(barChart:colorForBarAtIndex:)])
			{
				color = [_dataSource barChart:self colorForBarAtIndex:index];
				CAGradientLayer *gradient = [[layer sublayers] objectAtIndex:1];
				[gradient setColors:[NSArray arrayWithObjects:(id)[color CGColor], (id)[[self getColorFrom:color add:-60] CGColor], nil]];
				gradient = [[layer sublayers] objectAtIndex:2];
				[gradient setColors:[NSArray arrayWithObjects:(id)[color CGColor], (id)[[self getColorFrom:color add:-120] CGColor], nil]];
				gradient = [[layer sublayers] objectAtIndex:3];
				[gradient setColors:[NSArray arrayWithObjects:(id)[color CGColor], (id)[[self getColorFrom:color add:-80] CGColor], nil]];
                [layer setFillColor:[[self getColorFrom:color add:-60] CGColor]];
			}
			
			if([_dataSource respondsToSelector:@selector(barChart:textForBarAtIndex:)])
            {
                //layer.text = [_dataSource barChart:self textForBarAtIndex:index];
				//NDLog(@"MBMBarChart : reloadData #2: layer.text = %@",layer.text);
            }
			
            [self updateLabelForLayer:layer value:values[index]];
			
			CGRect fromRect = CGRectZero;
			CGRect toRect = CGRectZero;
			CGRect toScaledRect = CGRectZero;

			if([_dataSource respondsToSelector:@selector(barChart:rectForBarAtIndex:)])
			{
				toRect = [_dataSource barChart:self rectForBarAtIndex:index];
                NDLog(@"MBMBarChart : reloadData : toRect : x = %f : y = %f : w = %f : h = %f",toRect.origin.x,toRect.origin.y,toRect.size.width,toRect.size.height);
				fromRect = CGRectMake(toRect.origin.x, toRect.origin.y, toRect.size.width, 0);
				toScaledRect = CGRectMake(toRect.origin.x, toRect.origin.y, toRect.size.width, toRect.size.height*scaleAxisY);
			}
			
			[layer createBarAnimationForKey:@"barRect"
                                  fromValue:[NSValue valueWithCGRect:fromRect]
                                    toValue:[NSValue valueWithCGRect:toScaledRect]
                                   Delegate:self];
		}
		[CATransaction setDisableActions:YES];
        for(BarLayer *layer in layersToRemove)
        {
            [layer setFillColor:[self backgroundColor].CGColor];
            [layer setDelegate:nil];
            [layer setZPosition:0];
            CATextLayer *textLayer = [[layer sublayers] objectAtIndex:0];
            [textLayer setHidden:YES];
			CAGradientLayer *gradient = [[layer sublayers] objectAtIndex:1];
            [gradient setHidden:YES];
            gradient = [[layer sublayers] objectAtIndex:2];
            [gradient setHidden:YES];
            gradient = [[layer sublayers] objectAtIndex:3];
            [gradient setHidden:YES];
        }
		[CATransaction setDisableActions:NO];
		[CATransaction commit];
	}
}

#pragma mark - Animation Delegate + Run Loop Timer

- (void)updateTimerFired:(NSTimer *)timer;
{
    CALayer *parentLayer = [_barView layer];
    NSArray *barLayers = [parentLayer sublayers];
    [barLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CGRect presentationLayerRect = [[[obj presentationLayer] valueForKey:@"barRect"] CGRectValue];
        CGPathRef path = CGPathCreateBar(presentationLayerRect);
        [obj setPath:path];
        {
			[CATransaction setDisableActions:YES];
			CAGradientLayer *gradient = [[obj sublayers] objectAtIndex:1];
			[gradient setFrame:presentationLayerRect];
            
            CGFloat innerMargin = 2.5f;
            CGRect innerRect = CGRectInset(presentationLayerRect, innerMargin, 0);
            gradient = [[obj sublayers] objectAtIndex:2];
			[gradient setFrame:innerRect];
            
            CGFloat highLightMargin = 4.5f;
            CGRect highLightRect = CGRectInset(presentationLayerRect, highLightMargin, 0);
            gradient = [[obj sublayers] objectAtIndex:3];
			[gradient setFrame:highLightRect];
			[CATransaction setDisableActions:NO];
			
			CALayer *labelLayer = [[obj sublayers] objectAtIndex:0];
			//Hide the labelLayer so when the user clicks on it, it becomes visible
			[labelLayer setHidden:YES];
            [CATransaction setDisableActions:YES];
			[labelLayer setPosition:CGPointMake(presentationLayerRect.origin.x+presentationLayerRect.size.width/2, presentationLayerRect.origin.y + presentationLayerRect.size.height)];
            [CATransaction setDisableActions:NO];
        }
        CFRelease(path);
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
    
    CALayer *parentLayer = [_barView layer];
    NSArray *barLayers = [parentLayer sublayers];
    
    [barLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BarLayer *barLayer = (BarLayer *)obj;
        CGPathRef path = [barLayer path];
        
        if (CGPathContainsPoint(path, &transform, point, 0)) {
            [barLayer setLineWidth:_selectedBarStroke];
            [barLayer setStrokeColor:[UIColor whiteColor].CGColor];
            [barLayer setLineJoin:kCALineJoinBevel];
            [barLayer setZPosition:MAXFLOAT];
            selectedIndex = idx;
        } else {
            [barLayer setZPosition:kDefaultBarZOrder];
            [barLayer setLineWidth:0.0];
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
    CGPoint point = [touch locationInView:_barView];
    [self getCurrentSelectedOnTouch:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_barView];
    NSInteger selectedIndex = [self getCurrentSelectedOnTouch:point];
    [self notifyDelegateOfSelectionChangeFrom:_selectedBarIndex to:selectedIndex];
    [self touchesCancelled:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    CALayer *parentLayer = [_barView layer];
    NSArray *barLayers = [parentLayer sublayers];
    
    for (BarLayer *barLayer in barLayers) {
        [barLayer setZPosition:kDefaultBarZOrder];
        [barLayer setLineWidth:0.0];
    }
}

#pragma mark - Selection Notification

- (void)notifyDelegateOfSelectionChangeFrom:(NSUInteger)previousSelection to:(NSUInteger)newSelection
{
    if (previousSelection != newSelection)
    {
        if (previousSelection != -1 && [_delegate respondsToSelector:@selector(barChart:willDeselectBarAtIndex:)])
        {
            [_delegate barChart:self willDeselectBarAtIndex:previousSelection];
        }
        
        _selectedBarIndex = newSelection;
        
        if (newSelection != -1)
        {
            if([_delegate respondsToSelector:@selector(barChart:willSelectBarAtIndex:)])
                [_delegate barChart:self willSelectBarAtIndex:newSelection];
            if(previousSelection != -1 && [_delegate respondsToSelector:@selector(barChart:didDeselectBarAtIndex:)])
                [_delegate barChart:self didDeselectBarAtIndex:previousSelection];
            if([_delegate respondsToSelector:@selector(barChart:didSelectBarAtIndex:)])
                [_delegate barChart:self didSelectBarAtIndex:newSelection];
            [self setBarSelectedAtIndex:newSelection];
        }
        
        if(previousSelection != -1)
        {
            [self setBarDeselectedAtIndex:previousSelection];
            if([_delegate respondsToSelector:@selector(barChart:didDeselectBarAtIndex:)])
                [_delegate barChart:self didDeselectBarAtIndex:previousSelection];
        }
    }
    else if (newSelection != -1)
    {
        BarLayer *layer = [_barView.layer.sublayers objectAtIndex:newSelection];
        if(layer){
            
            if (layer.isSelected) {
                if ([_delegate respondsToSelector:@selector(barChart:willDeselectBarAtIndex:)])
                    [_delegate barChart:self willDeselectBarAtIndex:newSelection];
                [self setBarDeselectedAtIndex:newSelection];
                if (newSelection != -1 && [_delegate respondsToSelector:@selector(barChart:didDeselectBarAtIndex:)])
                    [_delegate barChart:self didDeselectBarAtIndex:newSelection];
            }
            else {
                if ([_delegate respondsToSelector:@selector(barChart:willSelectBarAtIndex:)])
                    [_delegate barChart:self willSelectBarAtIndex:newSelection];
                [self setBarSelectedAtIndex:newSelection];
                if (newSelection != -1 && [_delegate respondsToSelector:@selector(barChart:didSelectBarAtIndex:)])
                    [_delegate barChart:self didSelectBarAtIndex:newSelection];
            }
        }
    }
}

#pragma mark - Bar Layer Creation Method

- (BarLayer *)createBarLayer
{
	NDLog(@"MBMBarChart : createBarLayer ");
    BarLayer *barLayer = [BarLayer layer];

    [barLayer setZPosition:0];
    [barLayer setStrokeColor:NULL];
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
    [textLayer setForegroundColor:self.valueColor.CGColor];
    if (self.valueShadowColor) {
        [textLayer setShadowColor:self.valueShadowColor.CGColor];
        [textLayer setShadowOffset:CGSizeZero];
        [textLayer setShadowOpacity:1.0f];
        [textLayer setShadowRadius:2.0f];
    }
    CGSize size = [@"0" sizeWithFont:self.labelFont];
    [CATransaction setDisableActions:YES];
    [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
	[CATransaction setDisableActions:NO];
    [barLayer insertSublayer:textLayer atIndex:0];

	CAGradientLayer * gradient = [CAGradientLayer layer];
	[gradient setColors:[NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor clearColor] CGColor], nil]];
	[gradient setCornerRadius:4.0f];
    [barLayer insertSublayer:gradient atIndex:1];
    
    gradient = [CAGradientLayer layer];
	[gradient setColors:[NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor clearColor] CGColor], nil]];
    [barLayer insertSublayer:gradient atIndex:2];
    
    gradient = [CAGradientLayer layer];
	[gradient setColors:[NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor clearColor] CGColor], nil]];
    [barLayer insertSublayer:gradient atIndex:3];

    return barLayer;
}

- (void)updateLabelForLayer:(BarLayer *)barLayer value:(CGFloat)value
{
    CATextLayer *textLayer = [[barLayer sublayers] objectAtIndex:0];
    if(!_showLabel) return;
	NSString *label = (barLayer.text)?barLayer.text:[NSString stringWithFormat:@"%0.0f", value];
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
	NDLog(@"MBMBarChart : calculateChartFrame : barWidth = %f : barInterval = %f : leftPadding = %f ",barWidth,barInterval,leftPadding);
}

- (void)drawChart:(NSMutableArray*)barDicArray
{
	[self setBarDicArray:barDicArray];
	[self setMaxValueAxisY:0];
	[self setMinValueAxisY:0];

	for (NSDictionary *barDic in _barDicArray)
	{
		CGFloat barValue = [[barDic objectForKey:@"BarValue"] floatValue];
		if(barValue > maxValueAxisY)
			[self setMaxValueAxisY:barValue];

		if(barValue < minValueAxisY)
			[self setMinValueAxisY:barValue];

	}
	float range = maxValueAxisY - minValueAxisY;
	float exponent = floor(log10f(range));
	float base = pow(10, (exponent - 1));
	[self setMaxValueAxisY:(ceilf(range / base) * base)];

	NDLog(@"MBMBarChart : drawChart : maxValueAxisY = %f ",maxValueAxisY);
	NDLog(@"MBMBarChart : drawChart : maxValueAxisY = %f ",minValueAxisY);
	double height = self.frame.size.height;
	[self setScaleAxisY:((height - paddingTop - paddingBotom) / maxValueAxisY)];
	NDLog(@"MBMBarChart : drawChart : scaleAxisY = %f ",scaleAxisY);
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	NDLog(@"MBMBarChart : drawRect ");
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
		for (NSDictionary *barDic in _barDicArray)
		{
			NSString *barLabel = [NSString stringWithFormat:@"%@",[barDic objectForKey:@"BarLabel"]];
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
	[_valueColor release];
	[_valueShadowColor release];
    [_barDicArray release];
	[colorAxisY release];
	[colorAxis release];
	[super dealloc];
}


@end
