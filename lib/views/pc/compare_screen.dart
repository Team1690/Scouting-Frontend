import "dart:collection";
import "dart:math";

import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/team_selection_future.dart";
import "package:scouting_frontend/views/pc/team_info_screen.dart";
import "package:scouting_frontend/views/pc/widgets/card.dart";
import "package:scouting_frontend/views/pc/widgets/carousel_with_indicator.dart";
import "package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart";
import "package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart";
import "package:scouting_frontend/views/pc/widgets/radar_chart.dart";
import "package:scouting_frontend/views/pc/widgets/team_info_data.dart";
import "package:scouting_frontend/models/map_nullable.dart";

const String query = """
query MyQuery(\$ids: [Int!]) {
  team(where: {id: {_in: \$ids}}) {
    matches_aggregate {
      aggregate {
        avg {
          auto_lower
          auto_upper
          auto_upper_missed
          tele_lower
          tele_upper
          tele_upper_missed
        }
      }
    }
    matches(order_by: {match_number: asc}) {
      climb {
        title
      }
      auto_lower
      auto_upper
      auto_upper_missed
      match_number
      tele_lower
      tele_upper
      tele_upper_missed
    }
    name
    number
    id
  }
}
""";

class CompareTeam {
  CompareTeam({
    required this.autoUpperScoredPercentage,
    required this.avgAutoUpperScored,
    required this.avgClimbPoints,
    required this.avgTeleUpperScored,
    required this.climbPercentage,
    required this.teleUpperScoredPercentage,
    required this.climbData,
    required this.upperScoredDataAuto,
    required this.upperScoredDataTele,
    required this.upperMissedDataAuto,
    required this.upperMissedDataTele,
    required this.team,
  });
  final LightTeam team;
  final double avgAutoUpperScored;
  final double autoUpperScoredPercentage;
  final double avgTeleUpperScored;
  final double teleUpperScoredPercentage;
  final double avgClimbPoints;
  final double climbPercentage;
  final CompareLineChartData climbData;
  final CompareLineChartData upperScoredDataTele;
  final CompareLineChartData upperMissedDataTele;
  final CompareLineChartData upperScoredDataAuto;
  final CompareLineChartData upperMissedDataAuto;
}

class CompareLineChartData {
  CompareLineChartData({required this.points});

  List<int> points;
}

