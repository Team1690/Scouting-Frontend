import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/dashboard_linechart.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class ClimbLineChart extends StatelessWidget {
  const ClimbLineChart(this.data);

  final LineChartData data;
  @override
  Widget build(final BuildContext context) => Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(-1, -1),
            child: Text(data.title),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
              left: 40.0,
              right: 20.0,
              top: 40,
            ),
            child: DashboardClimbLineChart(
              showShadow: true,
              inputedColors: <Color>[Color(0xFF2697FF)],
              gameNumbers: data.gameNumbers,
              dataSet: data.points,
              robotMatchStatuses: data.robotMatchStatuses,
            ),
          ),
        ],
      );
}
