import "package:flutter/material.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/team_info_line_chart.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class ClimbLineChart<E extends num> extends StatelessWidget {
  const ClimbLineChart(this.data);

  final LineChartData<E> data;
  @override
  Widget build(final BuildContext context) => Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(-1, -1),
            child: Text(data.title),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 40.0,
              left: 40.0,
              right: 20.0,
              top: 40,
            ),
            child: DashboardClimbLineChart<E>(
              matchNumbers: data.gameNumbers,
              dataSet: data.points,
            ),
          ),
        ],
      );
}