Future<SplayTreeSet<CompareTeam>> fetchData(final List<int> ids) async {
  final GraphQLClient client = getClient();

  final QueryResult result = await client.query(
    QueryOptions(
      document: gql(query),
      variables: <String, dynamic>{
        "ids": ids,
      },
    ),
  );
  return result.mapQueryResult<SplayTreeSet<CompareTeam>>(
      (final Map<String, dynamic>? data) {
    return data.mapNullable<SplayTreeSet<CompareTeam>>(
          (final Map<String, dynamic> teams) {
            return SplayTreeSet<CompareTeam>.from(
                (teams["team"] as List<dynamic>)
                    .map<CompareTeam>((final dynamic e) {
                  final double avgAutoUpperScored = e["matches_aggregate"]
                          ["aggregate"]["avg"]["auto_upper"] as double? ??
                      0;
                  final double avgAutoUpperMissed = e["matches_aggregate"]
                              ["aggregate"]["avg"]["auto_upper_missed"]
                          as double? ??
                      0;
                  final double autoUpperScorePercentage = avgAutoUpperScored /
                      (avgAutoUpperScored + avgAutoUpperMissed) *
                      100;
                  final double avgTeleUpperScored = e["matches_aggregate"]
                          ["aggregate"]["avg"]["tele_upper"] as double? ??
                      0;
                  final double avgTeleUpperMissed = e["matches_aggregate"]
                              ["aggregate"]["avg"]["tele_upper_missed"]
                          as double? ??
                      0;
                  final double teleUpperPointPercentage = (avgTeleUpperScored /
                          (avgTeleUpperScored + avgTeleUpperMissed)) *
                      100;

                  final List<String> climbVals = (e["matches"] as List<dynamic>)
                      .map((final dynamic e) => e["climb"]["title"] as String)
                      .toList();
                  final double climbAvg = getClimbAverage(climbVals);

                  final int failedClimb = climbVals
                      .where(
                        (final String element) =>
                            element == "failed" || element == "no attempt",
                      )
                      .length;
                  final int succededClimb = climbVals.length - failedClimb;

                  final double climbSuccessPercent =
                      (succededClimb / (succededClimb + failedClimb)) * 100;
                  final List<int> climbPoints =
                      climbVals.map<int>((final String e) {
                    switch (e) {
                      case "Failed":
                        return 0;
                      case "No attempt":
                        return -1;
                      case "Level 1":
                        return 1;
                      case "Level 2":
                        return 2;
                      case "Level 3":
                        return 3;
                      case "Level 4":
                        return 4;
                    }
                    throw Exception("Not a climb value");
                  }).toList();

                  final CompareLineChartData climbData = CompareLineChartData(
                    points: climbPoints,
                  );

                  final List<int> upperScoredDataTele =
                      (e["matches"] as List<dynamic>)
                          .map((final dynamic e) => e["tele_upper"] as int)
                          .toList();
                  final List<int> upperMissedDataTele =
                      (e["matches"] as List<dynamic>)
                          .map(
                            (final dynamic e) => e["tele_upper_missed"] as int,
                          )
                          .toList();

                  final CompareLineChartData upperScoredDataTeleLineChart =
                      CompareLineChartData(
                    points: upperScoredDataTele,
                  );

                  final CompareLineChartData upperMissedDataTeleLineChart =
                      CompareLineChartData(
                    points: upperMissedDataTele,
                  );

                  final List<int> upperScoredDataAuto =
                      (e["matches"] as List<dynamic>)
                          .map((final dynamic e) => e["auto_upper"] as int)
                          .toList();
                  final List<int> upperMissedDataAuto =
                      (e["matches"] as List<dynamic>)
                          .map(
                            (final dynamic e) => e["auto_upper_missed"] as int,
                          )
                          .toList();

                  final CompareLineChartData upperScoredDataAutoLinechart =
                      CompareLineChartData(
                    points: upperScoredDataAuto,
                  );

                  final CompareLineChartData upperMissedDataAutoLinechart =
                      CompareLineChartData(
                    points: upperMissedDataAuto,
                  );

                  return CompareTeam(
                    team: LightTeam(
                      e["id"] as int,
                      e["number"] as int,
                      e["name"] as String,
                    ),
                    autoUpperScoredPercentage: autoUpperScorePercentage,
                    avgAutoUpperScored: avgAutoUpperScored,
                    avgClimbPoints: climbAvg,
                    avgTeleUpperScored: avgTeleUpperScored,
                    climbPercentage: climbSuccessPercent,
                    teleUpperScoredPercentage: teleUpperPointPercentage,
                    climbData: climbData,
                    upperScoredDataAuto: upperScoredDataAutoLinechart,
                    upperMissedDataAuto: upperMissedDataAutoLinechart,
                    upperScoredDataTele: upperScoredDataTeleLineChart,
                    upperMissedDataTele: upperMissedDataTeleLineChart,
                  );
                }), (final CompareTeam team1, final CompareTeam team2) {
              return team1.team.id.compareTo(team2.team.id);
            });
          },
        ) ??
        (throw Exception("Error shoudn't happen"));
  });
}

