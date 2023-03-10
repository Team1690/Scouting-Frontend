import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/average_or_null.dart";
import "package:scouting_frontend/models/cycle_model.dart";
import "package:scouting_frontend/models/event_model.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/technical_match_model.dart";
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
//TODO try add other team's climb
final String query = """
query FetchCoach {
  matches(order_by: {match_type: {order: asc}, match_number: asc}) {
    happened
    match_number
    match_type {
      title
    }
        ${teamValues.map(
          (final String e) => """$e {
      colors_index
      id
      name
      number
      secondary_technicals(where: {ignored: {_eq: false}}, order_by: {match: {id: asc, match_number: asc}, is_rematch: asc}) {
        _2023_secondary_technical_events(order_by: {match_id: asc, timestamp: asc}) {
          event_type_id
          timestamp
        }
        schedule_match_id
        scouter_name
        starting_position_id
        team_id
        robot_match_status {
          title
        }
      }
      technical_matches_v3(where: {ignored: {_eq: false}}, order_by: {match: {id: asc, match_number: asc}, is_rematch: asc}) {
        auto_balance {
          title
          auto_points
        }
        auto_cones_delivered
        auto_cones_failed
        auto_cones_scored
        auto_cubes_delivered
        auto_cubes_failed
        auto_cubes_scored
        endgame_balance {
          title
          endgame_points
        }
        robot_match_status {
          title
        }
        schedule_match_id
        scouter_name
        tele_cones_delivered
        tele_cones_failed
        tele_cones_scored
        tele_cubes_delivered
        tele_cubes_failed
        tele_cubes_scored
        _2023_technical_events(order_by: {match_id: asc, timestamp: asc}) {
          event_type_id
          timestamp
        }
      }
      technical_matches_v3_aggregate {
        aggregate {
          avg {
            auto_cones_delivered
            auto_cones_failed
            auto_cones_scored
            auto_cubes_delivered
            auto_cubes_failed
            auto_cubes_scored
            tele_cones_delivered
            tele_cones_failed
            tele_cones_scored
            tele_cubes_delivered
            tele_cubes_failed
            tele_cubes_scored
          }
        }
        nodes {
         auto_balance{
          title
          auto_points
        }
        endgame_balance{
          title
          endgame_points
        }
        robot_match_status{
          title
        }
      }
      }
    }""",
        ).join(" ")}
}}""";

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
                final dynamic avg = match[e]["technical_matches_v3_aggregate"]
                    ["aggregate"]["avg"];
                final bool nullValidator = avg["auto_cones_scored"] == null;
                final int amountOfMatches = (match[e]
                            ["technical_matches_v3_aggregate"]["nodes"]
                        as List<dynamic>)
                    .length;
                final List<MatchEvent> locations = getEvents(
                  match[e]["secondary_technicals"] as List<dynamic>,
                  "_2023_secondary_technical_events",
                );
                final List<MatchEvent> robotEvents = getEvents(
                  match[e]["technical_matches_v3"] as List<dynamic>,
                  "_2023_technical_events",
                );

                final List<Cycle> cycles =
                    getCycles(robotEvents, locations, context);
                final double avgCycles = cycles.isNotEmpty
                    ? cycles.length / amountOfMatches
                    : double.nan;
                final double avgCycleTime = cycles
                        .map((final Cycle cycle) => cycle.getLength())
                        .toList()
                        .averageOrNull ??
                    double.nan;
                final double avgAutoConesScored = nullValidator
                    ? double.nan
                    : avg["auto_cones_scored"] as double;
                final double avgAutoCubesScored = nullValidator
                    ? double.nan
                    : avg["auto_cubes_scored"] as double;
                final double avgAutoGamepiece = nullValidator
                    ? double.nan
                    : getPieces(parseByMode(MatchMode.auto, avg));
                final double avgAutoFailed = nullValidator
                    ? double.nan
                    : (avg["auto_cubes_failed"] as double) +
                        (avg["auto_cones_failed"] as double);
                final double avgTeleGamepiece = nullValidator
                    ? double.nan
                    : getPieces(parseByMode(MatchMode.tele, avg));
                final double avgTeleFailed = nullValidator
                    ? double.nan
                    : (avg["tele_cubes_failed"] as double) +
                        (avg["tele_cones_failed"] as double);
                return CoachViewLightTeam(
                  team: team,
                  isBlue: e.startsWith("blue"),
                  avgCycles: avgCycles,
                  amountOfMatches: amountOfMatches,
                  avgCycleTime: avgCycleTime,
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
    required this.team,
    required this.isBlue,
    required this.avgCycles,
    required this.amountOfMatches,
    required this.avgCycleTime,
  });
  final LightTeam team;
  final bool isBlue;
  final int amountOfMatches;
  final double avgCycles;
  final double avgCycleTime;
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
                      const Spacer(),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Avg Cycle Time: ${(team.avgCycleTime / 1000).toStringAsFixed(2)}",
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Avg Cycles: ${(team.avgCycles).toStringAsFixed(2)}",
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Text(
                            "Matches Played: ${team.amountOfMatches}",
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
