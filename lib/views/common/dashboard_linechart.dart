import "dart:math";

import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart"
    show MatchIdentifier, RobotMatchStatus;

class DashboardLineChart<E extends num> extends StatelessWidget {
  const DashboardLineChart({
    required this.dataSet,
    required this.gameNumbers,
    this.distanceFromHighest = 5,
    required this.inputedColors,
    required this.showShadow,
    required this.robotMatchStatuses,
  });
  final bool showShadow;
  final List<Color> inputedColors;
  final int distanceFromHighest;
  final List<List<E>> dataSet;
  final List<MatchIdentifier> gameNumbers;
  final List<List<RobotMatchStatus>> robotMatchStatuses;

  @override
  Widget build(final BuildContext context) {
    final num highestValue =
        dataSet.map((final List<E> points) => points.reduce(max)).reduce(max);
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideVertically: true,
            fitInsideHorizontally: true,
            getTooltipItems: (final List<LineBarSpot> touchedSpots) =>
                touchedSpots
                    .map(
                      (final LineBarSpot e) => LineTooltipItem(
                        e.y.toInt().toString(),
                        TextStyle(color: e.bar.colors[0]),
                      ),
                    )
                    .toList(),
          ),
        ),
        lineBarsData:
            List<LineChartBarData>.generate(dataSet.length, (final int index) {
          final List<Color> chartColors = <Color>[inputedColors[index]];
          return LineChartBarData(
            isCurved: false,
            colors: chartColors,
            barWidth: 8,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (
                final FlSpot spot,
                final double d,
                final LineChartBarData a,
                final int v,
              ) =>
                  FlDotCirclePainter(
                strokeWidth: 4,
                radius: 6,
                color: secondaryColor,
                strokeColor: robotMatchStatuses[index][spot.x.toInt()] ==
                        RobotMatchStatus.didntComeToField
                    ? Colors.red
                    : Colors.purple,
              ),
              checkToShowDot: (final FlSpot spot, final LineChartBarData data) {
                return robotMatchStatuses[index][spot.x.toInt()] ==
                        RobotMatchStatus.didntComeToField ||
                    robotMatchStatuses[index][spot.x.toInt()] ==
                        RobotMatchStatus.didntWorkOnField;
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              colors: showShadow
                  ? chartColors
                      .map((final Color color) => color.withOpacity(0.3))
                      .toList()
                  : <Color>[Color(0x00000000)],
            ),
            spots: List<FlSpot>.generate(
              dataSet[index].length,
              (final int inner) => FlSpot(
                inner.toDouble(),
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
            interval: 1,
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
              return gameNumbers[value.toInt()].toString();
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
        minX: 0,
        minY: 0,
        maxY: highestValue.toDouble() + distanceFromHighest,
      ),
    );
  }
}

class DashboardClimbLineChart<E extends num> extends StatelessWidget {
  const DashboardClimbLineChart({
    required this.dataSet,
    required this.inputedColors,
    required this.matchNumbers,
    required this.showShadow,
    required this.robotMatchStatuses,
  });
  final List<Color> inputedColors;
  final List<MatchIdentifier> matchNumbers;
  final List<List<RobotMatchStatus>> robotMatchStatuses;

  final List<List<E>> dataSet;
  final bool showShadow;

  @override
  Widget build(final BuildContext context) => LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (final List<LineBarSpot> touchedSpots) =>
                  touchedSpots
                      .map(
                        (final LineBarSpot e) => LineTooltipItem(
                          <int, String>{
                                0: "Failed",
                                -1: "No attempt"
                              }[e.y.toInt()] ??
                              "Level ${e.y.toInt()}",
                          TextStyle(color: e.bar.colors[0]),
                        ),
                      )
                      .toList(),
            ),
          ),
          lineBarsData: List<LineChartBarData>.generate(dataSet.length,
              (final int index) {
            final List<Color> chartColors = <Color>[inputedColors[index]];
            return LineChartBarData(
              isCurved: false,
              colors: chartColors,
              barWidth: 8,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (
                  final FlSpot spot,
                  final double d,
                  final LineChartBarData a,
                  final int v,
                ) =>
                    FlDotCirclePainter(
                  strokeWidth: 4,
                  radius: 6,
                  color: secondaryColor,
                  strokeColor: robotMatchStatuses[index][spot.x.toInt()] ==
                          RobotMatchStatus.didntComeToField
                      ? Colors.red
                      : Colors.purple,
                ),
                checkToShowDot:
                    (final FlSpot spot, final LineChartBarData data) {
                  return robotMatchStatuses[index][spot.x.toInt()] ==
                          RobotMatchStatus.didntComeToField ||
                      robotMatchStatuses[index][spot.x.toInt()] ==
                          RobotMatchStatus.didntWorkOnField;
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                colors: showShadow
                    ? chartColors
                        .map((final Color color) => color.withOpacity(0.3))
                        .toList()
                    : <Color>[Color(0x00000000)],
              ),
              spots: List<FlSpot>.generate(
                dataSet[index].length,
                (final int inner) => FlSpot(
                  inner.toDouble(),
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
                  matchNumbers[value.toInt()].toString(),
              showTitles: true,
              interval: 1,
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
          minX: 0,
          minY: -1,
          maxY: 5,
        ),
      );
}
