import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/carousel_with_indicator.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/dashboard_linechart.dart";
import "package:scouting_frontend/views/pc/team_info/models/fetch_team_info.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/balance_line_chart.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/gamepiece_line_chart.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/points_linechart.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/pit/pit_scouting_card.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/quick_data/quick_data.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/specific/specific_card.dart";

class CoachTeamData extends StatelessWidget {
  const CoachTeamData(this.team);
  final LightTeam team;
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "${team.number} ${team.name}",
        ),
      ),
      body: FutureBuilder<Team>(
        future: fetchTeamInfo(team, context), //fetchTeam(team.id, context),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<Team> snapshot,
        ) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return snapshot.data.mapNullable((final Team data) {
                  return CarouselWithIndicator(
                    enableInfininteScroll: true,
                    initialPage: 0,
                    widgets: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DashboardCard(
                          title: "Line charts",
                          body: data.autoBalanceData.points[0].length < 2
                              ? Center(
                                  child: Text("No data :("),
                                )
                              : CoachTeamInfoLineCharts(data),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DashboardCard(
                          title: "Specific",
                          body: data.specificData.msg.isEmpty
                              ? Center(
                                  child: Text("No data :("),
                                )
                              : SpecificCard(data.specificData),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DashboardCard(
                          title: "Quick data",
                          body: CoachQuickData(data.quickData),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: data.pitViewData.mapNullable(
                              PitScoutingCard.new,
                            ) ??
                            DashboardCard(
                              title: "Pit scouting",
                              body: Center(
                                child: Text("No data"),
                              ),
                            ),
                      )
                    ],
                  );
                }) ??
                (throw Exception("No data"));
          }
        },
      ),
    );
  }
}

class CoachTeamInfoLineCharts extends StatelessWidget {
  CoachTeamInfoLineCharts(this.data);
  final Team data;
  @override
  Widget build(final BuildContext context) => CarouselWithIndicator(
        direction: Axis.vertical,
        enableInfininteScroll: true,
        widgets: <Widget>[
          CoachTeamInfoLineChart(
            GamepiecesLineChart(data.scoredMissedDataAutoCones),
            "Auto Cones",
          ),
          CoachTeamInfoLineChart(
            GamepiecesLineChart(data.scoredMissedDataTeleCones),
            "Tele Cones",
          ),
          CoachTeamInfoLineChart(
            GamepiecesLineChart(data.scoredMissedDataAutoCubes),
            "Auto Cubes",
          ),
          CoachTeamInfoLineChart(
            GamepiecesLineChart(data.scoredMissedDataTeleCubes),
            "Tele Cubes",
          ),
          CoachTeamInfoLineChart(
            GamepiecesLineChart(data.scoredMissedDataAll),
            "Gamepieces",
          ),
          CoachTeamInfoLineChart(
            PointsLineChart(data.pointsData),
            "Points",
          ),
          CoachTeamInfoLineChart(
            BalanceLineChart(data.autoBalanceData),
            "Auto Balance",
          ),
          CoachTeamInfoLineChart(
            BalanceLineChart(data.endgameBalanceData),
            "Endgame Balance",
          ),
        ],
      );
}

class CoachTeamInfoLineChart extends StatelessWidget {
  const CoachTeamInfoLineChart(this.linechart, this.title);
  final Widget linechart;
  final String title;

  @override
  Widget build(final BuildContext context) => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Text(title),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              margin: const EdgeInsets.only(left: 25, top: 8.0),
              child: linechart,
            ),
          ),
          Spacer()
        ],
      );
}

class CoachQuickData extends StatelessWidget {
  const CoachQuickData(this.data);
  final QuickData data;

  @override
  Widget build(final BuildContext context) => data.amoutOfMatches == 0
      ? Center(child: Text("No data :("))
      : Column(
          children: <Widget>[
            Spacer(),
            Row(
              children: <Expanded>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Auto",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      gamepieceRow(
                        "Top",
                        data.avgAutoConesTop,
                        data.avgAutoCubesTop,
                      ),
                      gamepieceRow(
                        "Mid",
                        data.avgAutoConesMid,
                        data.avgAutoCubesMid,
                      ),
                      gamepieceRow(
                        "Low",
                        data.avgAutoConesLow,
                        data.avgAutoCubesLow,
                      ),
                      gamepieceRow(
                        "Failed",
                        data.avgAutoConesFailed,
                        data.avgAutoCubesFailed,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Points",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Text(
                        "Gamepieces: ${data.avgGamepiecePoints.toStringAsFixed(1)}",
                      ),
                      Text(
                        "Auto Balance: ${data.avgAutoBalancePoints.toStringAsFixed(1)}/${data.matchesBalancedAuto}/${data.amoutOfMatches}",
                      ),
                      Text(
                        "Endgame Balance: ${data.avgEndgameBalancePoints.toStringAsFixed(1)}/${data.matchesBalancedEndgame}/${data.amoutOfMatches}",
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Picklist",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Text("First: ${data.firstPicklistIndex + 1}"),
                      Text("Second: ${data.secondPicklistIndex + 1}"),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Teleop",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      gamepieceRow(
                        "Top",
                        data.avgTeleConesTop,
                        data.avgTeleCubesTop,
                      ),
                      gamepieceRow(
                        "Mid",
                        data.avgTeleConesMid,
                        data.avgTeleCubesMid,
                      ),
                      gamepieceRow(
                        "Low",
                        data.avgTeleConesLow,
                        data.avgTeleCubesLow,
                      ),
                      gamepieceRow(
                        "Failed",
                        data.avgTeleConesFailed,
                        data.avgTeleCubesFailed,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Aim",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Text(
                        "Auto: ${data.avgAutoGamepieces.toStringAsFixed(1)}/${(data.avgAutoGamepieces + data.avgAutoConesFailed + data.avgAutoCubesFailed).toStringAsFixed(1)}",
                      ),
                      Text(
                        "Teleop: ${data.avgTeleGamepieces.toStringAsFixed(1)}/${(data.avgTeleGamepieces + data.avgTeleConesFailed + data.avgTeleCubesFailed).toStringAsFixed(1)}",
                      ),
                      Text(
                        "Misc",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        "Gamepiece sum: ${data.avgGamepieces.toStringAsFixed(1)}",
                      ),
                      Text(
                        "Best Auto Balance: ${data.highestBalanceTitleAuto}",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Spacer(
              flex: 2,
            )
          ],
        );
}
