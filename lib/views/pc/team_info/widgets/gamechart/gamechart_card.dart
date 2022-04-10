import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/carousel_with_indicator.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/ball_line_chart.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/climb_line_chart.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/points_linechart.dart";

class Gamechart extends StatelessWidget {
  const Gamechart(this.data);
  final Team data;
  @override
  Widget build(final BuildContext context) => DashboardCard(
        title: "Game Chart",
        body: data.climbData.points[0].isEmpty
            ? Center(
                child: Container(),
              )
            : data.climbData.points[0].length == 1
                ? Text("Not enough data for line chart")
                : CarouselWithIndicator(
                    widgets: <Widget>[
                      BallLineChart(data.scoredMissedDataTele),
                      BallLineChart(data.scoredMissedDataAuto),
                      BallLineChart(data.scoredMissedDataAll),
                      PointsLineChart(data.pointsData),
                      ClimbLineChart(data.climbData),
                    ],
                  ),
      );
}
