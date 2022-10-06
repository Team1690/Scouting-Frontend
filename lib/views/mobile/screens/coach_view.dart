import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/coach_team_info_data.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/pc/compare/compare_screen.dart";

class CoachView extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    int page = -1;
    List<CoachData>? coachData;
    return Scaffold(
      drawer: SideNavBar(),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Coach"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              if (page == -1) return;
              final CoachData? innerCoachData = coachData?[page];
              innerCoachData.mapNullable(
                (final CoachData p0) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<CompareScreen>(
                    builder: (final BuildContext context) =>
                        CompareScreen(<LightTeam>[
                      ...p0.blueAlliance
                          .map((final CoachViewLightTeam e) => e.team),
                      ...p0.redAlliance
                          .map((final CoachViewLightTeam e) => e.team)
                    ]),
                  ),
                ),
              );
            },
            icon: Icon(Icons.compare_arrows),
          )
        ],
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
                coachData = data;
                page = initialIndex;
                return CarouselSlider(
                  options: CarouselOptions(
                    onPageChanged:
                        (final int index, final CarouselPageChangedReason _) {
                      page = index;
                    },
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
query FetchCoach {
  matches(order_by: {match_type: {order: asc}, match_number: asc}) {
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
  final QueryResult<List<CoachData>> result = await client.query(
    QueryOptions<List<CoachData>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> data) {
        final List<dynamic> matches = (data["matches"] as List<dynamic>);
        return matches
            .where(
          (final dynamic element) => teamValues
              .any((final String team) => element[team]?["number"] == 1690),
        )
            .map((final dynamic match) {
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
                  matchesClimbed:
                      (match[e]["matches_aggregate"]["nodes"] as List<dynamic>)
                          .where(
                            (final dynamic element) =>
                                element["climb"]["title"] != "No attempt" &&
                                element["climb"]["title"] != "Failed",
                          )
                          .length,
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
      },
    ),
  );
  return result.mapQueryResult();
}

const List<String> teamValues = <String>[
  "blue_0",
  "blue_1",
  "blue_2",
  "blue_3",
  "red_0",
  "red_1",
  "red_2",
  "red_3",
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
    required this.matchesClimbed,
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
  final int matchesClimbed;
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
        MaterialPageRoute<CoachTeamData>(
          builder: (final BuildContext context) => CoachTeamData(team.team),
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
                          "Climb points: ${team.avgClimbPoints.toStringAsFixed(1)}/${team.matchesClimbed}/${team.amountOfMatches}",
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
