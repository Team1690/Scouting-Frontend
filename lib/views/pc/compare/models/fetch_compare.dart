import "dart:collection";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/average_or_null.dart";
import "package:scouting_frontend/models/cycle_model.dart";
import "package:scouting_frontend/models/event_model.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/technical_match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

const String query = """
query FetchCompare(\$ids: [Int!]) {
  team(where: {id: {_in: \$ids}}) {
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
  }
}

""";

Future<SplayTreeSet<CompareTeam>> fetchData(
  final List<int> ids,
  final BuildContext context,
) async {
  final GraphQLClient client = getClient();

  final QueryResult<SplayTreeSet<CompareTeam>> result = await client.query(
    QueryOptions<SplayTreeSet<CompareTeam>>(
      parserFn: (final Map<String, dynamic> teams) =>
          SplayTreeSet<CompareTeam>.from(
        (teams["team"] as List<dynamic>)
            .map<CompareTeam>((final dynamic teamsTable) {
          final LightTeam team = LightTeam.fromJson(teamsTable);
          final List<dynamic> matches =
              teamsTable["technical_matches_v3"] as List<dynamic>;
          final List<int> autoGamepieces = matches
              .map(
                (final dynamic technicalMatch) => (getPieces(
                  parseByMode(MatchMode.auto, technicalMatch),
                ).toInt()),
              )
              .toList();
          final List<int> teleGamepieces = matches
              .map(
                (final dynamic technicalMatch) => (getPieces(
                  parseByMode(MatchMode.tele, technicalMatch),
                ).toInt()),
              )
              .toList();
          final List<int> gamepieces = matches
              .map(
                (final dynamic technicalMatch) => (getPieces(
                  parseMatch(technicalMatch),
                ).toInt()),
              )
              .toList();
          final List<String> autoBalanceVals = matches
              .map(
                (final dynamic match) =>
                    (match["robot_match_status"]["title"] as String) !=
                            "Didn't come to field"
                        ? match["auto_balance"]["title"] as String
                        : "No Attempt",
              )
              .toList();
          final double avgAutoBalancePoints = matches
                  .map(
                    (final dynamic match) =>
                        (match["robot_match_status"]["title"] as String) !=
                                "Didn't come to field"
                            ? (match["auto_balance"]["auto_points"] as int)
                            : 0,
                  )
                  .toList()
                  .averageOrNull ??
              double.nan;
          final List<String> endgameBalanceVals = matches
              .map(
                (final dynamic match) =>
                    (match["robot_match_status"]["title"] as String) !=
                            "Didn't come to field"
                        ? match["endgame_balance"]["title"] as String
                        : "No Attempt",
              )
              .toList();
          final double avgEndgameBalancePoints = matches
                  .map(
                    (final dynamic match) => (match["robot_match_status"]
                                ["title"] as String) !=
                            "Didn't come to field"
                        ? (match["endgame_balance"]["endgame_points"] as int)
                        : 0,
                  )
                  .toList()
                  .averageOrNull ??
              double.nan;
          final List<int> totalCones = matches
              .map(
                (final dynamic match) =>
                    (match["auto_cones_delivered"] as int) +
                    (match["tele_cones_delivered"] as int) +
                    (match["auto_cones_scored"] as int) +
                    (match["tele_cones_scored"] as int),
              )
              .toList();
          final List<int> totalCubes = matches
              .map(
                (final dynamic match) =>
                    (match["auto_cubes_delivered"] as int) +
                    (match["tele_cubes_delivered"] as int) +
                    (match["auto_cubes_scored"] as int) +
                    (match["tele_cubes_scored"] as int),
              )
              .toList();
          final List<MatchEvent> robotEvents =
              getEvents(matches, "_2023_technical_events");
          final List<MatchEvent> locations = getEvents(
            teamsTable["secondary_technicals"] as List<dynamic>,
            "_2023_secondary_technical_events",
          );
          final List<Cycle> cycles = getCycles(robotEvents, locations, context);
          final double avgCycleTime = cycles
                  .map((final Cycle cycle) => cycle.getLength())
                  .toList()
                  .averageOrNull ??
              double.nan;
          final int autoBalanceFailed = autoBalanceVals
              .where((final String title) => title == "Failed")
              .length;
          final double avgPlacingTime =
              getPlacingTime(locations, robotEvents, context);
          final double avgFeederTime = getFeederTime(locations, context);
          final int autoBalanceSucceded = autoBalanceVals
                  .where(
                    (final String element) => element != "No Attempt",
                  )
                  .length -
              autoBalanceFailed;
          final double autoBalanceSuccessPercentage = (autoBalanceSucceded) /
              (autoBalanceSucceded + autoBalanceFailed) *
              100;
          final List<int> autoBalanceLineChartPoints =
              autoBalanceVals.map<int>((final String title) {
            switch (title) {
              case "No Attempt":
                return -1;
              case "Failed":
                return 0;
              case "Unbalanced":
                return 1;
              case "Balanced":
                return 2;
            }
            throw Exception("Not a auto balance value");
          }).toList();
          final int endgameBalanceFailed = endgameBalanceVals
              .where((final String title) => title == "Failed")
              .length;

          final int endgameBalanceSucceded = endgameBalanceVals
                  .where(
                    (final String element) => element != "No Attempt",
                  )
                  .length -
              endgameBalanceFailed;
          final double endgameBalanceSuccessPercentage =
              (endgameBalanceSucceded) /
                  (endgameBalanceSucceded + endgameBalanceFailed) *
                  100;
          final List<int> endgameBalanceLineChartPoints =
              endgameBalanceVals.map<int>((final String title) {
            switch (title) {
              case "No Attempt":
                return -1;
              case "Failed":
                return 0;
              case "Unbalanced":
                return 1;
              case "Balanced":
                return 2;
            }
            throw Exception("Not a endgame balance value");
          }).toList();
          final List<RobotMatchStatus> matchStatuses = matches
              .map(
                (final dynamic e) => titleToEnum(
                  e["robot_match_status"]["title"] as String,
                ),
              )
              .toList();
          final List<int> placeTime = matches
              .map(
                (final dynamic match) => getPlacingTime(
                  getEvents(
                    teamsTable["secondary_technicals"] as List<dynamic>,
                    "_2023_secondary_technical_events",
                  )
                      .where(
                        (final MatchEvent location) =>
                            location.matchId == match["schedule_match_id"],
                      )
                      .toList(),
                  getEvents(matches, "_2023_technical_events")
                      .where(
                        (final MatchEvent robotEvent) =>
                            robotEvent.matchId == match["schedule_match_id"],
                      )
                      .toList(),
                  context,
                ),
              )
              .map((final double e) => e.isNaN ? 0 : (e / 100).round())
              .toList();
          final List<int> feederTime = matches
              .map(
                (final dynamic match) => getFeederTime(
                  getEvents(
                    teamsTable["secondary_technicals"] as List<dynamic>,
                    "_2023_secondary_technical_events",
                  )
                      .where(
                        (final MatchEvent location) =>
                            location.matchId ==
                            (match["schedule_match_id"] as int),
                      )
                      .toList(),
                  context,
                ),
              )
              .map((final double e) => e.isNaN ? 0 : (e / 100).round())
              .toList();
          final List<List<Cycle>> cyclesForEachMatch = matches
              .map(
                (final dynamic match) => getCycles(
                  getEvents(matches, "_2023_technical_events")
                      .where(
                        (final MatchEvent robotEvent) =>
                            (match["schedule_match_id"] as int) ==
                            robotEvent.matchId,
                      )
                      .toList(),
                  getEvents(
                    teamsTable["secondary_technicals"] as List<dynamic>,
                    "_2023_secondary_technical_events",
                  )
                      .where(
                        (final MatchEvent location) =>
                            (match["schedule_match_id"] as int) ==
                            location.matchId,
                      )
                      .toList(),
                  context,
                ),
              )
              .toList();
          final CompareLineChartData avgPlacingTimeLineChart =
              CompareLineChartData(
            points: placeTime,
            matchStatuses: matchStatuses,
          );
          final CompareLineChartData avgFeederTimeLineChart =
              CompareLineChartData(
            points: feederTime,
            matchStatuses: matchStatuses,
          );
          final CompareLineChartData avgCycleTimeLineChart =
              CompareLineChartData(
            points: cyclesForEachMatch
                .map(
                  (final List<Cycle> matchCycles) =>
                      matchCycles
                          .map(
                            (final Cycle cycle) => cycle.getLength() / 1000,
                          )
                          .toList()
                          .averageOrNull
                          .mapNullable(
                            (final double average) => average.round(),
                          ) ??
                      0,
                )
                .toList(),
            matchStatuses: matchStatuses,
          );
          final CompareLineChartData cycleAmountLineChart =
              CompareLineChartData(
            points: cyclesForEachMatch
                .map(
                  (final List<Cycle> matchCycles) => matchCycles.length,
                )
                .toList(),
            matchStatuses: matchStatuses,
          );
          final CompareLineChartData endgameBalanceLineChartVals =
              CompareLineChartData(
            points: endgameBalanceLineChartPoints,
            matchStatuses: matchStatuses,
          );
          final CompareLineChartData autoBalanceLineChartVals =
              CompareLineChartData(
            points: autoBalanceLineChartPoints,
            matchStatuses: matchStatuses,
          );
          final CompareLineChartData totalCubesLineChart = CompareLineChartData(
            points: totalCubes,
            matchStatuses: matchStatuses,
          );
          final CompareLineChartData totalConesLineChart = CompareLineChartData(
            points: totalCones,
            matchStatuses: matchStatuses,
          );
          final CompareLineChartData gamepiecesLine = CompareLineChartData(
            points: gamepieces,
            matchStatuses: matchStatuses,
          );
          final CompareLineChartData autoGamepiecesLineChart =
              CompareLineChartData(
            points: autoGamepieces,
            matchStatuses: matchStatuses,
          );
          final CompareLineChartData teleGamepiecesLineChart =
              CompareLineChartData(
            points: teleGamepieces,
            matchStatuses: matchStatuses,
          );

          return CompareTeam(
            autoBalanceSuccessPercentage: autoBalanceSuccessPercentage,
            endgameBalanceSuccessPercentage: endgameBalanceSuccessPercentage,
            autoBalanceVals: autoBalanceLineChartVals,
            endgameBalanceVals: endgameBalanceLineChartVals,
            gamepieces: gamepiecesLine,
            team: team,
            totalCones: totalConesLineChart,
            totalCubes: totalCubesLineChart,
            avgCycleTime: avgCycleTime,
            avgFeederTime: avgFeederTime,
            avgPlacingTime: avgPlacingTime,
            teleGamepieces: teleGamepiecesLineChart,
            autoGamepieces: autoGamepiecesLineChart,
            avgAutoBalancePoints: avgAutoBalancePoints,
            avgEndgameBalancePoints: avgEndgameBalancePoints,
            cycleAmount: cycleAmountLineChart,
            cycleTime: avgCycleTimeLineChart,
            feederTime: avgFeederTimeLineChart,
            placeTime: avgPlacingTimeLineChart,
          );
        }),
        (final CompareTeam team1, final CompareTeam team2) =>
            team1.team.id.compareTo(team2.team.id),
      ),
      document: gql(query),
      variables: <String, dynamic>{
        "ids": ids,
      },
    ),
  );
  return result.mapQueryResult();
}
