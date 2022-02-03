import "dart:math";

import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/models/map_nullable.dart";

class Scatter extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    String? tooltip;
    return Container(
      color: secondaryColor,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: FutureBuilder<List<ScatterData>>(
              future: fetchScatterData(),
              builder: (
                final BuildContext context,
                final AsyncSnapshot<List<ScatterData>> snapshot,
              ) {
                if (snapshot.hasError) {
                  return Text(
                    "Error has happened in the future! " +
                        snapshot.error.toString(),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.data!.isEmpty) {
                    return Text("invalid data :(");
                  }
                  return snapshot.data
                          .mapNullable((final List<ScatterData> report) {
                        final List<LightTeam> teams = report
                            .map(
                              (final ScatterData e) => LightTeam(
                                e.team.id,
                                e.team.number,
                                e.team.name,
                              ),
                            )
                            .toList();
                        return ScatterChart(
                          ScatterChartData(
                            scatterSpots: report
                                .map(
                                  (final ScatterData e) => ScatterSpot(
                                    e.xBallPointsAvg,
                                    e.yBallPointsStddev,
                                  ),
                                )
                                .toList(),
                            scatterTouchData: ScatterTouchData(
                              touchCallback: (
                                final FlTouchEvent event,
                                final ScatterTouchResponse? response,
                              ) {
                                if (response?.touchedSpot != null) {
                                  tooltip =
                                      teams[response!.touchedSpot!.spotIndex]
                                          .number
                                          .toString();
                                }
                              },
                              enabled: true,
                              handleBuiltInTouches: true,
                              touchTooltipData: ScatterTouchTooltipData(
                                tooltipBgColor: bgColor,
                                getTooltipItems:
                                    (final ScatterSpot touchedBarSpot) {
                                  return ScatterTooltipItem(
                                    tooltip!,
                                    textStyle: TextStyle(color: Colors.white),
                                    bottomMargin: 10,
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              rightTitles: SideTitles(showTitles: false),
                              topTitles: SideTitles(showTitles: false),
                              show: true,
                              bottomTitles: SideTitles(
                                interval: 5,
                                showTitles: true,
                              ),
                              leftTitles: SideTitles(
                                interval: 5,
                                showTitles: true,
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              horizontalInterval: 5,
                              verticalInterval: 5,
                              drawHorizontalLine: true,
                              checkToShowHorizontalLine: (final double value) =>
                                  true,
                              getDrawingHorizontalLine: (final double value) =>
                                  FlLine(color: Colors.black.withOpacity(0.1)),
                              drawVerticalLine: true,
                              checkToShowVerticalLine: (final double value) =>
                                  true,
                              getDrawingVerticalLine: (final double value) =>
                                  FlLine(color: Colors.black.withOpacity(0.1)),
                            ),
                            axisTitleData: FlAxisTitleData(
                              show: true,
                              bottomTitle: AxisTitle(
                                showTitle: true,
                                titleText: "Average ball points",
                              ),
                              leftTitle: AxisTitle(
                                showTitle: true,
                                titleText: "Ball point standard deviation",
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                            ),
                            minX: 0,
                            minY: 0,
                            maxX: report
                                .map(
                                  (final ScatterData e) => (e.xBallPointsAvg),
                                )
                                .reduce(max),
                            maxY: report
                                .map(
                                  (final ScatterData e) => e.yBallPointsStddev,
                                )
                                .reduce(max),
                          ),
                        );
                      }) ??
                      (throw Exception("No data"));
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

class ScatterData {
  const ScatterData(this.xBallPointsAvg, this.yBallPointsStddev, this.team);
  final LightTeam team;
  final double xBallPointsAvg;
  final double yBallPointsStddev;
}

const String query = """
query MyQuery {
  team {
    number
    id
    name
    matches_aggregate {
      aggregate {
        avg {
          auto_lower
          auto_upper
          tele_lower
          tele_upper
        }
      }
    }
    matches {
      auto_lower
      auto_upper
      tele_lower
      tele_upper
    }
  }
}

""";
Future<List<ScatterData>> fetchScatterData() async {
  final GraphQLClient client = getClient();

  final QueryResult result =
      await client.query(QueryOptions(document: gql(query)));
  return result.mapQueryResult(
        (final Map<String, dynamic>? data) =>
            data.mapNullable((final Map<String, dynamic> data) {
          return (data["team"] as List<dynamic>)
              .map<ScatterData?>((final dynamic e) {
                final LightTeam team = LightTeam(
                  e["id"] as int,
                  e["number"] as int,
                  e["name"] as String,
                );
                final double? avgAutoUpper = (e["matches_aggregate"]
                        ["aggregate"]["avg"]["auto_upper"] as double?)
                    .mapNullable((final double p0) => p0 * 4);
                final double? avgTeleUpper = (e["matches_aggregate"]
                        ["aggregate"]["avg"]["tele_upper"] as double?)
                    .mapNullable((final double p0) => p0 * 2);
                final double? avgAutoLower = (e["matches_aggregate"]
                        ["aggregate"]["avg"]["auto_lower"] as double?)
                    .mapNullable((final double p0) => p0 * 2);
                final double? avgTeleLower = (e["matches_aggregate"]
                    ["aggregate"]["avg"]["tele_lower"] as double?);
                if (avgTeleUpper == null ||
                    avgTeleLower == null ||
                    avgAutoLower == null ||
                    avgAutoUpper == null) return null;
                final double xBallPointsAvg =
                    avgTeleLower + avgAutoLower + avgTeleUpper + avgAutoUpper;
                final List<dynamic> matches = e["matches"] as List<dynamic>;
                final Iterable<int> matchBallPoints = matches.map(
                  (final dynamic e) => ((e["auto_lower"] as int) * 2 +
                      (e["tele_lower"] as int) * 1 +
                      (e["auto_upper"] as int) * 4 +
                      (e["tele_upper"] as int) * 2),
                );
                double yStddevBallPoints = 0;
                for (final int element in matchBallPoints) {
                  yStddevBallPoints += (element - xBallPointsAvg).abs();
                }
                yStddevBallPoints /= matchBallPoints.length;
                return ScatterData(xBallPointsAvg, yStddevBallPoints, team);
              })
              .where((final ScatterData? element) => element != null)
              .cast<ScatterData>()
              .toList();
        }),
      ) ??
      (throw Exception("No data"));
}
