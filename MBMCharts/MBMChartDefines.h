//
//  MBMChartDefines.h
//  MBMCharts
//
//  Created by Pat Murphy on 12/17/12.
//  Copyright (c) 2012 Pat Murphy. All rights reserved.
//

#define STROKE_AXIS_Y_SCALE 85
#define FONT_SIZE_IPAD 14.0f
#define BAR_LABEL_FONT_SIZE_IPAD 12.0f
#define STEP_AXIS_Y_IPAD 20.0f

#define FONT_SIZE_IPHONE 10.0f
#define BAR_LABEL_FONT_SIZE_IPHONE 12.0f
#define STEP_AXIS_Y_IPHONE 40.0f

#define PLOT_PADDING_TOP 15.0f
#define PLOT_PADDING_BOTTOM 15.0f

#define LINE_CHART_POINT_RADIUS_IPAD 7.0f
#define LINE_CHART_POINT_RADIUS_IPHONE 4.0f

#define LINE_STROKE_WIDTH_IPAD 3.0f
#define LINE_STROKE_WIDTH_IPHONE 2.0f

#ifdef DEBUG
#    define NDLog(...) NSLog(__VA_ARGS__)
#else
#    define NDLog(...)
#endif
