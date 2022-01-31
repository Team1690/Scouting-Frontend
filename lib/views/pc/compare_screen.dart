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
          auto_missed
          tele_lower
          tele_upper
          tele_missed
        }
      }
    }
    matches(order_by: {match_number: asc}) {
      climb {
        title
      }
      auto_lower
      auto_upper
      auto_missed
      match_number
      tele_lower
      tele_upper
      tele_missed
    }
    name
    number
    id
  }
}
""";

class CompareTeam<E extends num> {
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
    required this.missedDataAuto,
    required this.missedDataTele,
    required this.team,
  });
  final LightTeam team;
  final double avgAutoUpperScored;
  final double autoUpperScoredPercentage;
  final double avgTeleUpperScored;
  final double teleUpperScoredPercentage;
  final double avgClimbPoints;
  final double climbPercentage;
  final CompareLineChartData<E> climbData;
  final CompareLineChartData<E> upperScoredDataTele;
  final CompareLineChartData<E> missedDataTele;
  final CompareLineChartData<E> upperScoredDataAuto;
  final CompareLineChartData<E> missedDataAuto;
}

class CompareLineChartData<E extends num> {
  CompareLineChartData({required this.points, required this.title});
  final String title;
  final List<E> points;
}

Future<SplayTreeSet<CompareTeam<E>>> fetchData<E extends num>(
  final List<int> ids,
) async {
  final GraphQLClient client = getClient();

  final QueryResult result = await client.query(
    QueryOptions(
      document: gql(query),
      variables: <String, dynamic>{
        "ids": ids,
      },
    ),
  );
  return result.mapQueryResult<SplayTreeSet<CompareTeam<E>>>(
      (final Map<String, dynamic>? data) {
    return data.mapNullable<SplayTreeSet<CompareTeam<E>>>(
          (final Map<String, dynamic> teams) {
            return SplayTreeSet<CompareTeam<E>>.from(
                (teams["team"] as List<dynamic>)
                    .map<CompareTeam<E>>((final dynamic e) {
                  final double avgAutoUpperScored = e["matches_aggregate"]
                          ["aggregate"]["avg"]["auto_upper"] as double? ??
                      0;
                  final double avgAutoMissed = e["matches_aggregate"]
                          ["aggregate"]["avg"]["auto_missed"] as double? ??
                      0;
                  final double autoUpperScorePercentage = avgAutoUpperScored /
                      (avgAutoUpperScored + avgAutoMissed) *
                      100;
                  final double avgTeleUpperScored = e["matches_aggregate"]
                          ["aggregate"]["avg"]["tele_upper"] as double? ??
                      0;
                  final double avgTeleMissed = e["matches_aggregate"]
                          ["aggregate"]["avg"]["tele_missed"] as double? ??
                      0;
                  final double teleUpperPointPercentage = (avgTeleUpperScored /
                          (avgTeleUpperScored + avgTeleMissed)) *
                      100;

                  final List<String> climbVals = (e["matches"] as List<dynamic>)
                      .map((final dynamic e) => e["climb"]["title"] as String)
                      .toList();
                  final double climbAvg = getClimbAverage(climbVals);

                  final int failedClimb = climbVals
                      .where(
                        (final String element) =>
                            element == "Failed" || element == "No attempt",
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

                  final CompareLineChartData<E> climbData =
                      CompareLineChartData<E>(
                    title: "Climb",
                    points: climbPoints.cast(),
                  );

                  final List<int> upperScoredDataTele =
                      (e["matches"] as List<dynamic>)
                          .map((final dynamic e) => e["tele_upper"] as int)
                          .toList();
                  final List<int> missedDataTele =
                      (e["matches"] as List<dynamic>)
                          .map(
                            (final dynamic e) => e["tele_missed"] as int,
                          )
                          .toList();

                  final CompareLineChartData<E> upperScoredDataTeleLineChart =
                      CompareLineChartData<E>(
                    title: "Teleop upper",
                    points: upperScoredDataTele.cast(),
                  );

                  final CompareLineChartData<E> missedDataTeleLineChart =
                      CompareLineChartData<E>(
                    title: "Teleop missed",
                    points: missedDataTele.cast(),
                  );

                  final List<int> upperScoredDataAuto =
                      (e["matches"] as List<dynamic>)
                          .map((final dynamic e) => e["auto_upper"] as int)
                          .toList();
                  final List<int> missedDataAuto =
                      (e["matches"] as List<dynamic>)
                          .map(
                            (final dynamic e) => e["auto_missed"] as int,
                          )
                          .toList();

                  final CompareLineChartData<E> upperScoredDataAutoLinechart =
                      CompareLineChartData<E>(
                    title: "Auto upper",
                    points: upperScoredDataAuto.cast(),
                  );

                  final CompareLineChartData<E> missedDataAutoLinechart =
                      CompareLineChartData<E>(
                    title: "Auto missed",
                    points: missedDataAuto.cast(),
                  );

                  return CompareTeam<E>(
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
                    missedDataAuto: missedDataAutoLinechart,
                    upperScoredDataTele: upperScoredDataTeleLineChart,
                    missedDataTele: missedDataTeleLineChart,
                  );
                }), (final CompareTeam<E> team1, final CompareTeam<E> team2) {
              return team1.team.id.compareTo(team2.team.id);
            });
          },
        ) ??
        (throw Exception("Error shoudn't happen"));
  });
}

class CompareScreen<E extends num> extends StatefulWidget {
  @override
  _CompareScreenState<E> createState() => _CompareScreenState<E>();
}

class _CompareScreenState<E extends num> extends State<CompareScreen<E>> {
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
    return FutureBuilder<SplayTreeSet<CompareTeam<E>>>(
      future: teams.isEmpty
          ? Future<SplayTreeSet<CompareTeam<E>>>(
              always(SplayTreeSet<CompareTeam<E>>()),
            )
          : fetchData<E>(teams.map((final LightTeam e) => e.id).toList()),
      builder: (
        final BuildContext context,
        final AsyncSnapshot<SplayTreeSet<CompareTeam<E>>?> snapshot,
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
                          children: List<Padding>.generate(
                            teams.length,
                            (final int index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding / 2,
                              ),
                              child: Chip(
                                label: Text(
                                  teams.elementAt(index).number.toString(),
                                ),
                                backgroundColor: colors[index],
                                onDeleted: () => setState(
                                  () => teams.remove(teams.elementAt(index)),
                                ),
                              ),
                            ),
                          ),
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
                      ),
                      SizedBox(width: defaultPadding),
                      Expanded(
                        flex: 3,
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
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 40.0,
                                            ),
                                            child: spiderChartWidget(
                                              snapshot.data!,
                                            ),
                                          ),
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

Widget spiderChartWidget<E extends num>(
  final SplayTreeSet<CompareTeam<E>> data,
) {
  final Iterable<CompareTeam<E>> emptyTeams = data
      .where((final CompareTeam<E> team) => team.climbData.points.length < 2);

  return emptyTeams.isNotEmpty
      ? Container()
      : Builder(
          builder: (final BuildContext context) {
            final double autoRatio = 100 /
                data
                    .map(
                      (final CompareTeam<E> e) => e.avgAutoUpperScored,
                    )
                    .reduce(max);
            final double teleRatio = 100 /
                data
                    .map(
                      (final CompareTeam<E> e) => e.avgTeleUpperScored,
                    )
                    .reduce(max);
            final double climbPointsRatio = 100 /
                data
                    .map(
                      (final CompareTeam<E> e) => e.avgClimbPoints,
                    )
                    .reduce(max);
            return SpiderChart(
              numberOfFeatures: 6,
              data: data
                  .map<List<int>>(
                    (final CompareTeam<E> e) => <int>[
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
                "Auto upper",
                "Auto scoring%",
                "Teleop upper",
                "Teleop scoring%",
                "Climb points",
                "Climb%"
              ],
            );
          },
        );
}

Widget lineChart<E extends num>(final List<CompareLineChartData<E>> data) =>
    Stack(
      children: <Widget>[
        Align(
          alignment: Alignment(-1, -1),
          child: Text(data[0].title),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            top: 40,
          ),
          child: DashboardLineChart<E>(
            distanceFromHighest: 4,
            dataSet: data
                .map(
                  (final CompareLineChartData<E> e) => e.points,
                )
                .toList(),
          ),
        ),
      ],
    );

Widget climbLineChart<E extends num>(
  final List<CompareLineChartData<E>> data,
) =>
    Stack(
      children: <Widget>[
        Align(
          alignment: Alignment(-1, -1),
          child: Text(data[0].title),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 20.0,
            left: 40.0,
            right: 20.0,
            top: 40,
          ),
          child: DashBoardClimbLineChart<E>(
            dataSet: data
                .map(
                  (final CompareLineChartData<E> e) => e.points,
                )
                .toList(),
          ),
        ),
      ],
    );

Widget gameChartWidget<E extends num>(final SplayTreeSet<CompareTeam<E>> data) {
  final Iterable<CompareTeam<E>> emptyTeams = data.where(
    (final CompareTeam<E> element) => element.climbData.points.length < 2,
  );
  return emptyTeams.isNotEmpty
      ? Text(
          "teams: ${emptyTeams.map((final CompareTeam<E> e) => e.team.number).toString()} have insufficient data please remove them",
        )
      : Builder(
          builder: (
            final BuildContext context,
          ) {
            final List<CompareLineChartData<E>> teleScored =
                <CompareLineChartData<E>>[];

            final List<CompareLineChartData<E>> teleMissed =
                <CompareLineChartData<E>>[];

            final List<CompareLineChartData<E>> climb =
                <CompareLineChartData<E>>[];

            final List<CompareLineChartData<E>> autoScored =
                <CompareLineChartData<E>>[];

            final List<CompareLineChartData<E>> autoMissed =
                <CompareLineChartData<E>>[];
            for (final CompareTeam<E> item in data) {
              if ((item.climbData.points.length > 1)) {
                teleScored.add(
                  item.upperScoredDataTele,
                );
                teleMissed.add(
                  item.missedDataTele,
                );
                autoScored.add(
                  item.upperScoredDataAuto,
                );
                autoMissed.add(
                  item.missedDataAuto,
                );
                climb.add(item.climbData);
              }
            }
            int longestList = -1;
            for (final CompareLineChartData<E> element in climb) {
              longestList = max(
                longestList,
                element.points.length,
              );
            }
            return CarouselWithIndicator(
              widgets: <Widget>[
                lineChart(autoScored),
                lineChart(autoMissed),
                lineChart(teleScored),
                lineChart(teleMissed),
                climbLineChart(climb)
              ],
            );
          },
        );
}
