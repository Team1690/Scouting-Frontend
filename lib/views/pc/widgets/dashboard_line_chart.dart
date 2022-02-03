import "dart:math";

import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";

class DashboardLineChart<E extends num> extends StatelessWidget {
  const DashboardLineChart({
    required this.dataSet,
    required this.gameNumbers,
    this.distanceFromHighest = 5,
    this.inputedColors = colors,
  });
  final List<Color> inputedColors;
  final int distanceFromHighest;
  final List<List<E>> dataSet;
  final List<int> gameNumbers;

  @override
  Widget build(final BuildContext context) {
    final num highestValue =
        dataSet.map((final List<E> points) => points.reduce(max)).reduce(max);
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
            spots: List<FlSpot>.generate(
              dataSet[index].length,
              (final int inner) => FlSpot(
                inner.toDouble() + 1,
                dataSet[index][inner].toDouble(),
              ),
            ),
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
            getTitles: (final double value) {
              return gameNumbers[value.toInt() - 1].toString();
            },
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
        maxY: highestValue.toDouble() + distanceFromHighest,
      ),
    );
  }
}

class DashBoardClimbLineChart<E extends num> extends StatelessWidget {
  const DashBoardClimbLineChart({
    required this.dataSet,
    this.inputedColors = const <Color>[],
    required this.matchNumbers,
  });
  final List<int> matchNumbers;
  final List<Color> inputedColors;
  final List<List<E>> dataSet;

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
              spots: List<FlSpot>.generate(
                dataSet[index].length,
                (final int inner) => FlSpot(
                  inner.toDouble() + 1,
                  dataSet[index][inner].toDouble(),
                ),
              ),
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
              getTitles: (final double value) =>
                  matchNumbers[value.toInt() - 1].toString(),
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
