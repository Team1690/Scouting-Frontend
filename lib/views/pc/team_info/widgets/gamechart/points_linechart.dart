import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/dashboard_linechart.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class PointsLineChart extends StatelessWidget {
  const PointsLineChart(this.data);
  final LineChartData data;

  @override
  Widget build(final BuildContext context) => Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              data.title,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              top: 40,
            ),
            child: DashboardLineChart(
              sideTitlesInterval: 10,
              showShadow: true,
              gameNumbers: data.gameNumbers,
              inputedColors: const <Color>[
                Colors.green,
              ],
              distanceFromHighest: 20,
              dataSet: data.points,
              robotMatchStatuses: data.robotMatchStatuses,
              defenseAmounts: data.defenseAmounts,
            ),
          ),
        ],
      );
}
