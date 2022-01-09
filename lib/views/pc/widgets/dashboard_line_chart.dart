import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/constants.dart';

class DashboardLineChart extends StatelessWidget {
  const DashboardLineChart({
    required this.dataSet,
    this.distanceFromHighest = 5,
    Key? key,
  }) : super(key: key);

  final int distanceFromHighest;
  final List<List<double>> dataSet;

  @override
  Widget build(BuildContext context) {
    double highestValue = -1;
    dataSet.forEach(
        (points) => {highestValue = max(highestValue, points.reduce(max))});
    double highestX = -1;
    return LineChart(LineChartData(
        lineBarsData: List.generate(dataSet.length, (index) {
          List<Color> chartColors = [colors[index]];
          return LineChartBarData(
              isCurved: false,
              colors: chartColors,
              barWidth: 8,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                colors:
                    chartColors.map((color) => color.withOpacity(0.3)).toList(),
              ),
              spots: dataSet[index]
                  .asMap()
                  .entries
                  .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                  .toList());
        }),
        gridData: FlGridData(
          verticalInterval: 1,
          horizontalInterval: 1,
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xff37434d),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: const Color(0xff37434d),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
            show: true,
            topTitles: SideTitles(
              showTitles: true,
              reservedSize: 16,
              getTextStyles: (context, value) =>
                  const TextStyle(color: Colors.white, fontSize: 16),
              margin: 8,
              checkToShowTitle:
                  (minValue, maxValue, sideTitles, appliedInterval, value) =>
                      value == value.floorToDouble(),
            ),
            rightTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              reservedSize: 28,
              margin: 12,
            ),
            bottomTitles: SideTitles(showTitles: false),
            leftTitles: SideTitles(showTitles: false)),
        borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1)),
        minX: 0,
        minY: 0,
        maxY: highestValue + distanceFromHighest));
  }
}
