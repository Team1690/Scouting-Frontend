import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/mobile/team_selection_future.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/carousel_with_indicator.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/radar_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';

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
  late Team chosenTeam;
  List<LightTeam> compareTeamsList = [];
  // List tables;

  Future<List<LineChartData>?> fetchMatch(int teamNumber) async {
    final client = getClient();
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

    final QueryResult result = await client.query(QueryOptions(
        document: gql(query),
        variables: <String, int>{"teamNumber": teamNumber}));
    if (result.hasException) {
      throw result.exception!;
    } else if (result.data == null) {
      return null;
    }

    final List<dynamic> matches =
        result.data!["team"][0]["matches"] as List<dynamic>;
    return [
      LineChartData(
        points: matches
            .map<double>((dynamic e) => e['teleop_inner'] as double)
            .toList(),
      ),
      LineChartData(
        points: matches
            .map<double>((dynamic e) => e['teleop_outer'] as double)
            .toList(),
      ),
      LineChartData(
        points: matches
            .map<double>((dynamic e) => e['auto_balls'] as double)
            .toList(),
      ),
    ];
  }

  Future<List<List<LineChartData>>> fetchMatches(List<int> teamnumbers) async {
    List<List<LineChartData>> matches = [];
    for (int i = 0; i < teamnumbers.length; i++) {
      matches.add((await fetchMatch(teamnumbers[i])) ?? []);
    }
    return matches;
  }

  Future<List<Team>> fetchGameCharts(List<int> teamId) async {
    List<Team> teamList = [];
    for (int i = 0; i < teamId.length; i++) {
      Iterable<Team>? team = await fetchGameChart(teamId[i]);
      if (team != null) teamList.addAll(team);
    }

    return teamList;
  }

  Future<List<Team>?> fetchGameChart(int teamId) async {
    final client = getClient();
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

    final QueryResult result = await client.query(QueryOptions(
        document: gql(query), variables: <String, dynamic>{"team_id": teamId}));
    if (result.hasException) {
      throw result.exception!;
    } else if (result.data == null) {
      return null;
    }

    return (result.data!['team'] as List<dynamic>)
        .map((dynamic e) => Team(
              teamName: e['name'] as String,
              teamNumber: e['number'] as int,
              autoGoalAverage: e['matches_aggregate']['aggregate']['avg']
                  ['auto_balls'] as double,
              teleInnerGoalAverage: e['matches_aggregate']['aggregate']['avg']
                  ['teleop_inner'] as double,
              teleOuterGoalAverage: e['matches_aggregate']['aggregate']['avg']
                  ['teleop_outer'] as double,
              id: teamId,
              climbFailed: e['climbFail']['aggregate']['count'] as int,
              climbSuccess: e['climbSuccess']['aggregate']['count'] as int,
            ))
        .toList();
    //.entries.map((e) => LightTeam(e['id']);
  }

  void addTeam(LightTeam team) => compareTeamsList.add(team);
  void removeTeam(MapEntry<int, LightTeam> index) => compareTeamsList
      .removeWhere((LightTeam entry) => entry.number == index.value.number);

  Widget build(BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TeamSelectionFuture(
                      onChange: (LightTeam team) {
                        if (compareTeamsList
                            .any((element) => element.id == team.id)) return;
                        setState(() => {
                              compareTeamsList.add(
                                  LightTeam(team.id, team.number, team.name))
                            });
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
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: defaultPadding / 2),
                                child: Chip(
                                  label: Text(index.value.number.toString()),
                                  backgroundColor: colors[index.key],
                                  onDeleted: () =>
                                      setState(() => removeTeam(index)),
                                ),
                              ),
                            )
                            .toList()),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: ToggleButtons(
                        children: [
                          Icon(Icons.shield_rounded),
                          Icon(Icons.remove_moderator_outlined),
                        ],
                        isSelected: [false, false],
                        onPressed: (int index) {},
                      )),
                ],
              ),
            ),
            SizedBox(height: defaultPadding),
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DashboardCard(
                            title: 'Game Chart',
                            // body: Container(),
                            body: FutureBuilder(
                              future: fetchMatches(compareTeamsList
                                  .map((e) => e.number)
                                  .toList()),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (!snapshot.hasData ||
                                    (snapshot.data as List<List<LineChartData>>)
                                        .isEmpty) {
                                  return Container();
                                }

                                List<LineChartData> inner = [];

                                List<LineChartData> outer = [];

                                List<LineChartData> auto = [];
                                (snapshot.data as List<List<LineChartData>>)
                                    .forEach((item) {
                                  inner.add(item[0]);
                                  outer.add(item[1]);
                                  auto.add(item[2]);
                                });

                                return CarouselSlider(
                                  options: CarouselOptions(
                                    height: 3500,
                                    viewportFraction: 1,
                                    // autoPlay: true,
                                  ),
                                  items: [
                                    Stack(
                                      children: [
                                        Text('Inner'),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20,
                                              right: 20,
                                              left: 20,
                                              bottom: 20),
                                          child: DashboardLineChart(
                                              dataSet: inner
                                                  .map((e) => e.points)
                                                  .toList()),
                                        ),
                                      ],
                                    ),
                                    Stack(
                                      children: [
                                        Align(
                                          child: Text('Outer'),
                                          alignment: Alignment.topLeft,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20,
                                              right: 20,
                                              left: 20,
                                              bottom: 20),
                                          child: DashboardLineChart(
                                              dataSet: outer
                                                  .map((e) => e.points)
                                                  .toList()),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20,
                                          right: 20,
                                          bottom: 20,
                                          left: 20),
                                      child: Stack(
                                        children: [
                                          Align(
                                            child: Text('Auto'),
                                            alignment: Alignment.topLeft,
                                          ),
                                          DashboardLineChart(
                                              dataSet: auto
                                                  .map((e) => e.points)
                                                  .toList())
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
                        title: 'Compare Spider Chart',
                        body: Center(
                            child: FutureBuilder(
                          future: fetchGameCharts(
                              compareTeamsList.map((e) => e.id).toList()),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error has happened in the future! ' +
                                  snapshot.error.toString());
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                              // const CircularProgressIndicator();
                            } else {
                              if ((snapshot.data as List<Team>).isNotEmpty) {
                                double innerRatio = 100 /
                                    (snapshot.data as List<Team>)
                                        .map((e) => e.teleInnerGoalAverage)
                                        .reduce((curr, next) =>
                                            curr > next ? curr : next);
                                double outerRatio = 100 /
                                    (snapshot.data as List<Team>)
                                        .map((e) => e.teleOuterGoalAverage)
                                        .reduce((curr, next) =>
                                            curr > next ? curr : next);
                                double autoRatio = 100 /
                                    (snapshot.data as List<Team>)
                                        .map((e) => e.autoGoalAverage)
                                        .reduce((curr, next) =>
                                            curr > next ? curr : next);
                                return SpiderChart(
                                    numberOfFeatures: 4,
                                    data: (snapshot.data as List<Team>)
                                        .map((e) => ([
                                              (e.teleInnerGoalAverage *
                                                      innerRatio)
                                                  .toInt(),
                                              (e.teleOuterGoalAverage *
                                                      outerRatio)
                                                  .toInt(),
                                              (e.autoGoalAverage * autoRatio)
                                                  .toInt(),
                                              (e.climbSuccess /
                                                      (e.climbSuccess +
                                                          e.climbFailed) *
                                                      100)
                                                  .toInt()
                                            ]))
                                        .toList(),
                                    ticks: [
                                      0,
                                      25,
                                      50,
                                      75,
                                      100
                                    ],
                                    features: [
                                      "inner balls",
                                      "outer balls",
                                      "Auto balls",
                                      "Climb%",
                                    ]);
                              } else {
                                return Container();
                              }
                            }
                          },
                        )),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
