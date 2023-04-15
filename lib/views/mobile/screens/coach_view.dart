import "dart:math";

import "package:carousel_slider/carousel_slider.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/average_or_null.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/match_model.dart";
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
        title: const Text("Coach"),
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
            icon: const Icon(Icons.compare_arrows),
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
            return const Center(
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

Widget matchScreen(final BuildContext context, final CoachData data) {
  int getPointsEstimation(final bool isBlue) {
    final double avgLow = !isBlue ? data.avgRedLow : data.avgBlueLow;
    final double avgMid = !isBlue ? data.avgRedMid : data.avgBlueMid;
    final double avgTop = !isBlue ? data.avgRedTop : data.avgBlueTop;
    final double avgSupercharged =
        !isBlue ? data.avgRedSupercharged : data.avgBlueSupercharged;
    return (avgLow * 2 +
            avgMid * 3 +
            avgTop * 5 + //basic points
            (avgTop / 3) * 5 +
            (avgMid / 3) * 5 +
            (avgLow / 3) * 5 + //links estimation
            (avgMid + avgTop + avgMid == 27 && avgSupercharged != 0
                ? avgSupercharged * 3
                : 0) //superCharges
        )
        .round();
  }

  return Column(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("${data.matchType}: ${data.matchNumber}"),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              style: const TextStyle(color: Colors.blue),
              "${data.avgBlueTop.toStringAsFixed(1)} | ${data.avgBlueMid.toStringAsFixed(1)} | ${data.avgBlueLow.toStringAsFixed(1)} ${data.avgBlueLow + data.avgBlueMid + data.avgBlueTop == 27 && data.avgBlueSupercharged != 0 ? "(${data.avgBlueSupercharged.toStringAsFixed(1)})" : ""}",
            ),
            const Text(" vs "),
            Text(
              style: const TextStyle(color: Colors.red),
              "${data.avgRedTop.toStringAsFixed(1)} | ${data.avgRedMid.toStringAsFixed(1)} | ${data.avgRedLow.toStringAsFixed(1)} ${data.avgRedLow + data.avgRedMid + data.avgRedTop == 27 && data.avgRedSupercharged != 0 ? "(${data.avgRedSupercharged.toStringAsFixed(1)})" : ""}",
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              style: const TextStyle(color: Colors.blue),
              "${getPointsEstimation(true)}",
            ),
            const Text(" vs "),
            Text(
              style: const TextStyle(color: Colors.red),
              "${getPointsEstimation(false)}",
            ),
          ],
        ),
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
}

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
    technical_matches(where: {ignored: {_eq: false}}){
        balanced_with
      }
     technical_matches_aggregate(where: {ignored: {_eq: false}}) {
      aggregate {
        avg {
          auto_cones_low
          auto_cones_mid
          auto_cones_top
          auto_cubes_low
          auto_cubes_mid
          auto_cubes_top
          tele_cones_low
          tele_cones_mid
          tele_cones_top
          tele_cubes_low
          tele_cubes_mid
          tele_cubes_top
           auto_cones_delivered
          auto_cubes_delivered
          tele_cones_delivered
         tele_cubes_delivered
         balanced_with
        }
    }
      nodes{
        auto_balance{
          auto_points
          title
        }
        endgame_balance{
          endgame_points
          title
        }
        robot_match_status{
          title
        }
      }
    }
    }
    """,
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
                final LightTeam team = LightTeam.fromJson(match[e]);
                final List<dynamic> nodes = match[e]
                    ["technical_matches_aggregate"]["nodes"] as List<dynamic>;
                final dynamic avg =
                    match[e]["technical_matches_aggregate"]["aggregate"]["avg"];
                final bool avgNullValidator = avg["auto_cones_top"] == null;
                final bool nodeNullValidator = nodes.isEmpty;
                final double avgAutoDelivered = avgNullValidator
                    ? double.nan
                    : (avg["auto_cones_delivered"] as double) +
                        (avg["auto_cubes_delivered"] as double);
                final double avgTeleDelivered = avgNullValidator
                    ? double.nan
                    : ((avg["tele_cones_delivered"] as double) +
                        (avg["tele_cubes_delivered"] as double));
                final double avgAutoGamepieces = avgNullValidator
                    ? double.nan
                    : getPieces(parseByMode(MatchMode.auto, avg)) -
                        avgAutoDelivered;
                final double avgTeleGamepieces = avgNullValidator
                    ? double.nan
                    : getPieces(parseByMode(MatchMode.tele, avg)) -
                        avgTeleDelivered;
                final double avgGamepiecePoints =
                    avgNullValidator ? double.nan : getPoints(parseMatch(avg));
                final double avgAutoBalancePoints = nodeNullValidator
                    ? double.nan
                    : nodes
                            .where(
                              (final dynamic element) =>
                                  element["robot_match_status"] !=
                                          "Didn't come to field"
                                      ? element["auto_balance"]["title"] !=
                                          "No Attempt"
                                      : false,
                            )
                            .map(
                              (final dynamic match) =>
                                  match["auto_balance"]["auto_points"] as int,
                            )
                            .toList()
                            .averageOrNull ??
                        double.nan;
                final double avgEndgameBalancePoints = nodeNullValidator
                    ? double.nan
                    : nodes
                            .where(
                              (final dynamic element) =>
                                  element["robot_match_status"] !=
                                          "Didn't come to field"
                                      ? element["endgame_balance"]["title"] !=
                                          "No attempt"
                                      : false,
                            )
                            .map(
                              (final dynamic match) => match["endgame_balance"]
                                  ["endgame_points"] as int,
                            )
                            .toList()
                            .averageOrNull ??
                        double.nan;
                final double autoBalancePercentage = nodeNullValidator
                    ? double.nan
                    : nodes
                            .where(
                              (final dynamic element) =>
                                  element["robot_match_status"] !=
                                          "Didn't come to field"
                                      ? element["auto_balance"]["title"] !=
                                              "No attempt" &&
                                          element["auto_balance"]["title"] !=
                                              "Failed"
                                      : false,
                            )
                            .length /
                        nodes
                            .where(
                              (final dynamic match) =>
                                  match["auto_balance"]["title"] !=
                                  "No attempt",
                            )
                            .length;
                final double endgameBalancePercentage = nodeNullValidator
                    ? double.nan
                    : nodes
                            .where(
                              (final dynamic element) =>
                                  element["robot_match_status"] !=
                                          "Didn't come to field"
                                      ? element["endgame_balance"]["title"] !=
                                              "No attempt" &&
                                          element["endgame_balance"]["title"] !=
                                              "Failed"
                                      : false,
                            )
                            .length /
                        nodes.length;
                final List<dynamic> matches =
                    match[e]["technical_matches"] as List<dynamic>;
                final int matchesBalancedSingle = matches
                    .where(
                      (final dynamic match) =>
                          (match["balanced_with"] as int?) == 0,
                    )
                    .length;
                final int matchesBalancedDouble = matches
                    .where(
                      (final dynamic match) =>
                          (match["balanced_with"] as int?) == 1,
                    )
                    .length;
                final int matchesBalancedTriple = matches
                    .where(
                      (final dynamic match) =>
                          (match["balanced_with"] as int?) == 2,
                    )
                    .length;
                double getAvgPerLevel(final GridLevel level) => avgNullValidator
                    ? 0
                    : (avg["tele_cones_${level.title}"] as double) +
                        (avg["tele_cubes_${level.title}"] as double) +
                        (avg["auto_cones_${level.title}"] as double) +
                        (avg["auto_cubes_${level.title}"] as double);
                return CoachViewLightTeam(
                  avgGamepiecePoints: avgGamepiecePoints,
                  amountOfMatches: nodes.length,
                  team: team,
                  avgDelivered: avgAutoDelivered + avgTeleDelivered,
                  avgGamepiecesPlaced: avgAutoGamepieces + avgTeleGamepieces,
                  avgEndgameBalancePoints: avgEndgameBalancePoints,
                  endgameBalancePercentage: endgameBalancePercentage,
                  matchesBalancedSingle: matchesBalancedSingle,
                  matchesBalancedDouble: matchesBalancedDouble,
                  matchesBalancedTriple: matchesBalancedTriple,
                  avgAutoBalancePoints: avgAutoBalancePoints,
                  autoBalancePercentage: autoBalancePercentage,
                  isBlue: e.startsWith("blue"),
                  avgLowPieces: getAvgPerLevel(GridLevel.low),
                  avgMidPieces: getAvgPerLevel(GridLevel.mid),
                  avgTopPieces: getAvgPerLevel(GridLevel.top),
                );
              })
              .whereType<CoachViewLightTeam>()
              .toList();
          Map<GridLevel, double> getRealisticAvgAlliancePerLevel(
            final bool isBlue,
          ) {
            double avgLow = teams
                .where(
                  (final CoachViewLightTeam element) =>
                      element.isBlue == isBlue,
                )
                .map((final CoachViewLightTeam team) => team.avgLowPieces)
                .toList()
                .sum;
            double avgMid = teams
                .where(
                  (final CoachViewLightTeam element) =>
                      element.isBlue == isBlue,
                )
                .map((final CoachViewLightTeam team) => team.avgMidPieces)
                .toList()
                .sum;
            double avgTop = teams
                .where(
                  (final CoachViewLightTeam element) =>
                      element.isBlue == isBlue,
                )
                .map((final CoachViewLightTeam team) => team.avgTopPieces)
                .toList()
                .sum;
            //TODO this is an abomintaion
            if (avgTop > 9) {
              avgMid += (avgTop - 9);
              avgTop = 9;
            }
            if (avgMid > 9) {
              if (avgTop > 0) {
                avgTop += (avgMid - 9);
                if (avgTop > 9) {
                  avgLow += (avgTop - 9);
                  avgTop = 9;
                }
              } else {
                avgLow += (avgMid - 9);
              }
              avgMid = 9;
            }
            if (avgLow > 9) {
              if (avgMid == 9) {
                if (avgTop == 9) {
                } else if (avgTop > 0) {
                  avgTop == min(avgTop + (avgLow - 9), 9);
                }
              } else if (avgMid > 0) {
                avgMid += (avgLow - 9);
                if (avgMid > 9) {
                  if (avgTop == 9) {
                  } else if (avgTop > 0) {
                    avgTop == min(avgTop + (avgMid - 9), 9);
                  }
                  avgMid = 9;
                }
              }
              avgLow = 9;
            }
            return <GridLevel, double>{
              GridLevel.low: avgLow,
              GridLevel.mid: avgMid,
              GridLevel.top: avgTop,
            };
          }

          final Map<GridLevel, double> avgBlue =
              getRealisticAvgAlliancePerLevel(true);
          final Map<GridLevel, double> avgRed =
              getRealisticAvgAlliancePerLevel(false);

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
            avgBlueLow: avgBlue[GridLevel.low]!,
            avgBlueMid: avgBlue[GridLevel.mid]!,
            avgBlueTop: avgBlue[GridLevel.top]!,
            avgRedLow: avgRed[GridLevel.low]!,
            avgRedMid: avgRed[GridLevel.mid]!,
            avgRedTop: avgRed[GridLevel.top]!,
            avgBlueSupercharged: teams
                    .where((final CoachViewLightTeam element) => element.isBlue)
                    .map(
                      (final CoachViewLightTeam team) =>
                          team.avgLowPieces +
                          team.avgMidPieces +
                          team.avgTopPieces,
                    )
                    .sum -
                (avgBlue[GridLevel.top]! +
                    avgBlue[GridLevel.mid]! +
                    avgBlue[GridLevel.low]!),
            avgRedSupercharged: teams
                    .where(
                      (final CoachViewLightTeam element) => !element.isBlue,
                    )
                    .map(
                      (final CoachViewLightTeam team) =>
                          team.avgLowPieces +
                          team.avgMidPieces +
                          team.avgTopPieces,
                    )
                    .sum -
                (avgRed[GridLevel.top]! +
                    avgRed[GridLevel.mid]! +
                    avgRed[GridLevel.low]!),
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
    required this.avgEndgameBalancePoints,
    required this.matchesBalancedSingle,
    required this.matchesBalancedDouble,
    required this.matchesBalancedTriple,
    required this.avgAutoBalancePoints,
    required this.team,
    required this.amountOfMatches,
    required this.autoBalancePercentage,
    required this.endgameBalancePercentage,
    required this.avgGamepiecesPlaced,
    required this.isBlue,
    required this.avgDelivered,
    required this.avgGamepiecePoints,
    required this.avgLowPieces,
    required this.avgMidPieces,
    required this.avgTopPieces,
  });
  final int amountOfMatches;
  final double avgEndgameBalancePoints;
  final double endgameBalancePercentage;
  final int matchesBalancedSingle;
  final int matchesBalancedDouble;
  final int matchesBalancedTriple;
  final double avgAutoBalancePoints;
  final double autoBalancePercentage;
  final double avgDelivered;
  final double avgGamepiecesPlaced;
  final double avgGamepiecePoints;
  final LightTeam team;
  final bool isBlue;
  final double avgTopPieces;
  final double avgMidPieces;
  final double avgLowPieces;
}

class CoachData {
  const CoachData({
    required this.happened,
    required this.blueAlliance,
    required this.redAlliance,
    required this.matchNumber,
    required this.matchType,
    required this.avgBlueLow,
    required this.avgBlueMid,
    required this.avgBlueTop,
    required this.avgRedLow,
    required this.avgRedMid,
    required this.avgRedTop,
    required this.avgBlueSupercharged,
    required this.avgRedSupercharged,
  });
  final int matchNumber;
  final bool happened;
  final List<CoachViewLightTeam> blueAlliance;
  final List<CoachViewLightTeam> redAlliance;
  final String matchType;
  final double avgBlueTop;
  final double avgBlueMid;
  final double avgBlueLow;
  final double avgBlueSupercharged;
  final double avgRedTop;
  final double avgRedMid;
  final double avgRedLow;
  final double avgRedSupercharged;
}

Widget teamData(
  final CoachViewLightTeam team,
  final BuildContext context,
  final bool isBlue,
) =>
    Padding(
      padding: const EdgeInsets.all(defaultPadding / 4),
      child: ElevatedButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size.infinite),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(borderRadius: defaultBorderRadius),
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
            const Spacer(),
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
                      ...List<Spacer>.filled(7, const Spacer())
                    else ...<Widget>[
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Avg Gamepieces Scored: ${team.avgGamepiecesPlaced.toStringAsFixed(1)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Avg Gamepiece Points: ${team.avgGamepiecePoints.toStringAsFixed(1)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Avg Delivered: ${team.avgDelivered.toStringAsFixed(1)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Auto Balance: ${team.avgAutoBalancePoints.toStringAsFixed(1)} / ${(team.autoBalancePercentage * 100).toStringAsFixed(1)}%",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Endgame Balance: ${team.avgEndgameBalancePoints.toStringAsFixed(1)} / ${(team.endgameBalancePercentage * 100).toStringAsFixed(1)}%",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Balance Partners: ${team.matchesBalancedSingle} / ${team.matchesBalancedDouble} / ${team.matchesBalancedTriple}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Amount Of Matches: ${(team.amountOfMatches)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const Spacer(
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
