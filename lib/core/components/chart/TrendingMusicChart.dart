import 'package:_12sale_app/core/styles/style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class TrendingMusicChart extends StatefulWidget {
  @override
  _TrendingMusicChartState createState() => _TrendingMusicChartState();
}

class _TrendingMusicChartState extends State<TrendingMusicChart> {
  String _selectedGenre = 'All'; // Default filter

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TRENDING MUSIC',
              style: Styles.black24(context),
            ),
            Container(
              // width: screenWidth / 3,
              padding: EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Styles.primaryColor),
                borderRadius: BorderRadius.circular(8),
                // color: Colors.amber,
              ),
              child: DropdownButton<String>(
                value: _selectedGenre,
                style: Styles.black18(context),
                items: ['All', 'Jazz Music', 'Pop Music', 'Rock Music']
                    .map((String genre) {
                  return DropdownMenuItem<String>(
                    value: genre,
                    child: Text(
                      genre,
                      style: Styles.black18(context),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGenre = newValue!;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: screenWidth / 25),
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: 25, // Adjust based on your data
              barGroups: _buildBarGroups(),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(
                show: false,
              ),
              titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final style = Styles.black12(context);
                        switch (value.toInt()) {
                          case 0:
                            return Text('Jan', style: style);
                          case 1:
                            return Text('Feb', style: style);
                          case 2:
                            return Text('Mar', style: style);
                          case 3:
                            return Text('Apr', style: style);
                          case 4:
                            return Text('May', style: style);
                          case 5:
                            return Text('Jun', style: style);
                          case 6:
                            return Text('Jul', style: style);
                          case 7:
                            return Text('Aug', style: style);
                          case 8:
                            return Text('Sep', style: style);
                          case 9:
                            return Text('Oct', style: style);
                          case 10:
                            return Text('Nov', style: style);
                          case 11:
                            return Text('Dec', style: style);
                          default:
                            return Text('', style: style);
                        }
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  topTitles: AxisTitles()),

              barTouchData: BarTouchData(enabled: true),
            ),
          ),
        ),
        SizedBox(height: screenWidth / 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend('Jazz Music', Colors.orange, context),
            SizedBox(width: 10),
            _buildLegend('Pop Music', Colors.teal, context),
            SizedBox(width: 10),
            _buildLegend('Rock Music', Colors.blue, context),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend(String title, Color color, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        SizedBox(width: 4),
        Text(
          title,
          style: Styles.black12(context),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        barRods: _buildBarRods(index),
        barsSpace: 4, // Space between bars in the group
      );
    });
  }

  List<BarChartRodData> _buildBarRods(int month) {
    // Display bars based on the selected genre filter
    switch (_selectedGenre) {
      case 'Jazz Music':
        return [
          BarChartRodData(
            toY: _getJazzValue(month),
            color: Colors.orange,
            width: 12,
            borderRadius: BorderRadius.circular(0),
          ),
        ];
      case 'Pop Music':
        return [
          BarChartRodData(
            toY: _getPopValue(month),
            color: Colors.teal,
            width: 12,
            borderRadius: BorderRadius.circular(0),
          ),
        ];
      case 'Rock Music':
        return [
          BarChartRodData(
            toY: _getRockValue(month),
            color: Colors.blue,
            width: 12,
            borderRadius: BorderRadius.circular(0),
          ),
        ];
      default: // 'All'
        return [
          BarChartRodData(
            toY: _getJazzValue(month),
            color: Colors.orange,
            borderRadius: BorderRadius.circular(0),
            width: 12,
          ),
          BarChartRodData(
            toY: _getPopValue(month),
            color: Colors.teal,
            borderRadius: BorderRadius.circular(0),
            width: 12,
          ),
          BarChartRodData(
            toY: _getRockValue(month),
            color: Colors.blue,
            borderRadius: BorderRadius.circular(0),
            width: 12,
          ),
        ];
    }
  }

  double _getJazzValue(int month) {
    const values = [
      5.0,
      10.0,
      15.0,
      8.0,
      20.0,
      18.0,
      10.0,
      15.0,
      12.0,
      17.0,
      22.0,
      20.0
    ];
    return values[month];
  }

  double _getPopValue(int month) {
    const values = [
      7.0,
      12.0,
      8.0,
      12.0,
      22.0,
      25.0,
      15.0,
      18.0,
      20.0,
      24.0,
      25.0,
      23.0
    ];
    return values[month];
  }

  double _getRockValue(int month) {
    const values = [
      4.0,
      8.0,
      6.0,
      10.0,
      12.0,
      11.0,
      8.0,
      7.0,
      9.0,
      10.0,
      13.0,
      11.0
    ];
    return values[month];
  }
}
