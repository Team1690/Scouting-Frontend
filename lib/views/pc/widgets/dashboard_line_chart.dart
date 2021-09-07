import 'dart:developer';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardLineChart extends StatelessWidget {
  const DashboardLineChart({
    Key key,
    @required this.dataSets,
    this.colors,
    // this.colors = const [const Color(0xff23b6e6), const Color(0xff02d39a)],
    // @required this.title,
    // @required this.body,
  }) : super(key: key);

  final List dataSets;
  final List<Color> colors;
  // final String title;
  // final Widget body;

  @override
  Widget build(BuildContext context) {
    // inspect(dataSets);

    List<Color> _colors = [
      Colors.primaries[Random().nextInt(Colors.primaries.length)],
      Colors.primaries[Random().nextInt(Colors.primaries.length)]
    ];
    // const List<Color> colors = [
    //   const Color(0xff23b6e6),
    //   const Color(0xff02d39a)
    // ];
    return LineChart(
      LineChartData(
        lineBarsData: dataSets
            .asMap()
            .entries
            .map((dataSet) => LineChartBarData(
                  isCurved: true,
                  colors: [colors[dataSet.key]],
                  barWidth: 8,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    colors: [colors[dataSet.key].withOpacity(0.3)],
                    // colors.map((color) => color.withOpacity(0.3)).toList(),
                  ),
                  // spots: List.generate(10,
                  //     (index) => FlSpot(index.toDouble(), Random().nextDouble())))),
                  spots: dataSet.value
                      .map<FlSpot>(
                          (dataPoint) => FlSpot(dataPoint[0], dataPoint[1]))
                      .toList(),
                ))
            .toList(),
        gridData: FlGridData(
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
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 16,
            getTextStyles: (value) => const TextStyle(
                color: Color(0xff68737d),
                fontWeight: FontWeight.bold,
                fontSize: 16),
            margin: 8,
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value) => const TextStyle(
              color: Color(0xff67727d),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            reservedSize: 28,
            margin: 12,
          ),
        ),
        borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1)),
        minX: 0,
        // maxX: 11,
        minY: 0,
        // maxY: 2,
      ),
      swapAnimationDuration: Duration(milliseconds: 500),
      // swapAnimationCurve: Curves.easeInOutQuad  ,
    );
  }
}
