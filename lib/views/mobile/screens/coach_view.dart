import "package:carousel_slider/carousel_slider.dart";
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
                final int amountOfMatches = nodes.length;
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
                        amountOfMatches;
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
                        amountOfMatches;
                final double avgBalancePartners = avgNullValidator
                    ? double.nan
                    : (avg["balanced_with"] ?? 0) as double;
                return CoachViewLightTeam(
                  avgGamepiecePoints: avgGamepiecePoints,
                  amountOfMatches: amountOfMatches,
                  team: team,
                  avgDelivered: avgAutoDelivered + avgTeleDelivered,
                  avgGamepiecesPlaced: avgAutoGamepieces + avgTeleGamepieces,
                  avgEndgameBalancePoints: avgEndgameBalancePoints,
                  endgameBalancePercentage: endgameBalancePercentage,
                  endgameBalancePartners: avgBalancePartners,
                  avgAutoBalancePoints: avgAutoBalancePoints,
                  autoBalancePercentage: autoBalancePercentage,
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
    required this.avgEndgameBalancePoints,
    required this.endgameBalancePartners,
    required this.avgAutoBalancePoints,
    required this.team,
    required this.amountOfMatches,
    required this.autoBalancePercentage,
    required this.endgameBalancePercentage,
    required this.avgGamepiecesPlaced,
    required this.isBlue,
    required this.avgDelivered,
    required this.avgGamepiecePoints,
  });
  final int amountOfMatches;
  final double avgEndgameBalancePoints;
  final double endgameBalancePercentage;
  final double endgameBalancePartners;
  final double avgAutoBalancePoints;
  final double autoBalancePercentage;
  final double avgDelivered;
  final double avgGamepiecesPlaced;
  final double avgGamepiecePoints;
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
                            "Amount Of Matches: ${(team.amountOfMatches)}",
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
                            "Endgame Balance: ${team.avgEndgameBalancePoints.toStringAsFixed(1)} / ${(team.endgameBalancePercentage * 100).toStringAsFixed(1)}% / ${(team.endgameBalancePartners + 1).toStringAsFixed(1)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Avg Gamepiece Amount: ${team.avgGamepiecesPlaced.toStringAsFixed(1)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Avg Gamepiece Score: ${team.avgGamepiecePoints.toStringAsFixed(1)}",
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
