import 'dart:ui';

import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";

class CoachView extends StatefulWidget {
  @override
  _CoachViewState createState() => _CoachViewState();
}

class _CoachViewState extends State<CoachView> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      drawer: SideNavBar(),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Coach"),
      ),
      body: FutureBuilder<CoachData>(
        future: fetchMatch(),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<CoachData> snapshot,
        ) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return snapshot.data.mapNullable(
                (final CoachData data) => Column(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Column(
                                  children: List<Widget>.generate(
                                    3,
                                    (final int index) => Expanded(
                                      flex: 2,
                                      child: teamData(data.blueAlliance[index]),
                                    ),
                                  )..insert(0, Spacer()),
                                ),
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Column(
                                  children: List<Widget>.generate(
                                    3,
                                    (final int index) => Expanded(
                                      flex: 2,
                                      child: teamData(data.redAlliance[index]),
                                    ),
                                  )..insert(0, Spacer()),
                                ),
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ) ??
              (throw Exception("No data"));
        },
      ),
    );
  }
}

const String query = """
query MyQuery {
  orbit_matches(order_by: {match_number: asc}, where: {happend: {_eq: false}}) {
    blue_0_team {
      id
      name
      number
      matches_aggregate {
        aggregate {
          avg {
            auto_upper
            auto_lower
            tele_lower
            tele_upper
            tele_upper_missed
            auto_upper_missed
          }
        }
        nodes {
          climb {
            points
          }
        }
      }
    }
    blue_1_team {
      id
      name
      number
            matches_aggregate {
        aggregate {
          avg {
            auto_upper
            auto_lower
            tele_lower
            tele_upper
            tele_upper_missed
            auto_upper_missed
          }
        }
        nodes {
          climb {
            points
          }
        }
      }
    }
    blue_2_team {
      id
      name
      number
            matches_aggregate {
        aggregate {
          avg {
            auto_upper
            auto_lower
            tele_lower
            tele_upper
            tele_upper_missed
            auto_upper_missed
          }
        }
        nodes {
          climb {
            points
          }
        }
      }
    }
    red_0_team {
      id
      name
      number
            matches_aggregate {
        aggregate {
          avg {
            auto_upper
            auto_lower
            tele_lower
            tele_upper
            tele_upper_missed
            auto_upper_missed
          }
        }
        nodes {
          climb {
            points
          }
        }
      }
    }
    red_1_team {
      id
      name
      number
            matches_aggregate {
        aggregate {
          avg {
            auto_upper
            auto_lower
            tele_lower
            tele_upper
            tele_upper_missed
            auto_upper_missed
          }
        }
        nodes {
          climb {
            points
          }
        }
      }
    }
    red_2_team {
      id
      name
      number
            matches_aggregate {
        aggregate {
          avg {
            auto_upper
            auto_lower
            tele_lower
            tele_upper
            tele_upper_missed
            auto_upper_missed
          }
        }
        nodes {
          climb {
            points
          }
        }
      }
    }
  }
}


""";
Future<CoachData> fetchMatch() async {
  final GraphQLClient client = getClient();
  final QueryResult result =
      await client.query(QueryOptions(document: gql(query)));
  return result.mapQueryResult(
    (final Map<String, dynamic>? data) =>
        data.mapNullable((final Map<String, dynamic> data) {
          final dynamic match = (data["orbit_matches"] as List<dynamic>).first;
          final List<CoachViewTeam> teams =
              teamValues.map<CoachViewTeam>((final String e) {
            final LightTeam team = LightTeam(
              match[e]["id"] as int,
              match[e]["number"] as int,
              match[e]["name"] as String,
            );
            final double autoLower = (match[e]["matches_aggregate"]["aggregate"]
                    ["avg"]["auto_lower"] as double?) ??
                double.nan;

            final double autoUpper = (match[e]["matches_aggregate"]["aggregate"]
                    ["avg"]["auto_upper"] as double?) ??
                double.nan;
            final double teleLower = (match[e]["matches_aggregate"]["aggregate"]
                    ["avg"]["tele_lower"] as double?) ??
                double.nan;
            final double teleUpper = (match[e]["matches_aggregate"]["aggregate"]
                    ["avg"]["tele_upper"] as double?) ??
                double.nan;
            final double avgBallPoints =
                autoLower * 2 + autoUpper * 4 + teleLower + teleUpper * 2;
            final Iterable<int> climb =
                (match[e]["matches_aggregate"]["nodes"] as List<dynamic>)
                    .map<int>((final dynamic e) => e["climb"]["points"] as int);

            final double climbAvg = climb.isEmpty
                ? double.nan
                : climb.length == 1
                    ? climb.first.toDouble()
                    : climb.reduce(
                          (final int value, final int element) =>
                              value + element,
                        ) /
                        climb.length;
            final dynamic avg =
                match[e]["matches_aggregate"]["aggregate"]["avg"];
            final double autoAim =
                (((avg["auto_upper"] as double?) ?? double.nan) /
                        (((avg["auto_upper"] as double?) ?? double.nan) +
                            ((avg["auto_lower"] as double?) ?? double.nan))) *
                    100;
            final double teleAim =
                (((avg["tele_upper"] as double?) ?? double.nan) /
                        (((avg["tele_upper"] as double?) ?? double.nan) +
                            ((avg["tele_lower"] as double?) ?? double.nan))) *
                    100;
            return CoachViewTeam(
              avgBallPoints: avgBallPoints,
              team: team,
              avgClimbPoints: climbAvg,
              autoBallAim: autoAim,
              teleopBallAim: teleAim,
            );
          }).toList();

          return CoachData(teams.sublist(0, 3), teams.sublist(3));
        }) ??
        (throw Exception("No data :(")),
  );
}

const List<String> teamValues = <String>[
  "blue_0_team",
  "blue_1_team",
  "blue_2_team",
  "red_0_team",
  "red_1_team",
  "red_2_team"
];

class CoachViewTeam {
  const CoachViewTeam({
    required this.autoBallAim,
    required this.avgBallPoints,
    required this.avgClimbPoints,
    required this.teleopBallAim,
    required this.team,
  });
  final double avgBallPoints;
  final double avgClimbPoints;
  final double teleopBallAim;
  final double autoBallAim;
  final LightTeam team;
}

class CoachData {
  const CoachData(this.blueAlliance, this.redAlliance);
  final List<CoachViewTeam> blueAlliance;
  final List<CoachViewTeam> redAlliance;
}

Widget teamData(final CoachViewTeam team) {
  if (team.autoBallAim.isNaN) {
    return Column(
      children: [
        Text(
          team.team.number.toString(),
          style: TextStyle(fontSize: 20),
        ),
        Text("No data :(")
      ],
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Align(
        alignment: Alignment.center,
        child: Text(
          team.team.number.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight:
                team.team.number == 1690 ? FontWeight.w900 : FontWeight.normal,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Text("Ball points: "),
                Text(team.avgBallPoints.toString()),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Climb points: "),
                Text(team.avgClimbPoints.toStringAsFixed(3)),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Teleop aim: "),
                Text(team.teleopBallAim.isNaN
                    ? "No data :("
                    : "${team.teleopBallAim.toStringAsFixed(3)}%")
              ],
            ),
            Row(
              children: <Widget>[
                Text("Auto aim: "),
                Text(
                  team.teleopBallAim.isNaN
                      ? "No data :("
                      : "${team.teleopBallAim.toStringAsFixed(3)}%",
                )
              ],
            )
          ],
        ),
      )
    ],
  );
}
