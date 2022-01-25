import "dart:math";

import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";

class DashboardLineChart extends StatelessWidget {
  const DashboardLineChart({
    required this.dataSet,
    this.distanceFromHighest = 5,
    this.inputedColors = colors,
  });
  final List<Color> inputedColors;
  final int distanceFromHighest;
  final List<List<double>> dataSet;

  @override
  Widget build(final BuildContext context) {
    final double highestValue = dataSet
        .map((final List<double> points) => points.reduce(max))
        .reduce(max);
    return LineChart(
      LineChartData(
        lineBarsData:
            List<LineChartBarData>.generate(dataSet.length, (final int index) {
          final List<Color> chartColors = <Color>[inputedColors[index]];
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
            interval: 5,
            getTitles: (final double value) => value.toInt().toString(),
            showTitles: true,
            getTextStyles: (final BuildContext context, final double value) =>
                TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            reservedSize: 28,
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
        minY: 0,
        maxY: highestValue + distanceFromHighest,
      ),
    );
  }
}

class DashBoardClimbLineChart extends StatelessWidget {
  const DashBoardClimbLineChart({
    required this.dataSet,
    this.inputedColors = const <Color>[],
  });
  final List<Color> inputedColors;
  final List<List<double>> dataSet;

  @override
  Widget build(final BuildContext context) => LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (final List<LineBarSpot> touchedSpots) =>
                  touchedSpots
                      .map(
                        (final LineBarSpot e) => LineTooltipItem(
                          <int, String>{
                                0: "Failed",
                                -1: "No attempt"
                              }[e.y.toInt()] ??
                              "Level ${e.y.toInt()}",
                          TextStyle(),
                        ),
                      )
                      .toList(),
            ),
          ),
          lineBarsData: List<LineChartBarData>.generate(dataSet.length,
              (final int index) {
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
              interval: 1,
              getTitles: (final double value) {
                switch (value.toInt()) {
                  case -1:
                    return "No attempt";
                  case 0:
                    return "Failed";
                  default:
                    return value == 5 || value == -2
                        ? ""
                        : "level ${value.toInt()}";
                }
              },
              showTitles: true,
              getTextStyles: (final BuildContext context, final double value) =>
                  TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              reservedSize: 70,
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
          minY: -1,
          maxY: 5,
        ),
      );
}
