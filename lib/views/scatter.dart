import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:scouting_frontend/models/team_model.dart';

class Scatter extends StatelessWidget {
  const Scatter({
    @required this.teams,
    Key key,
  }) : super(key: key);

  final List<Team> teams;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: 350,
      // color: Colors.grey,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: teams
              .map(
                (element) => ScatterSpot(
                    element.averageShots, element.totalShotsSD,
                    radius: 5),
              )
              .toList(),

          scatterTouchData: ScatterTouchData(
            enabled: true,
            handleBuiltInTouches: false,
            touchTooltipData: ScatterTouchTooltipData(
              tooltipBgColor: Colors.black,
              getTooltipItems: (ScatterSpot touchedBarSpot) {
                return ScatterTooltipItem(
                  'X: ',
                  TextStyle(
                    height: 1.2,
                    color: Colors.grey[100],
                    fontStyle: FontStyle.italic,
                  ),
                  10,
                  children: [
                    TextSpan(
                      text: '${touchedBarSpot.x.toInt()} \n',
                      style: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          //axis formatting
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              interval: 5,
              showTitles: true,
            ),
            leftTitles: SideTitles(
              interval: 5,
              showTitles: true,
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 5,
            verticalInterval: 5,
            drawHorizontalLine: true,
            checkToShowHorizontalLine: (value) => true,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.black.withOpacity(0.1)),
            drawVerticalLine: true,
            checkToShowVerticalLine: (value) => true,
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.black.withOpacity(0.1)),
          ),
          axisTitleData: FlAxisTitleData(bottomTitle: AxisTitle()),
          borderData: FlBorderData(
            show: true,
          ),
          minX: 0,
          minY: 0,
          // maxX: 55,
          // maxY: 55,
        ),
      ),
    );
  }
}
