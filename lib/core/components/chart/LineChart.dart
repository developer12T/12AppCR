import 'package:_12sale_app/core/styles/style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          // backgroundColor: Colors.black,
          gridData: const FlGridData(show: true), // Show grid lines
          titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}',
                      style: Styles.black18(context));
                },
              )),
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                getTitlesWidget: (value, meta) {
                  return Text(value.toString(), style: Styles.black18(context));
                },
                showTitles: true,
              )),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false))),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Styles.primaryColor,
              spots: _getMockData(),
              dotData: const FlDotData(show: true), // Dots on the line
              belowBarData: BarAreaData(
                  show: true, color: Styles.primaryColor.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }

  // Mock data for the line chart
  List<FlSpot> _getMockData() {
    return [
      FlSpot(0, 1),
      FlSpot(1, 1.5),
      FlSpot(2, 1.4),
      FlSpot(3, 3.4),
      FlSpot(4, 2),
      FlSpot(5, 2.2),
      FlSpot(6, 1.8),
    ];
  }
}

void main() => runApp(MaterialApp(home: LineChartSample()));
