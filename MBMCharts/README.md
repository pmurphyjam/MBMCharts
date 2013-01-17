Mobitor Business Models for Charts
Includes : BarChart, LineChart & PieChart

Copyright (c) 2013 Mobitor Corporation;
www.mobitor.com

MBMCharts is a simple and easy-to-use charting library for iOS apps. 
It includes path animations for redrawing and animating the charts using a CAShapeLayer.
All charts have pretty much the same architecture:
1) CAShapeLayer
2) Animation for Key for animating the chart.
3) Chart Class for either MBMBarChart, MBMLineChart, MBMPieChart.
4) Data and Source Delegates for reloading the respective chart.
5) Animation timer.
6) Touch Events.
7) Chart background view.
8) Respective View Controller for the specified chart type with Nib for either iPhone or iPad.

To Use:
Pick one of the three chart types. Add the QuartzCore.framework to your project.
Add MBMChartDefines, and either MBMBarChart, or MBMLineChart, or MBMPieChart to the Xcode project.
Add the respective View Controller, either BarChartViewController, or LineChartViewController, or PieChartViewController.
These view controllers will need to be slightly modified for your purpose, you will have to do the following:
1) Load DicArray : Contains the chart data that is displayed in the chart.
2) Load ChartConfigArray : Contains various booleans and color values for the background chart. 
   Not required for PieCharts.
3) Load the ChartDataArray : Contains various Labels, and colors for the background chart.
   Not required for PieCharts.
4) Modify the respective Nib View Controller for your purpose.

All charts must be displayed in Landscape mode, they will not draw correctly in Portrait.

MBMCharts also uses the MBMControlLibrary components UIColorCategory, and UIImageCategory.

The ChartViewController is not required in your project, it is used to merely demo the respective charts.
