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
    String tooltip = '';
    return Container(
      // color: Colors.grey,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: teams
              .map(
                (element) => ScatterSpot(
                    element.averageShots.toDouble(), element.totalShotsSD,
                    radius: 5),
              )
              .toList(),

          scatterTouchData: ScatterTouchData(
            touchCallback: (p0) => {
              p0.touchedSpot != null
                  ? tooltip =
                      teams[p0.touchedSpot.spotIndex].teamNumber.toString()
                  : tooltip = '',
            },
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: ScatterTouchTooltipData(
              tooltipBgColor: Colors.grey[400],
              getTooltipItems: (ScatterSpot touchedBarSpot) {
                return ScatterTooltipItem(tooltip, TextStyle(), 10);
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
          maxX: 100,
          maxY: 100,
        ),
      ),
    );
  }
}
