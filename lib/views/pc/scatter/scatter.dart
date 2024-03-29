import "dart:math";

import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/scatter/fetch_scatter.dart";
import "package:orbit_standard_library/orbit_standard_library.dart";

class Scatter extends StatefulWidget {
  @override
  State<Scatter> createState() => _ScatterState();
}

class _ScatterState extends State<Scatter> {
  bool isPoints = true;
  @override
  Widget build(final BuildContext context) {
    String? tooltip;
    return DashboardCard(
      title: "",
      titleWidgets: <Widget>[
        ToggleButtons(
          children: <Widget>[
            const Text("Points"),
            const Text("Sum"),
          ]
              .map(
                (final Widget text) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: text,
                ),
              )
              .toList(),
          isSelected: <bool>[isPoints, !isPoints],
          onPressed: (final int pressedIndex) {
            if (pressedIndex == 0) {
              setState(() {
                isPoints = true;
              });
            } else if (pressedIndex == 1) {
              setState(() {
                isPoints = false;
              });
            }
          },
        ),
      ],
      body: Column(
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
                    "Error has happened in the future! ${snapshot.error}",
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return snapshot.data
                          .mapNullable((final List<ScatterData> report) {
                        if (report.isEmpty) {
                          return const Text("No data");
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
                                  (final ScatterData e) => isPoints
                                      ? ScatterSpot(
                                          e.gamepiecePointsAvg,
                                          e.yGamepiecePointsStddev,
                                          dotPainter: FlDotCirclePainter(color: e.team.color,),
                                        )
                                      : ScatterSpot(
                                          e.avgGamepieces,
                                          e.gamepiecesStddev,
                                          dotPainter: FlDotCirclePainter(color: e.team.color,),
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
                                    (final ScatterSpot touchedBarSpot) =>
                                        ScatterTooltipItem(
                                  tooltip!,
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                  bottomMargin: 10,
                                ),
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                axisNameSize: 26,
                                axisNameWidget: isPoints
                                    ? const Text(
                                        "Average gamepiece points",
                                      )
                                    : const Text("Average gamepieces"),
                                sideTitles: SideTitles(
                                  getTitlesWidget: (
                                    final double title,
                                    final TitleMeta meta,
                                  ) =>
                                      Container(child: Text(title.toString())),
                                  showTitles: true,
                                  interval: 5,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                axisNameSize: 26,
                                axisNameWidget: isPoints
                                    ? const Text(
                                        "Gamepiece points standard deviation",
                                      )
                                    : const Text(
                                        "Gamepieces standard deviation",
                                      ),
                                sideTitles: SideTitles(
                                  getTitlesWidget: (
                                    final double title,
                                    final TitleMeta meta,
                                  ) =>
                                      Container(child: Text(title.toString())),
                                  reservedSize: 22,
                                  showTitles: true,
                                  interval: 5,
                                ),
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
                            borderData: FlBorderData(
                              show: true,
                            ),
                            minX: 0,
                            minY: 0,
                            maxX: report
                                .map(
                                  (final ScatterData e) => isPoints
                                      ? (e.gamepiecePointsAvg + 1)
                                          .roundToDouble()
                                      : (e.avgGamepieces + 1).roundToDouble(),
                                )
                                .reduce(max),
                            maxY: report
                                .map(
                                  (final ScatterData e) => isPoints
                                      ? (e.yGamepiecePointsStddev + 1)
                                          .roundToDouble()
                                      : (e.gamepiecesStddev + 1)
                                          .roundToDouble(),
                                )
                                .fold<double>(25.0, max),
                          ),
                        );
                      }) ??
                      (throw Exception("No data"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ScatterData {
  const ScatterData(
    this.gamepiecePointsAvg,
    this.yGamepiecePointsStddev,
    this.team,
    this.avgGamepieces,
    this.gamepiecesStddev,
  );
  final LightTeam team;
  final double gamepiecePointsAvg;
  final double yGamepiecePointsStddev;
  final double avgGamepieces;
  final double gamepiecesStddev;
}
