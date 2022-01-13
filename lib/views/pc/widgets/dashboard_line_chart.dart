import "dart:math";

import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";

class DashboardLineChart extends StatelessWidget {
  const DashboardLineChart(
      {required this.dataSet,
      this.distanceFromHighest = 5,
      this.inputedColors = const <Color>[],
      this.isClimb = false});
  final List<Color> inputedColors;
  final int distanceFromHighest;
  final List<List<double>> dataSet;
  final bool isClimb;

  @override
  Widget build(final BuildContext context) {
    final double highestValue = dataSet
        .map((final List<double> points) => points.reduce(max))
        .reduce(max);
    return LineChart(
      LineChartData(
        lineTouchData: isClimb
            ? LineTouchData(touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (final List<LineBarSpot> touchedSpots) {
                  switch (touchedSpots[0].y.toInt()) {
                    case -1:
                      return [LineTooltipItem("Failed", TextStyle())];
                    case 0:
                      return [LineTooltipItem("No attempt", TextStyle())];
                    default:
                      return [
                        LineTooltipItem(
                            "level ${touchedSpots[0].y.toInt().toString()}",
                            TextStyle())
                      ];
                  }
                },
              ))
            : null,
        lineBarsData:
            List<LineChartBarData>.generate(dataSet.length, (final int index) {
          final List<Color> chartColors = <Color>[
            inputedColors.isEmpty ? colors[index] : inputedColors[index]
          ];
          return LineChartBarData(
            isCurved: false,
            colors: chartColors,
            barWidth: 8,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              colors: chartColors
                  .map((final Color color) => color.withOpacity(0.3))
                  .toList(),
            ),
            spots: dataSet[index]
                .asMap()
                .entries
                .map(
                  (final MapEntry<int, double> entry) =>
                      FlSpot(entry.key.toDouble() + 1, entry.value),
                )
                .toList(),
          );
        }),
        gridData: FlGridData(
          verticalInterval: 1,
          horizontalInterval: 1,
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (final double value) {
            return FlLine(
              color: const Color(0xff37434d),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (final double value) {
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
            getTextStyles: (final BuildContext context, final double value) =>
                TextStyle(color: Colors.white, fontSize: 16),
            checkToShowTitle: (
              final double minValue,
              final double maxValue,
              final SideTitles sideTitles,
              final double appliedInterval,
              final double value,
            ) =>
                value == value.floorToDouble(),
          ),
          rightTitles: SideTitles(
            interval: isClimb ? 1 : 5,
            getTitles: (final double value) {
              if (isClimb) {
                switch (value.toInt()) {
                  case -1:
                    return "No attempt";
                  case 0:
                    return "Failed";
                  default:
                    return "level ${value.toInt()}";
                }
              } else {
                return value.toString();
              }
            },
            showTitles: true,
            getTextStyles: (final BuildContext context, final double value) =>
                TextStyle(
              color: Colors.white,
              fontSize: isClimb ? 12 : 16,
            ),
            reservedSize: isClimb ? 70 : 28,
            margin: 12,
          ),
          bottomTitles: SideTitles(showTitles: false),
          leftTitles: SideTitles(showTitles: false),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 1,
        minY: isClimb ? -1 : 0,
        maxY: highestValue + distanceFromHighest,
      ),
    );
  }
}
