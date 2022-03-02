import "dart:math";

import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/views/pc/scatter/fetch_scatter.dart";

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
                  return snapshot.data
                          .mapNullable((final List<ScatterData> report) {
                        if (report.isEmpty) {
                          return Text("No data");
                        }
                        final List<LightTeam> teams = report
                            .map(
                              (final ScatterData e) => e.team,
                            )
                            .toList();
                        return ScatterChart(
                          ScatterChartData(
                            scatterSpots: report
                                .map(
                                  (final ScatterData e) => ScatterSpot(
                                    e.xBallPointsAvg,
                                    e.yBallPointsStddev,
                                    color: e.team.color,
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
                                .fold<double>(25.0, max),
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
