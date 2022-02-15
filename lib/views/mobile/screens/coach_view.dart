import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/team_data.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";

class CoachView extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      drawer: SideNavBar(),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Coach"),
      ),
      body: FutureBuilder<List<CoachData>>(
        future: fetchMatches(context),
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
      specifics {
        robot_role {
          id
          title
        }
      }
      colors_index
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
      specifics {
        robot_role {
          id
          title
        }
      }
      colors_index
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
      specifics {
        robot_role {
          id
          title
        }
      }
      colors_index
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
      specifics {
        robot_role {
          id
          title
        }
      }
      colors_index
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
      specifics {
        robot_role {
          id
          title
        }
      }
      colors_index
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
      specifics {
        robot_role {
          id
          title
        }
      }
      colors_index
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
Future<List<CoachData>> fetchMatches(final BuildContext context) async {
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
                match[e]["colors_index"] as int,
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

              final List<int> roleIds = (match[e]["specifics"] as List<dynamic>)
                  .map<int?>(
                    (final dynamic e) => e["robot_role"]?["id"] as int?,
                  )
                  .where((final int? element) => element != null)
                  .cast<int>()
                  .toList();

              final Map<int, int> roleToAmount = <int, int>{};
              for (final int element in roleIds) {
                roleToAmount[element] = (roleToAmount[element] ?? 0) + 1;
              }
              final List<MapEntry<int, int>> roles = roleToAmount.entries
                  .toList()
                ..sort(
                  (final MapEntry<int, int> a, final MapEntry<int, int> b) =>
                      b.value.compareTo(a.value),
                );
              final String mostPopularRoleName = roles.isEmpty
                  ? "No data"
                  : roles.length == 1
                      ? IdProvider.of(context)
                          .robotRole
                          .idToName[roles.first.key]!
                      : roles.length == 2
                          ? "${IdProvider.of(context).robotRole.idToName[roles.first.key]}-${IdProvider.of(context).robotRole.idToName[roles.elementAt(1).key]}"
                          : "Misc";

              return CoachViewLightTeam(
                robotRole: mostPopularRoleName,
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
    required this.robotRole,
  });
  final double avgBallPoints;
  final double avgClimbPoints;
  final double teleopBallAim;
  final double autoBallAim;
  final LightTeam team;
  final String robotRole;
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
        minimumSize: MaterialStateProperty.all(Size.infinite),
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
      child: Column(
        children: <Widget>[
          Spacer(),
          Expanded(
            child: Text(
              team.team.number.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: team.team.number == 1690
                    ? FontWeight.w900
                    : FontWeight.normal,
              ),
            ),
          ),
          if (!(team.autoBallAim.isNaN ||
              team.avgBallPoints.isNaN ||
              team.avgClimbPoints.isNaN ||
              team.teleopBallAim.isNaN))
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Ball points: ${team.avgBallPoints.toStringAsFixed(1)}%",
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Climb points: ${team.avgClimbPoints.toStringAsFixed(1)}%",
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Teleop aim: ${team.teleopBallAim.toStringAsFixed(1)}%",
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Auto aim: ${team.autoBallAim.toStringAsFixed(1)}%",
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Auto aim: ${team.autoBallAim.toStringAsFixed(1)}%",
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Role: ${team.robotRole}",
                        ),
                      ),
                    ),
                    Spacer(
                      flex: 1,
                    )
                  ],
                ),
              ),
            )
          else
            Expanded(
              flex: 4,
              child: Center(child: Text("No data :(")),
            )
        ],
      ),
    ),
  );
}
