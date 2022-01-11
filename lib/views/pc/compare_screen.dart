import "dart:math";

import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/team_selection_future.dart";
import "package:scouting_frontend/views/pc/widgets/card.dart";
import "package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart";
import "package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart";
import "package:scouting_frontend/views/pc/widgets/radar_chart.dart";

// ignore: must_be_immutable
class CompareScreen extends StatefulWidget {
  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class LineChartData {
  LineChartData({required this.points});
  List<double> points;
}

class _CompareScreenState extends State<CompareScreen> {
  TextEditingController controller = TextEditingController();
  List<LightTeam> compareTeamsList = <LightTeam>[];
  // List tables;

  Future<List<LineChartData>> fetchMatch(final int teamNumber) async {
    final GraphQLClient client = getClient();
    final String query = """
query fetchGameChart(\$teamNumber : Int) {
  team(where: {number: {_eq: \$teamNumber}}) {
    matches(order_by: {number: asc}) {
      teleop_inner
      teleop_outer
      auto_balls
    }
  }
}

""";

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: <String, int>{"teamNumber": teamNumber},
      ),
    );
    final List<dynamic> matches = result.mapQueryResult(
      (final Map<String, dynamic>? data) =>
          data.mapNullable<List<dynamic>>(
            (final Map<String, dynamic> team) =>
                team["team"][0]["matches"] as List<dynamic>,
          ) ??
          <dynamic>[],
    );

