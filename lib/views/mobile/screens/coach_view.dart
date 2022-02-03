import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/team_data.dart";
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
      body: FutureBuilder<List<CoachData>>(
        future: fetchMatches(),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<CoachData>> snapshot,
        ) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return snapshot.data.mapNullable((final List<CoachData> data) {
                final List<CoachData> matches = matchTypes
                    .map(
                      (final String matchType) => data
                          .where(
                            (final CoachData element) =>
                                element.matchType == matchType,
                          )
                          .toList()
                        ..sort(
                          (final CoachData a, final CoachData b) =>
                              a.matchNumber.compareTo(b.matchNumber),
                        ),
                    )
                    .expand((final List<CoachData> element) => element)
                    .toList();
                final int initialIndex = matches.indexWhere(
                  (final CoachData element) => !element.happened,
                );
                return CarouselSlider(
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    height: double.infinity,
                    aspectRatio: 2.0,
                    viewportFraction: 1,
                    initialPage:
                        initialIndex == -1 ? matches.length - 1 : initialIndex,
                  ),
                  items: matches
                      .map((final CoachData e) => matchScreen(context, e))
                      .toList(),
                );
              }) ??
              (throw Exception("No data"));
        },
      ),
    );
  }
}

const List<String> matchTypes = <String>[
  "Quals",
  "Quarter finals",
  "Semi finals",
  "Finals"
];

Widget matchScreen(final BuildContext context, final CoachData data) => Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("${data.matchType}: ${data.matchNumber}"),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(0.625),
                  child: Column(
                    children: List<Widget>.generate(
                      3,
                      (final int index) => Expanded(
                        flex: 2,
                        child: teamData(
                          data.blueAlliance[index],
                          context,
                          true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(0.625),
                  child: Column(
                    children: List<Widget>.generate(
                      3,
                      (final int index) => Expanded(
                        flex: 2,
                        child:
                            teamData(data.redAlliance[index], context, false),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );

const String query = """
query MyQuery {
  orbit_matches{
    happened
    match_number
    match_type{
      title
    }
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
            tele_missed
            auto_missed
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
            tele_missed
            auto_missed
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
            tele_missed
            auto_missed
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
            tele_missed
            auto_missed
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
            tele_missed
            auto_missed
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
            tele_missed
            auto_missed
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
Future<List<CoachData>> fetchMatches() async {
  final GraphQLClient client = getClient();
  final QueryResult result =
      await client.query(QueryOptions(document: gql(query)));
  return result.mapQueryResult(
    (final Map<String, dynamic>? data) =>
        data.mapNullable((final Map<String, dynamic> data) {
          final List<dynamic> matches =
              (data["orbit_matches"] as List<dynamic>);
          return matches.map((final dynamic match) {
            final int number = match["match_number"] as int;
            final String matchType = match["match_type"]["title"] as String;
            final bool happened = match["happened"] as bool;
            final List<CoachViewLightTeam> teams =
                teamValues.map<CoachViewLightTeam>((final String e) {
              final LightTeam team = LightTeam(
                match[e]["id"] as int,
                match[e]["number"] as int,
                match[e]["name"] as String,
              );
              final dynamic avg =
                  match[e]["matches_aggregate"]["aggregate"]["avg"];
              final double autoLower =
                  (avg["auto_lower"] as double?) ?? double.nan;

              final double autoUpper =
                  (avg["auto_upper"] as double?) ?? double.nan;
              final double teleLower =
                  (avg["tele_lower"] as double?) ?? double.nan;
              final double teleUpper =
                  (avg["tele_upper"] as double?) ?? double.nan;
              final double avgBallPoints =
                  autoLower * 2 + autoUpper * 4 + teleLower + teleUpper * 2;
              final Iterable<int> climb = (match[e]["matches_aggregate"]
                      ["nodes"] as List<dynamic>)
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

              final double autoAim =
                  (((avg["auto_upper"] as double? ?? double.nan) +
                              (avg["auto_lower"] as double? ?? double.nan)) /
                          ((avg["auto_upper"] as double? ?? double.nan) +
                              (avg["auto_missed"] as double? ?? double.nan) +
                              (avg["auto_lower"] as double? ?? double.nan))) *
                      100;
              final double teleAim =
                  (((avg["tele_upper"] as double? ?? double.nan) +
                              (avg["tele_lower"] as double? ?? double.nan)) /
                          ((avg["tele_upper"] as double? ?? double.nan) +
                              (avg["tele_missed"] as double? ?? double.nan) +
                              (avg["tele_lower"] as double? ?? double.nan))) *
                      100;
              return CoachViewLightTeam(
                avgBallPoints: avgBallPoints,
                team: team,
                avgClimbPoints: climbAvg,
                autoBallAim: autoAim,
                teleopBallAim: teleAim,
              );
            }).toList();

            return CoachData(
              happened: happened,
              blueAlliance: teams.sublist(0, 3),
              redAlliance: teams.sublist(3),
              matchNumber: number,
              matchType: matchType,
            );
          }).toList();
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

class CoachViewLightTeam {
  const CoachViewLightTeam({
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
  const CoachData({
    required this.happened,
    required this.blueAlliance,
    required this.redAlliance,
    required this.matchNumber,
    required this.matchType,
  });
  final int matchNumber;
  final bool happened;
  final List<CoachViewLightTeam> blueAlliance;
  final List<CoachViewLightTeam> redAlliance;
  final String matchType;
}

Widget teamData(
  final CoachViewLightTeam team,
  final BuildContext context,
  final bool isBlue,
) {
  return Padding(
    padding: const EdgeInsets.all(defaultPadding / 4),
    child: ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: defaultBorderRadius),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          isBlue ? Colors.blue : Colors.red,
        ),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute<CoachTeamData>(
          builder: (final BuildContext context) => CoachTeamData(team.team),
        ),
      ),
      child: Expanded(
        child: Column(
          children: <Widget>[
            Text(
              team.team.number.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: team.team.number == 1690
                    ? FontWeight.w900
                    : FontWeight.normal,
              ),
            ),
            if (!(team.autoBallAim.isNaN ||
                team.avgBallPoints.isNaN ||
                team.avgClimbPoints.isNaN ||
                team.teleopBallAim.isNaN))
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    children: <Widget>[
                      Spacer(),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Ball points: "),
                            Text(team.avgBallPoints.toString()),
                          ],
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Climb points: "),
                            Text(team.avgClimbPoints.toStringAsFixed(3)),
                          ],
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Teleop aim: "),
                            Text(
                              "${team.teleopBallAim.toStringAsFixed(3)}%",
                            )
                          ],
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Auto aim: "),
                            Text(
                              "${team.autoBallAim.toStringAsFixed(3)}%",
                            )
                          ],
                        ),
                      ),
                      Spacer(
                        flex: 2,
                      )
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Center(child: Text("No data :(")),
              )
          ],
        ),
      ),
    ),
  );
}
