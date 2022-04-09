import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/coach_team_info_data.dart";
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
                final int initialIndex = data.indexWhere(
                  (final CoachData element) => !element.happened,
                );
                return CarouselSlider(
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    height: double.infinity,
                    aspectRatio: 2.0,
                    viewportFraction: 1,
                    initialPage:
                        initialIndex == -1 ? data.length - 1 : initialIndex,
                  ),
                  items: data
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
                    children: data.blueAlliance
                        .map(
                          (final CoachViewLightTeam e) =>
                              Expanded(child: teamData(e, context, true)),
                        )
                        .toList(),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(0.625),
                  child: Column(
                    children: data.redAlliance
                        .map(
                          (final CoachViewLightTeam e) =>
                              Expanded(child: teamData(e, context, false)),
                        )
                        .toList(),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );

final String query = """
query MyQuery {
  orbit_matches(order_by: {match_type: {order: asc}, match_number: asc}) {
    happened
    match_number
    match_type {
      title
    }
    ${teamValues.map(
          (final String e) => """$e{
      colors_index
      id
      name
      number
      matches_aggregate(where: {ignored: {_eq: false}}) {
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
            title
            points
          }
        }
      }
    }""",
        ).join(" ")}
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
            final List<CoachViewLightTeam> teams = teamValues
                .map<CoachViewLightTeam?>((final String e) {
                  // Couldn't use mapNullable properly because this variable is dynamic
                  if (match[e] == null) {
                    return null;
                  }
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
                  final double autoMissed =
                      (avg["auto_missed"] as double?) ?? double.nan;
                  final double autoUpper =
                      (avg["auto_upper"] as double?) ?? double.nan;
                  final double teleLower =
                      (avg["tele_lower"] as double?) ?? double.nan;
                  final double teleUpper =
                      (avg["tele_upper"] as double?) ?? double.nan;
                  final double teleMissed =
                      (avg["tele_missed"] as double?) ?? double.nan;
                  final double avgBallPoints =
                      autoLower * 2 + autoUpper * 4 + teleLower + teleUpper * 2;
                  final Iterable<int> climb =
                      (match[e]["matches_aggregate"]["nodes"] as List<dynamic>)
                          .where(
                            (final dynamic element) =>
                                element["climb"]["title"] != "No attempt",
                          )
                          .map<int>(
                            (final dynamic e) => e["climb"]["points"] as int,
                          );
                  final int amountOfMatches =
                      (match[e]["matches_aggregate"]["nodes"] as List<dynamic>)
                          .length;
                  final double climbAvg = climb.isEmpty
                      ? 0
                      : climb.length == 1
                          ? climb.first.toDouble()
                          : climb.reduce(
                                (final int value, final int element) =>
                                    value + element,
                              ) /
                              climb.length;

                  return CoachViewLightTeam(
                    amountOfMatches: amountOfMatches,
                    avgBallPoints: avgBallPoints,
                    team: team,
                    avgClimbPoints: climbAvg,
                    autoLower: autoLower,
                    autoMissed: autoMissed,
                    teleLower: teleLower,
                    autoUpper: autoUpper,
                    teleUpper: teleUpper,
                    teleMissed: teleMissed,
                    isBlue: e.startsWith("blue"),
                  );
                })
                .whereType<CoachViewLightTeam>()
                .toList();

            return CoachData(
              happened: happened,
              blueAlliance: teams
                  .where((final CoachViewLightTeam element) => element.isBlue)
                  .toList(),
              redAlliance: teams
                  .where((final CoachViewLightTeam element) => !element.isBlue)
                  .toList(),
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
  "blue_3_team",
  "red_0_team",
  "red_1_team",
  "red_2_team",
  "red_3_team",
];

class CoachViewLightTeam {
  const CoachViewLightTeam({
    required this.avgBallPoints,
    required this.avgClimbPoints,
    required this.team,
    required this.amountOfMatches,
    required this.autoLower,
    required this.autoMissed,
    required this.autoUpper,
    required this.teleLower,
    required this.teleMissed,
    required this.teleUpper,
    required this.isBlue,
  });
  final int amountOfMatches;
  final double avgBallPoints;
  final double avgClimbPoints;
  final double autoUpper;
  final double autoLower;
  final double autoMissed;
  final double teleUpper;
  final double teleLower;
  final double teleMissed;
  final LightTeam team;
  final bool isBlue;
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
        MaterialPageRoute<CoachTeamData<int>>(
          builder: (final BuildContext context) =>
              CoachTeamData<int>(team.team),
        ),
      ),
      child: Column(
        children: <Widget>[
          Spacer(),
          Expanded(
            child: FittedBox(
              fit: BoxFit.fitHeight,
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
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                children: <Widget>[
                  if (team.amountOfMatches == 0)
                    ...List<Spacer>.filled(7, Spacer())
                  else ...<Widget>[
                    Spacer(),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Ball points: ${team.avgBallPoints.toStringAsFixed(1)}",
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Climb points: ${team.avgClimbPoints.toStringAsFixed(1)}",
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Auto aim: ${(team.autoUpper + team.autoLower).toStringAsFixed(1)}/${(team.autoUpper + team.autoLower + team.autoMissed).toStringAsFixed(1)}",
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Tele aim: ${(team.teleUpper + team.teleLower).toStringAsFixed(1)}/${(team.teleUpper + team.teleLower + team.teleMissed).toStringAsFixed(1)}",
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Teleop balls 20sc: ${(team.teleUpper * (2 / 9)).toStringAsFixed(1)}",
                        ),
                      ),
                    ),
                    Spacer(
                      flex: 1,
                    )
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    ),
  );
}
