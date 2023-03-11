import "dart:collection";
import "package:flutter/material.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/pc/compare/widgets/spiderChart/radar_chart.dart";

class CompareSpiderChart extends StatelessWidget {
  const CompareSpiderChart(this.data);
  final SplayTreeSet<CompareTeam> data;

  Iterable<CompareTeam> get emptyTeams => data.where(
        (final CompareTeam team) => team.gamepieces.points.length < 2,
      );

  @override
  Widget build(final BuildContext context) => emptyTeams.isNotEmpty
      ? Container()
      : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Builder(
            builder: (final BuildContext context) {
              final double autoBalanceRatio = 100 /
                  data
                      .map(
                        (final CompareTeam team) =>
                            team.avgAutoBalancePoints == double.nan
                                ? 0
                                : team.avgAutoBalancePoints,
                      )
                      .fold(
                        0,
                        (final num previousValue, final num element) =>
                            previousValue < element ? element : previousValue,
                      );
              final double endgameBalanceRatio = 100 /
                  data
                      .map(
                        (final CompareTeam team) =>
                            team.avgEndgameBalancePoints == double.nan
                                ? 0
                                : team.avgEndgameBalancePoints,
                      )
                      .fold(
                        0,
                        (final num previousValue, final num element) =>
                            previousValue < element ? element : previousValue,
                      );
              final double cycleTimeRatio = 100 /
                  data
                      .map(
                        (final CompareTeam team) =>
                            team.avgCycleTime == double.nan
                                ? 0
                                : team.avgCycleTime,
                      )
                      .fold(
                        0,
                        (final num previousValue, final num element) =>
                            previousValue < element ? element : previousValue,
                      );
              final double feederTimeRatio = 100 /
                  data
                      .map(
                        (final CompareTeam team) =>
                            team.avgFeederTime == double.nan
                                ? 0
                                : team.avgFeederTime,
                      )
                      .fold(
                        0,
                        (final num previousValue, final num element) =>
                            previousValue < element ? element : previousValue,
                      );
              final double placingTimeRatio = 100 /
                  data
                      .map(
                        (final CompareTeam team) =>
                            team.avgPlacingTime == double.nan
                                ? 0
                                : team.avgPlacingTime,
                      )
                      .fold(
                        0,
                        (final num previousValue, final num element) =>
                            previousValue < element ? element : previousValue,
                      );
              return SpiderChart(
                colors: data
                    .map(
                      (final CompareTeam team) => team.team.color,
                    )
                    .toList(),
                numberOfFeatures: 7,
                data: data
                    .map<List<int>>(
                      (final CompareTeam team) => <double>[
                        team.endgameBalanceSuccessPercentage,
                        team.autoBalanceSuccessPercentage,
                        team.avgEndgameBalancePoints * endgameBalanceRatio,
                        team.avgAutoBalancePoints * autoBalanceRatio,
                        team.avgCycleTime * cycleTimeRatio,
                        team.avgFeederTime * feederTimeRatio,
                        team.avgPlacingTime * placingTimeRatio,
                      ]
                          .map<int>(
                            (final double e) =>
                                e.isNaN || e.isInfinite ? 0 : e.toInt(),
                          )
                          .toList(),
                    )
                    .toList(),
                ticks: const <int>[0, 25, 50, 75, 100],
                features: const <String>[
                  "Endgame Balance%",
                  "Auto Balance%",
                  "Endgame Balance Score%",
                  "Auto Balance Score%",
                  "Cycle Time%",
                  "Feeder Time%",
                  "Placing Time%",
                ],
              );
            },
          ),
        );
}
