import "dart:collection";

import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

const String query = """
query FetchCompare(\$ids: [Int!]) {
  team(where: {id: {_in: \$ids}}) {
    matches_aggregate(where: {ignored: {_eq: false}}) {
      aggregate {
        avg {
          auto_lower
          auto_upper
          auto_missed
          tele_lower
          tele_upper
          tele_missed
        }
      }
    }
    matches(where: {ignored: {_eq: false}},order_by:[ {match: {match_type: {order: asc}}},{ match:{match_number:asc}},{is_rematch: asc}]) {
      climb {
        points
        title
      }
      robot_match_status{
        title
      }
      auto_lower
      auto_upper
      auto_missed
      match{
        match_number
      }
      tele_lower
      tele_upper
      tele_missed
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
                .map<CompareTeam>((final dynamic e) {
              final LightTeam team = LightTeam(
                e["id"] as int,
                e["number"] as int,
                e["name"] as String,
                e["colors_index"] as int,
              );
              final double avgAutoUpper = e["matches_aggregate"]["aggregate"]
                      ["avg"]["auto_upper"] as double? ??
                  0;
              final double avgAutoMissed = e["matches_aggregate"]["aggregate"]
                      ["avg"]["auto_missed"] as double? ??
                  0;
              final double avgAutoLower = e["matches_aggregate"]["aggregate"]
                      ["avg"]["auto_lower"] as double? ??
                  0;
              final double autoUpperScorePercentage =
                  ((avgAutoUpper + avgAutoLower) /
                          (avgAutoUpper + avgAutoMissed + avgAutoLower)) *
                      100;
              final double avgTeleUpper = e["matches_aggregate"]["aggregate"]
                      ["avg"]["tele_upper"] as double? ??
                  0;
              final double avgTeleMissed = e["matches_aggregate"]["aggregate"]
                      ["avg"]["tele_missed"] as double? ??
                  0;
              final double avgTeleLower = e["matches_aggregate"]["aggregate"]
                      ["avg"]["tele_lower"] as double? ??
                  0;
              final double teleUpperPointPercentage =
                  ((avgTeleUpper + avgTeleLower) /
                          (avgTeleUpper + avgTeleMissed + avgTeleLower)) *
                      100;

              final List<String> climbVals = (e["matches"] as List<dynamic>)
                  .map((final dynamic e) => e["climb"]["title"] as String)
                  .toList();
              final Iterable<int> climbPoints = (e["matches"] as List<dynamic>)
                  .where(
                    (final dynamic element) =>
                        element["climb"]["title"] != "No attempt",
                  )
                  .map((final dynamic e) => e["climb"]["points"] as int);

              final int failedClimb = climbVals
                  .where(
                    (final String element) => element == "Failed",
                  )
                  .length;
              final int succededClimb = climbVals
                      .where(
                        (final String element) => element != "No attempt",
                      )
                      .length -
                  failedClimb;
              final List<RobotMatchStatus> matchStatuses =
                  (e["matches"] as List<dynamic>)
                      .map(
                        (final dynamic e) => titleToEnum(
                          e["robot_match_status"]["title"] as String,
                        ),
                      )
                      .toList();
              final double climbSuccessPercent =
                  (succededClimb / (succededClimb + failedClimb)) * 100;
              final List<int> climbLineChartPoints =
                  climbVals.map<int>((final String e) {
                switch (e) {
                  case "Failed":
                    return 0;
                  case "No attempt":
                    return -1;
                  case "Level 1":
                    return 1;
                  case "Level 2":
                    return 2;
                  case "Level 3":
                    return 3;
                  case "Level 4":
                    return 4;
                }
                throw Exception("Not a climb value");
              }).toList();

              final CompareLineChartData climbData = CompareLineChartData(
                points: climbLineChartPoints.toList(),
                matchStatuses: matchStatuses,
              );

              final List<int> upperScoredDataTele =
                  (e["matches"] as List<dynamic>)
                      .map((final dynamic e) => e["tele_upper"] as int)
                      .toList();
              final List<int> missedDataTele = (e["matches"] as List<dynamic>)
                  .map(
                    (final dynamic e) => e["tele_missed"] as int,
                  )
                  .toList();

              final CompareLineChartData upperScoredDataTeleLineChart =
                  CompareLineChartData(
                points: upperScoredDataTele.toList(),
                matchStatuses: matchStatuses,
              );

              final CompareLineChartData missedDataTeleLineChart =
                  CompareLineChartData(
                points: missedDataTele.toList(),
                matchStatuses: matchStatuses,
              );

              final List<int> upperScoredDataAuto =
                  (e["matches"] as List<dynamic>)
                      .map((final dynamic e) => e["auto_upper"] as int)
                      .toList();
              final List<int> missedDataAuto = (e["matches"] as List<dynamic>)
                  .map(
                    (final dynamic e) => e["auto_missed"] as int,
                  )
                  .toList();

              final List<int> allBallsScored = (e["matches"] as List<dynamic>)
                  .map(
                    (final dynamic e) =>
                        (e["auto_upper"] as int) +
                        (e["tele_upper"] as int) +
                        (e["auto_lower"] as int) +
                        (e["tele_lower"] as int),
                  )
                  .toList();
              final CompareLineChartData upperScoredDataAutoLinechart =
                  CompareLineChartData(
                points: upperScoredDataAuto.toList(),
                matchStatuses: matchStatuses,
              );

              final CompareLineChartData allBallsScoredLinechart =
                  CompareLineChartData(
                points: allBallsScored.toList(),
                matchStatuses: matchStatuses,
              );

              final CompareLineChartData missedDataAutoLinechart =
                  CompareLineChartData(
                points: missedDataAuto.toList(),
                matchStatuses: matchStatuses,
              );
              final CompareLineChartData pointsLinechart = CompareLineChartData(
                points: (e["matches"] as List<dynamic>)
                    .map(
                      (final dynamic e) =>
                          (e["auto_upper"] as int) * 4 +
                          (e["auto_lower"] as int) * 2 +
                          (e["tele_upper"] as int) * 2 +
                          (e["tele_lower"] as int) +
                          (e["climb"]["points"] as int),
                    )
                    .toList(),
                matchStatuses: matchStatuses,
              );

              return CompareTeam(
                pointsData: pointsLinechart,
                allBallsScored: allBallsScoredLinechart,
                team: team,
                autoUpperScoredPercentage: autoUpperScorePercentage,
                avgAutoUpperScored: avgAutoUpper,
                avgClimbPoints: climbPoints.isEmpty
                    ? double.nan
                    : climbPoints.length == 1
                        ? climbPoints.single.toDouble()
                        : climbPoints.reduce(
                              (final int value, final int element) =>
                                  value + element,
                            ) /
                            climbPoints.length,
                avgTeleUpperScored: avgTeleUpper,
                climbPercentage: climbSuccessPercent,
                teleUpperScoredPercentage: teleUpperPointPercentage,
                climbData: climbData,
                upperScoredDataAuto: upperScoredDataAutoLinechart,
                missedDataAuto: missedDataAutoLinechart,
                upperScoredDataTele: upperScoredDataTeleLineChart,
                missedDataTele: missedDataTeleLineChart,
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
