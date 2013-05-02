MBMCharts
=========

Mobitor Business Model Charts for iPhone / iPad Objective-C

Mobitor Business Models for Charts
Includes : Bar Chart, Line Chart & Pie Chart

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Copyright (c) 2013 Mobitor Corporation;
www.mobitor.com

If your a programmer, go to our website : www.mobitor.com
We are always looking for good programmers in iOS, Xcode, C#, Visual Studio,
.NET, HTML5, jQuery and other JavaScript-based frameworks, SQL Server 2008 / 2012
and of course Git for source control.

If you find any bugs, you can contact:
Pat Murphy
pmurphyjam@me.com

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
Pick one of the three chart types or use them all. Add the QuartzCore.framework to your project.
Add MBMChartDefines, and either MBMBarChart, or MBMLineChart, or MBMPieChart to the Xcode project.
Add the respective View Controller, either BarChartViewController, or LineChartViewController, or PieChartViewController.
These view controllers will need to be slightly modified for your purpose, currently they show all the capabilities
which you may or may not want.
You will have to do the following:
1) Load DicArray : Contains the chart data that is displayed in the chart, currently this is all randomized.
   You will want to load your own data from a DB(SQLite,CoreData,UltraLite) or hard coded MutableArray.
2) Load ChartConfigArray : Contains various booleans and color values for the background chart. 
   Not required for PieCharts.
3) Load the ChartDataArray : Contains various Labels, and colors for the background chart.
   Not required for PieCharts.
4) Modify the respective Nib View Controller for your purpose.

All charts must be displayed in Landscape mode, they will not draw correctly in Portrait.

MBMCharts also uses the MBMControlLibrary components UIColorCategory, and UIImageCategory.

The ChartViewController is not required in your project, it is used to merely demo the respective charts.

The original PieChart was modified and obtained from : 
Copyright (c) 2012 Xiaoyang Feng, XYStudio.cc

