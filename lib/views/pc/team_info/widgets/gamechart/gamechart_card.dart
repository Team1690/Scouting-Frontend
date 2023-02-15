import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/carousel_with_indicator.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/gamepiece_line_chart.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/balance_line_chart.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/points_linechart.dart";

class Gamechart extends StatelessWidget {
  const Gamechart(this.data);
  final Team data;
  @override
  Widget build(final BuildContext context) => DashboardCard(
        title: "Game Chart",
        body: data.autoBalanceData.points[0].isEmpty
            ? Center(
                child: Container(),
              )
            : data.autoBalanceData.points[0].length == 1
                ? Text("Not enough data for line chart")
                : CarouselWithIndicator(
                    widgets: <Widget>[
                      BallLineChart(data.scoredMissedDataAutoCones),
                      BallLineChart(data.scoredMissedDataTeleCones),
                      BallLineChart(data.scoredMissedDataAutoCubes),
                      BallLineChart(data.scoredMissedDataTeleCubes),
                      BallLineChart(data.scoredMissedDataAll),
                      PointsLineChart(data.pointsData),
                      ClimbLineChart(data.autoBalanceData),
                      ClimbLineChart(data.endgameBalanceData),
                    ],
                  ),
      );
}