    return <LineChartData>[
      LineChartData(
        points: matches
            .map<double>((final dynamic e) => e["teleop_inner"] as double)
            .toList(),
      ),
      LineChartData(
        points: matches
            .map<double>((final dynamic e) => e["teleop_outer"] as double)
            .toList(),
      ),
      LineChartData(
        points: matches
            .map<double>((final dynamic e) => e["auto_balls"] as double)
            .toList(),
      ),
    ];
  }

  Future<List<List<LineChartData>>> fetchMatches(
    final List<int> teamnumbers,
  ) async {
    return Future.wait(teamnumbers.map(fetchMatch).toList());
  }

  Future<List<Team>> fetchGameCharts(final List<int> teamId) async {
    return Future.wait(teamId.map(fetchGameChart));
  }

  Future<Team> fetchGameChart(final int teamId) async {
    final GraphQLClient client = getClient();
    final String query = """
query MyQuery(\$team_id: Int) {
  team(where: {id: {_eq: \$team_id}}) {
    matches_aggregate {
      aggregate {
        avg {
          auto_balls
          teleop_inner
          teleop_outer
        }
        count(columns: id)
      }
    }
    matches {
      auto_balls
      teleop_inner
      teleop_outer
      climb_id
    }
    climbSuccess: matches_aggregate(where: {climb: {name: {_eq: "Succeeded"}}}) {
      aggregate {
        count(columns: climb_id)
      }
    }
    climbFail: matches_aggregate(where: {climb: {name: {_eq: "failed"}}}) {
      aggregate {
        count(columns: climb_id)
      }
    }
    name
    number
  }
}

  """;

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: <String, dynamic>{"team_id": teamId},
      ),
    );

    return result.mapQueryResult(
      (final Map<String, dynamic>? data) =>
          data.mapNullable(
            (final Map<String, dynamic> team) => Team(
              teamName: team["team"][0]["name"] as String,
              teamNumber: team["team"][0]["number"] as int,
              autoGoalAverage: team["team"][0]["matches_aggregate"]["aggregate"]
                  ["avg"]["auto_balls"] as double,
              teleInnerGoalAverage: team["team"][0]["matches_aggregate"]
                  ["aggregate"]["avg"]["teleop_inner"] as double,
              teleOuterGoalAverage: team["team"][0]["matches_aggregate"]
                  ["aggregate"]["avg"]["teleop_outer"] as double,
              id: teamId,
              climbFailed:
                  team["team"][0]["climbFail"]["aggregate"]["count"] as int,
              climbSuccess:
                  team["team"][0]["climbSuccess"]["aggregate"]["count"] as int,
            ),
          ) ??
          (throw Exception("No team available")),
    );
    //.entries.map((e) => LightTeam(e['id']);
  }

  void addTeam(final LightTeam team) => compareTeamsList.add(team);
  void removeTeam(final MapEntry<int, LightTeam> index) =>
      compareTeamsList.removeWhere(
        (final LightTeam entry) => entry.number == index.value.number,
      );

  Widget build(final BuildContext context) {
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
                        if (compareTeamsList.any(
                          (final LightTeam element) => element.id == team.id,
                        )) return;
                        setState(
                          () => compareTeamsList.add(
                            LightTeam(team.id, team.number, team.name),
                          ),
                        );
                      },
                      controller: controller,
                    ),
                  ),
                  SizedBox(width: defaultPadding),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: compareTeamsList
                          .asMap()
                          .entries
                          .map(
                            (final MapEntry<int, LightTeam> index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding / 2,
                              ),
                              child: Chip(
                                label: Text(index.value.number.toString()),
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
                            // body: Container(),
                            body: FutureBuilder<List<List<LineChartData>>>(
                              future: fetchMatches(
                                compareTeamsList
                                    .map((final LightTeam e) => e.number)
                                    .toList(),
                              ),
                              builder: (
                                final BuildContext context,
                                final AsyncSnapshot<List<List<LineChartData>>>
                                    snapshot,
                              ) {
                                if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (!snapshot.hasData ||
                                    (snapshot.data?.isEmpty ?? true)) {
                                  return Text("No Data yet :(");
                                }

                                final List<LineChartData> inner =
                                    <LineChartData>[];

                                final List<LineChartData> outer =
                                    <LineChartData>[];

                                final List<LineChartData> auto =
                                    <LineChartData>[];
                                (snapshot.data)!
                                    .forEach((final List<LineChartData> item) {
                                  if (!item.isEmpty) {
                                    inner.add(item[0]);
                                    outer.add(item[1]);
                                    auto.add(item[2]);
                                  }
                                });

                                return CarouselSlider(
                                  options: CarouselOptions(
                                    height: 3500,
                                    viewportFraction: 1,
                                    // autoPlay: true,
                                  ),
                                  items: <Widget>[
                                    Stack(
                                      children: <Widget>[
                                        Text("Inner"),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 20,
                                            right: 20,
                                            left: 20,
                                            bottom: 20,
                                          ),
                                          child: DashboardLineChart(
                                            dataSet: inner
                                                .map(
                                                  (final LineChartData e) =>
                                                      e.points,
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Stack(
                                      children: <Widget>[
                                        Align(
                                          child: Text("Outer"),
                                          alignment: Alignment.topLeft,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 20,
                                            right: 20,
                                            left: 20,
                                            bottom: 20,
                                          ),
                                          child: DashboardLineChart(
                                            dataSet: outer
                                                .map(
                                                  (final LineChartData e) =>
                                                      e.points,
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 20,
                                        right: 20,
                                        bottom: 20,
                                        left: 20,
                                      ),
                                      child: Stack(
                                        children: <Widget>[
                                          Align(
                                            child: Text("Auto"),
                                            alignment: Alignment.topLeft,
                                          ),
                                          DashboardLineChart(
                                            dataSet: auto
                                                .map(
                                                  (final LineChartData e) =>
                                                      e.points,
                                                )
                                                .toList(),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              },
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
                      body: Center(
                        child: FutureBuilder<List<Team>>(
                          future: fetchGameCharts(
                            compareTeamsList
                                .map((final LightTeam e) => e.id)
                                .toList(),
                          ),
                          builder: (
                            final BuildContext context,
                            final AsyncSnapshot<List<Team>> snapshot,
                          ) {
                            if (snapshot.hasError) {
                              return Text(
                                "Error has happened in the future! " +
                                    snapshot.error.toString(),
                              );
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (!snapshot.hasData) {
                              return Text("No Data yet");
                            } else {
                              if (snapshot.data!.isNotEmpty) {
                                final double innerRatio = 100 /
                                    (snapshot.data)!
                                        .map(
                                          (final Team e) =>
                                              e.teleInnerGoalAverage,
                                        )
                                        .reduce(max);
                                final double outerRatio = 100 /
                                    (snapshot.data)!
                                        .map(
                                          (final Team e) =>
                                              e.teleOuterGoalAverage,
                                        )
                                        .reduce(max);
                                final double autoRatio = 100 /
                                    (snapshot.data)!
                                        .map(
                                          (final Team e) => e.autoGoalAverage,
                                        )
                                        .reduce(max);
                                return SpiderChart(
                                  numberOfFeatures: 4,
                                  data: (snapshot.data)!
                                      .map(
                                        (final Team e) => (<int>[
                                          (e.teleInnerGoalAverage * innerRatio)
                                              .toInt(),
                                          (e.teleOuterGoalAverage * outerRatio)
                                              .toInt(),
                                          (e.autoGoalAverage * autoRatio)
                                              .toInt(),
                                          (e.climbSuccess /
                                                  (e.climbSuccess +
                                                      e.climbFailed) *
                                                  100)
                                              .toInt()
                                        ]),
                                      )
                                      .toList(),
                                  ticks: <int>[0, 25, 50, 75, 100],
                                  features: <String>[
                                    "inner balls",
                                    "outer balls",
                                    "Auto balls",
                                    "Climb%",
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            }
                          },
                        ),
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
  }
}
