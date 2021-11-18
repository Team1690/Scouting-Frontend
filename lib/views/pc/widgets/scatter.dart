import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:scouting_frontend/models/team_model.dart';

class Scatter extends StatelessWidget {
  const Scatter({
    @required this.teams,
    @required this.onHover,
    Key key,
  }) : super(key: key);

  final List<Team> teams;
  final Function(Team team) onHover;

  @override
  Widget build(BuildContext context) {
    Team selectedTeam;
    String tooltip;
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
              if (p0.touchedSpot != null)
                {
                  // onHover(teams[p0.touchedSpot.spotIndex]),
                  p0.clickHappened
                      ? onHover(teams[p0.touchedSpot.spotIndex])
                      : null,
                  // selectedTeam = teams[p0.touch  edSpot.spotIndex],
                  tooltip =
                      teams[p0.touchedSpot.spotIndex].teamNumber.toString(),
                  // inspect(p0),
                  // print(teams[p0.touchedSpot.spotIndex].teamNumber),
                }
            },
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: ScatterTouchTooltipData(
              tooltipBgColor: Colors.grey[400],
              getTooltipItems: (ScatterSpot touchedBarSpot) {
                // print(selectedTeam.teamNumber);
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
