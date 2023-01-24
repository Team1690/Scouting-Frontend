import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/carousel_with_indicator.dart";
import "package:scouting_frontend/views/common/dashboard_linechart.dart";
import "package:scouting_frontend/views/pc/team_info/models/fetch_team_info.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/pit/pit_scouting_card.dart";
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
                          body: data.climbData.points[0].length < 2
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
            DashboardLineChart(
              showShadow: true,
              gameNumbers: data.scoredMissedDataTele.gameNumbers,
              distanceFromHighest: 4,
              dataSet: data.scoredMissedDataTele.points,
              robotMatchStatuses: data.scoredMissedDataTele.robotMatchStatuses,
              inputedColors: <Color>[
                Colors.green,
                Colors.red,
                Colors.yellow[700]!
              ],
            ),
            "Teleop",
          ),
          CoachTeamInfoLineChart(
            DashboardLineChart(
              showShadow: true,
              gameNumbers: data.scoredMissedDataAuto.gameNumbers,
              robotMatchStatuses: data.scoredMissedDataAuto.robotMatchStatuses,
              distanceFromHighest: 4,
              dataSet: data.scoredMissedDataAuto.points,
              inputedColors: <Color>[
                Colors.green,
                Colors.red,
                Colors.yellow[700]!
              ],
            ),
            "Autonomous",
          ),
          CoachTeamInfoLineChart(
            DashboardLineChart(
              showShadow: true,
              gameNumbers: data.scoredMissedDataAll.gameNumbers,
              robotMatchStatuses: data.scoredMissedDataAll.robotMatchStatuses,
              distanceFromHighest: 4,
              dataSet: data.scoredMissedDataAll.points,
              inputedColors: <Color>[
                Colors.green,
                Colors.red,
                Colors.yellow[700]!
              ],
            ),
            "Balls",
          ),
          CoachTeamInfoLineChart(
            DashboardClimbLineChart(
              showShadow: true,
              inputedColors: <Color>[Color(0xFF2697FF)],
              gameNumbers: data.climbData.gameNumbers,
              dataSet: data.climbData.points,
              robotMatchStatuses: data.climbData.robotMatchStatuses,
            ),
            "Climb",
          )
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
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Auto",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Text(
                        "Upper: ${data.avgAutoUpperScored.toStringAsFixed(1)}",
                        style: TextStyle(color: Colors.green[300]),
                      ),
                      Text(
                        "Lower: ${data.avgAutoLowScored.toStringAsFixed(1)}",
                        style: TextStyle(color: Colors.yellow),
                      ),
                      Text(
                        "Missed: ${data.avgAutoMissed.toStringAsFixed(1)}",
                        style: TextStyle(color: Colors.red),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Points",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Text("Balls: ${data.avgBallPoints.toStringAsFixed(1)}"),
                      Text(
                        "Climb: ${data.avgClimbPoints.toStringAsFixed(1)}/${data.matchesClimbed}/${data.amoutOfMatches}",
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
                      Text(
                        "Upper: ${data.avgTeleUpperScored.toStringAsFixed(1)}",
                        style: TextStyle(color: Colors.green[300]),
                      ),
                      Text(
                        "Lower: ${data.avgTeleLowScored.toStringAsFixed(1)}",
                        style: TextStyle(color: Colors.yellow),
                      ),
                      Text(
                        "Missed: ${data.avgTeleMissed.toStringAsFixed(1)}",
                        style: TextStyle(color: Colors.red),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Aim",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Text(
                        "Auto: ${(data.avgAutoUpperScored + data.avgAutoLowScored).toStringAsFixed(1)}/${(data.avgAutoUpperScored + data.avgAutoLowScored + data.avgAutoMissed).toStringAsFixed(1)}",
                      ),
                      Text(
                        "Teleop: ${(data.avgTeleUpperScored + data.avgTeleLowScored).toStringAsFixed(1)}/${(data.avgTeleUpperScored + data.avgTeleLowScored + data.avgTeleMissed).toStringAsFixed(1)}",
                      ),
                      Text(
                        "Misc",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        "Ball sum: ${(data.avgAutoLowScored + data.avgAutoUpperScored + data.avgTeleLowScored + data.avgTeleUpperScored).toStringAsFixed(1)}",
                      ),
                      Text(
                        "Best climb: ${data.highestLevelTitle}",
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
