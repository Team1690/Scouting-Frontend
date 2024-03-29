import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/gamepiece_line_chart.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/balance_line_chart.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/points_linechart.dart";
import "package:orbit_standard_library/orbit_standard_library.dart";

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
                ? const Text("Not enough data for line chart")
                : CarouselWithIndicator(
                    widgets: <Widget>[
                      GamepiecesLineChart(data.allData),
                      GamepiecesLineChart(data.autoConesData),
                      GamepiecesLineChart(data.teleConesData),
                      GamepiecesLineChart(data.autoCubesData),
                      GamepiecesLineChart(data.teleCubesData),
                      PointsLineChart(data.gamepiecePointsData),
                      BalanceLineChart(data.autoBalanceData),
                      BalanceLineChart(data.endgameBalanceData),
                    ],
                  ),
      );
}
