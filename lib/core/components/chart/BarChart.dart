import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bar Chart Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            barGroups: _buildBarGroups(),
            borderData: FlBorderData(
              show: false,
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    const style = TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    );
                    switch (value.toInt()) {
                      case 0:
                        return Text('Mon', style: style);
                      case 1:
                        return Text('Tue', style: style);
                      case 2:
                        return Text('Wed', style: style);
                      case 3:
                        return Text('Thu', style: style);
                      case 4:
                        return Text('Fri', style: style);
                      case 5:
                        return Text('Sat', style: style);
                      case 6:
                        return Text('Sun', style: style);
                      default:
                        return Text('', style: style);
                    }
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return [
      BarChartGroupData(
          x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.blue)]),
      BarChartGroupData(
          x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.blue)]),
      BarChartGroupData(
          x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.blue)]),
      BarChartGroupData(
          x: 3, barRods: [BarChartRodData(toY: 15, color: Colors.blue)]),
      BarChartGroupData(
          x: 4, barRods: [BarChartRodData(toY: 13, color: Colors.blue)]),
      BarChartGroupData(
          x: 5, barRods: [BarChartRodData(toY: 10, color: Colors.blue)]),
      BarChartGroupData(
          x: 6, barRods: [BarChartRodData(toY: 12, color: Colors.blue)]),
    ];
  }
}
