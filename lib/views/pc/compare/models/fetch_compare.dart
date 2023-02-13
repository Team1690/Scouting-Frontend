import "dart:collection";

import "package:collection/collection.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

const String query = """
query FetchCompare(\$ids: [Int!]) {
  team(where: {id: {_in: \$ids}}) {
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
        }
      }
    }
    technical_matches(where: {ignored: {_eq: false}},order_by:[ {match: {match_type: {order: asc}}},{ match:{match_number:asc}},{is_rematch: asc}]) {
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
      match{
        match_number
      }
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
    }
    name
    number
    id
    colors_index
  }
}
""";

Future<SplayTreeSet<CompareTeam>> fetchData(
  final List<int> ids,
) async {
  final GraphQLClient client = getClient();

  final QueryResult<SplayTreeSet<CompareTeam>> result = await client.query(
    QueryOptions<SplayTreeSet<CompareTeam>>(
      parserFn: (final Map<String, dynamic> teams) {
        return SplayTreeSet<CompareTeam>.from(
            (teams["team"] as List<dynamic>)
                .map<CompareTeam>((final dynamic teamsTable) {
              final LightTeam team = LightTeam.fromJson(teamsTable);
              final List<dynamic> matches =
                  teamsTable["technical_matches"] as List<dynamic>;
              final List<int> autoGamepieces = matches
                  .map(
                    (final dynamic technicalMatch) =>
                        technicalMatch["auto_cones_top"] == null
                            ? 0
                            : (getPieces(
                                parseByMode(MatchMode.auto, technicalMatch),
                              ) as int),
                  )
                  .toList();
              final List<int> teleGamepieces = matches
                  .map(
                    (final dynamic technicalMatch) =>
                        technicalMatch["auto_cones_top"] == null
                            ? 0
                            : (getPieces(
                                parseByMode(MatchMode.tele, technicalMatch),
                              ) as int),
                  )
                  .toList();
              final List<int> gamepieces = matches
                  .map(
                    (final dynamic technicalMatch) =>
                        technicalMatch["auto_cones_top"] == null
                            ? 0
                            : (getPieces(
                                parseMatch(technicalMatch),
                              ) as int),
                  )
                  .toList();
              final List<int> points = matches
                  .map(
                    (final dynamic technicalMatch) =>
                        technicalMatch["auto_cones_top"] == null
                            ? 0
                            : (getPoints(
                                parseMatch(technicalMatch),
                              ) as int),
                  )
                  .toList();
              final List<String> autoBalanceVals = matches
                  .map(
                    (final dynamic match) =>
                        match["auto_balance"]["title"] as String,
                  )
                  .toList();
              final double avgAutoBalancePoints = matches
                  .map(
                    (final dynamic match) =>
                        (match["auto_balance"]["auto_points"] as int),
                  )
                  .toList()
                  .average;
              final List<String> endgameBalanceVals = matches
                  .map(
                    (final dynamic match) =>
                        match["endgame_balance"]["title"] as String,
                  )
                  .toList();
              final double avgEndgameBalancePoints = matches
                  .map(
                    (final dynamic match) =>
                        (match["endgame_balance"]["endgame_points"] as int),
                  )
                  .toList()
                  .average;
              final List<int> totalCones = matches
                  .map(
                    (final dynamic match) => match["auto_cones_low"] == null
                        ? 0
                        : (match["auto_cones_low"] as int) +
                            (match["auto_cones_mid"] as int) +
                            (match["auto_cones_top"] as int) +
                            (match["tele_cones_low"] as int) +
                            (match["tele_cones_mid"] as int) +
                            (match["tele_cones_top"] as int),
                  )
                  .toList();
              final List<int> totalCubes = matches
                  .map(
                    (final dynamic match) => match["auto_cones_low"] == null
                        ? 0
                        : (match["auto_cubes_low"] as int) +
                            (match["auto_cubes_mid"] as int) +
                            (match["auto_cubes_top"] as int) +
                            (match["tele_cubes_low"] as int) +
                            (match["tele_cubes_mid"] as int) +
                            (match["tele_cubes_top"] as int),
                  )
                  .toList();
              //spider
              final dynamic avg =
                  teamsTable["technical_matches_aggregate"]["aggregate"]["avg"];
              final bool nullValidator = avg["auto_cones_top"] == null;
              final double avgTeleGamepiecesPoints = nullValidator
                  ? 0
                  : getPieces(parseByMode(MatchMode.tele, avg));
              final double avgAutoGamepiecePoints = nullValidator
                  ? 0
                  : getPoints(parseByMode(MatchMode.auto, avg));
              final int autoBalanceFailed = autoBalanceVals
                  .where((final String title) => title == "Failed")
                  .length;

              final int autoBalanceSucceded = autoBalanceVals
                      .where(
                        (final String element) => element != "No attempt",
                      )
                      .length -
                  autoBalanceFailed;
              final double autoBalanceSuccessPercentage =
                  (autoBalanceSucceded) /
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
                        (final String element) => element != "No attempt",
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
              final CompareLineChartData totalCubesLineChart =
                  CompareLineChartData(
                points: totalCubes,
                matchStatuses: matchStatuses,
              );
              final CompareLineChartData totalConesLineChart =
                  CompareLineChartData(
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
              final CompareLineChartData pointLineChart = CompareLineChartData(
                points: points,
                matchStatuses: matchStatuses,
              );

              return CompareTeam(
                autoBalanceSuccessPercentage: autoBalanceSuccessPercentage,
                endgameBalanceSuccessPercentage:
                    endgameBalanceSuccessPercentage,
                autoBalanceVals: autoBalanceLineChartVals,
                endgameBalanceVals: endgameBalanceLineChartVals,
                gamepieces: gamepiecesLine,
                points: pointLineChart,
                team: team,
                totalCones: totalConesLineChart,
                totalCubes: totalCubesLineChart,
                teleGamepieces: teleGamepiecesLineChart,
                autoGamepieces: autoGamepiecesLineChart,
                avgAutoGamepiecePoints: avgAutoGamepiecePoints,
                avgTeleGamepiecesPoints: avgTeleGamepiecesPoints,
                avgAutoBalancePoints: avgAutoBalancePoints,
                avgEndgameBalancePoints: avgEndgameBalancePoints,
              );
            }), (final CompareTeam team1, final CompareTeam team2) {
          return team1.team.id.compareTo(team2.team.id);
        });
      },
      document: gql(query),
      variables: <String, dynamic>{
        "ids": ids,
      },
    ),
  );
  return result.mapQueryResult();
}
