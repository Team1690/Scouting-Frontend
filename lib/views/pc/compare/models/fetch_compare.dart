import "dart:collection";

import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";

const String query = """
query MyQuery(\$ids: [Int!]) {
  team(where: {id: {_in: \$ids}}) {
    matches_aggregate {
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
    matches(order_by: {match_number: asc}) {
      climb {
        points
        title
      }
      auto_lower
      auto_upper
      auto_missed
      match_number
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

Future<SplayTreeSet<CompareTeam<E>>> fetchData<E extends num>(
  final List<int> ids,
) async {
  final GraphQLClient client = getClient();

  final QueryResult result = await client.query(
    QueryOptions(
      document: gql(query),
      variables: <String, dynamic>{
        "ids": ids,
      },
    ),
  );
  return result.mapQueryResult<SplayTreeSet<CompareTeam<E>>>(
      (final Map<String, dynamic>? data) {
    return data.mapNullable<SplayTreeSet<CompareTeam<E>>>(
          (final Map<String, dynamic> teams) {
            return SplayTreeSet<CompareTeam<E>>.from(
                (teams["team"] as List<dynamic>)
                    .map<CompareTeam<E>>((final dynamic e) {
                  final LightTeam team = LightTeam(
                    e["id"] as int,
                    e["number"] as int,
                    e["name"] as String,
                    e["colors_index"] as int,
                  );
                  final double avgAutoUpper = e["matches_aggregate"]
                          ["aggregate"]["avg"]["auto_upper"] as double? ??
                      0;
                  final double avgAutoMissed = e["matches_aggregate"]
                          ["aggregate"]["avg"]["auto_missed"] as double? ??
                      0;
                  final double avgAutoLower = e["matches_aggregate"]
                          ["aggregate"]["avg"]["auto_lower"] as double? ??
                      0;
                  final double autoUpperScorePercentage =
                      ((avgAutoUpper + avgAutoLower) /
                              (avgAutoUpper + avgAutoMissed + avgAutoLower)) *
                          100;
                  final double avgTeleUpper = e["matches_aggregate"]
                          ["aggregate"]["avg"]["tele_upper"] as double? ??
                      0;
                  final double avgTeleMissed = e["matches_aggregate"]
                          ["aggregate"]["avg"]["tele_missed"] as double? ??
                      0;
                  final double avgTeleLower = e["matches_aggregate"]
                          ["aggregate"]["avg"]["tele_lower"] as double? ??
                      0;
                  final double teleUpperPointPercentage =
                      ((avgTeleUpper + avgTeleLower) /
                              (avgTeleUpper + avgTeleMissed + avgTeleLower)) *
                          100;

                  final List<String> climbVals = (e["matches"] as List<dynamic>)
                      .map((final dynamic e) => e["climb"]["title"] as String)
                      .toList();
                  final Iterable<int> climbPoints = (e["matches"]
                          as List<dynamic>)
                      .map((final dynamic e) => e["climb"]["points"] as int);

                  final int failedClimb = climbVals
                      .where(
                        (final String element) =>
                            element == "Failed" || element == "No attempt",
                      )
                      .length;
                  final int succededClimb = climbVals.length - failedClimb;

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

                  final CompareLineChartData<E> climbData =
                      CompareLineChartData<E>(
                    color: colors[team.colorsIndex],
                    title: "Climb",
                    points: climbLineChartPoints.castToGeneric<E>().toList(),
                  );

                  final List<int> upperScoredDataTele =
                      (e["matches"] as List<dynamic>)
                          .map((final dynamic e) => e["tele_upper"] as int)
                          .toList();
                  final List<int> missedDataTele =
                      (e["matches"] as List<dynamic>)
                          .map(
                            (final dynamic e) => e["tele_missed"] as int,
                          )
                          .toList();

                  final CompareLineChartData<E> upperScoredDataTeleLineChart =
                      CompareLineChartData<E>(
                    color: colors[team.colorsIndex],
                    title: "Teleop upper",
                    points: upperScoredDataTele.castToGeneric<E>().toList(),
                  );

                  final CompareLineChartData<E> missedDataTeleLineChart =
                      CompareLineChartData<E>(
                    color: colors[team.colorsIndex],
                    title: "Teleop missed",
                    points: missedDataTele.castToGeneric<E>().toList(),
                  );

                  final List<int> upperScoredDataAuto =
                      (e["matches"] as List<dynamic>)
                          .map((final dynamic e) => e["auto_upper"] as int)
                          .toList();
                  final List<int> missedDataAuto =
                      (e["matches"] as List<dynamic>)
                          .map(
                            (final dynamic e) => e["auto_missed"] as int,
                          )
                          .toList();

                  final CompareLineChartData<E> upperScoredDataAutoLinechart =
                      CompareLineChartData<E>(
                    color: colors[team.colorsIndex],
                    title: "Auto upper",
                    points: upperScoredDataAuto.castToGeneric<E>().toList(),
                  );

                  final CompareLineChartData<E> missedDataAutoLinechart =
                      CompareLineChartData<E>(
                    color: colors[team.colorsIndex],
                    title: "Auto missed",
                    points: missedDataAuto.castToGeneric<E>().toList(),
                  );

                  return CompareTeam<E>(
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
                }), (final CompareTeam<E> team1, final CompareTeam<E> team2) {
              return team1.team.id.compareTo(team2.team.id);
            });
          },
        ) ??
        (throw Exception("Error shoudn't happen"));
  });
}