class CompareScreen extends StatefulWidget {
  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final SplayTreeSet<LightTeam> teams = SplayTreeSet<LightTeam>(
    (final LightTeam p0, final LightTeam p1) => p0.id.compareTo(p1.id),
  );
  final TextEditingController controller = TextEditingController();
  void removeTeam(final MapEntry<int, LightTeam> index) {
    teams.removeWhere(
      (final LightTeam entry) => entry.number == index.value.number,
    );
    controller.value = TextEditingValue.empty;
  }

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<SplayTreeSet<CompareTeam>>(
      future: teams.isEmpty
          ? Future<SplayTreeSet<CompareTeam>>(
              always(SplayTreeSet<CompareTeam>()),
            )
          : fetchData(teams.map((final LightTeam e) => e.id).toList()),
      builder: (
        final BuildContext context,
        final AsyncSnapshot<SplayTreeSet<CompareTeam>?> snapshot,
      ) {
        if (snapshot.hasError) {
          return DashboardScaffold(body: Text(snapshot.error!.toString()));
        }
        return DashboardScaffold(
          body: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TeamSelectionFuture(
                          onChange: (final LightTeam team) {
                            if (teams.contains(team)) return;
                            setState(() {
                              teams.add(
                                team,
                              );
                            });
                          },
                          controller: controller,
                        ),
                      ),
                      SizedBox(width: defaultPadding),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: teams
                              .toList()
                              .asMap()
                              .entries
                              .map(
                                (final MapEntry<int, LightTeam> index) =>
                                    Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: defaultPadding / 2,
                                  ),
                                  child: Chip(
                                    label: Text(
                                      index.value.number.toString(),
                                    ),
                                    backgroundColor: colors[index.key],
                                    onDeleted: () =>
                                        setState(() => removeTeam(index)),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ToggleButtons(
                          children: <Widget>[
                            Icon(Icons.shield_rounded),
                            Icon(Icons.remove_moderator_outlined),
                          ],
                          isSelected: <bool>[false, false],
                          //Currently unused feature
                          onPressed: (final int index) {},
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: defaultPadding),
                Expanded(
                  flex: 5,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: DashboardCard(
                                title: "Game Chart",
                                body: teams.isEmpty || snapshot.data == null
                                    ? noTeamSelected()
                                    : !(snapshot.connectionState ==
                                            ConnectionState.waiting)
                                        ? gameChartWidget(snapshot.data!)
                                        : Center(
                                            child: CircularProgressIndicator(),
                                          ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: defaultPadding),
                      Expanded(
                        flex: 2,
                        child: DashboardCard(
                          title: "Compare Spider Chart",
                          body: Builder(
                            builder: (final BuildContext context) {
                              return Center(
                                child: teams.isEmpty || snapshot.data == null
                                    ? Container()
                                    : snapshot.connectionState ==
                                            ConnectionState.waiting
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : spiderChartWidget(snapshot.data!),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget spiderChartWidget(final SplayTreeSet<CompareTeam> data) {
  final Iterable<CompareTeam> emptyTeams =
      data.where((final CompareTeam team) => team.climbData.points.length < 2);

  return emptyTeams.isNotEmpty
      ? Container()
      : Builder(
          builder: (final BuildContext context) {
            final double autoRatio = 100 /
                data
                    .map(
                      (final CompareTeam e) => e.avgAutoUpperScored,
                    )
                    .reduce(max);
            final double teleRatio = 100 /
                data
                    .map(
                      (final CompareTeam e) => e.avgTeleUpperScored,
                    )
                    .reduce(max);
            final double climbPointsRatio = 100 /
                data
                    .map(
                      (final CompareTeam e) => e.avgClimbPoints,
                    )
                    .reduce(max);

            return SpiderChart(
              numberOfFeatures: 6,
              data: data
                  .map<List<int>>(
                    (final CompareTeam e) => <int>[
                      (e.avgAutoUpperScored * autoRatio).toInt(),
                      e.autoUpperScoredPercentage.toInt(),
                      (e.avgTeleUpperScored * teleRatio).toInt(),
                      e.teleUpperScoredPercentage.toInt(),
                      (e.avgClimbPoints * climbPointsRatio).toInt(),
                      e.climbPercentage.toInt()
                    ],
                  )
                  .toList(),
              ticks: <int>[0, 25, 50, 75, 100],
              features: <String>[
                "auto upper",
                "auto scoring%",
                "teleop upper",
                "teleop scoring%",
                "climb points",
                "climb%"
              ],
            );
          },
        );
}

Widget gameChartWidget(final SplayTreeSet<CompareTeam> data) {
  final Iterable<CompareTeam> emptyTeams = data.where(
    (final CompareTeam element) => element.climbData.points.length < 2,
  );
  return emptyTeams.isNotEmpty
      ? Text(
          "teams: ${emptyTeams.map((final CompareTeam e) => e.team.number).toString()} have insufficient data please remove them",
        )
      : Builder(
          builder: (
            final BuildContext context,
          ) {
            final List<CompareLineChartData> teleScored =
                <CompareLineChartData>[];

            final List<CompareLineChartData> teleMissed =
                <CompareLineChartData>[];

            final List<CompareLineChartData> climb = <CompareLineChartData>[];

            final List<CompareLineChartData> autoScored =
                <CompareLineChartData>[];

            final List<CompareLineChartData> autoMissed =
                <CompareLineChartData>[];
            for (final CompareTeam item in data) {
              if ((item.climbData.points.length > 1)) {
                teleScored.add(
                  item.upperScoredDataTele,
                );
                teleMissed.add(
                  item.upperMissedDataTele,
                );
                autoScored.add(
                  item.upperScoredDataAuto,
                );
                autoMissed.add(
                  item.upperMissedDataAuto,
                );
                climb.add(item.climbData);
              }
            }
            int longestList = -1;
            for (final CompareLineChartData element in climb) {
              longestList = max(
                longestList,
                element.points.length,
              );
            }
            if (longestList < 2) {
              return Text(
                "Can't show team with less than 2 entries :(",
              );
            }
            return CarouselWithIndicator(
              widgets: <Widget>[
                Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment(-1, -1),
                      child: Text(
                        "Auto upper scored",
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
                        distanceFromHighest: 4,
                        dataSet: autoScored
                            .map(
                              (
                                final CompareLineChartData e,
                              ) =>
                                  e.points,
                            )
                            .map(
                              (final List<int> e) =>
                                  e.map((final int e) => e.toDouble()).toList(),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment(-1, -1),
                      child: Text(
                        "Auto upper missed",
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
                        distanceFromHighest: 4,
                        dataSet: autoMissed
                            .map(
                              (
                                final CompareLineChartData e,
                              ) =>
                                  e.points,
                            )
                            .map(
                              (final List<int> e) =>
                                  e.map((final int e) => e.toDouble()).toList(),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment(-1, -1),
                      child: Text(
                        "Teleop upper scored",
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
                        distanceFromHighest: 4,
                        dataSet: teleScored
                            .map(
                              (
                                final CompareLineChartData e,
                              ) =>
                                  e.points,
                            )
                            .map(
                              (final List<int> e) =>
                                  e.map((final int e) => e.toDouble()).toList(),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment(-1, -1),
                      child: Text(
                        "Tele upper missed",
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
                        distanceFromHighest: 4,
                        dataSet: teleMissed
                            .map(
                              (
                                final CompareLineChartData e,
                              ) =>
                                  e.points,
                            )
                            .map(
                              (final List<int> e) =>
                                  e.map((final int e) => e.toDouble()).toList(),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment(-1, -1),
                      child: Text("Climb"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 40.0,
                        left: 40.0,
                        right: 20.0,
                        top: 40,
                      ),
                      child: DashBoardClimbLineChart(
                        dataSet: climb
                            .map(
                              (
                                final CompareLineChartData e,
                              ) =>
                                  e.points,
                            )
                            .map(
                              (final List<int> e) =>
                                  e.map((final int e) => e.toDouble()).toList(),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        );
}
