import "dart:collection";
import "dart:math";

import "package:flutter/material.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/pc/compare/widgets/spiderChart/radar_chart.dart";

class CompareSpiderChart extends StatelessWidget {
  const CompareSpiderChart(this.data);
  final SplayTreeSet<CompareTeam> data;

  Iterable<CompareTeam> get emptyTeams =>
      data.where((final CompareTeam team) => team.climbData.points.length < 2);

  @override
  Widget build(final BuildContext context) {
    return emptyTeams.isNotEmpty
        ? Container()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Builder(
              builder: (final BuildContext context) {
                final double autoRatio = 100 /
                    data
                        .map(
                          (final CompareTeam e) => e.avgAutoUpperScored,
                        )
                        .reduce(max);
                final double teleRatio = 100 /
                    data
                        .map(
                          (final CompareTeam e) => e.avgTeleUpperScored,
                        )
                        .reduce(max);
                final double climbPointsRatio = 100 /
                    data
                        .map(
                          (final CompareTeam e) => e.avgClimbPoints,
                        )
                        .reduce(max);
                return SpiderChart(
                  colors: data
                      .map(
                        (final CompareTeam element) => element.team.color,
                      )
                      .toList(),
                  numberOfFeatures: 6,
                  data: data
                      .map<List<int>>(
                        (final CompareTeam e) => <double>[
                          e.avgAutoUpperScored * autoRatio,
                          e.autoUpperScoredPercentage,
                          e.avgTeleUpperScored * teleRatio,
                          e.teleUpperScoredPercentage,
                          e.avgClimbPoints * climbPointsRatio,
                          e.climbPercentage
                        ]
                            .map<int>(
                              (final double e) =>
                                  e.isNaN || e.isInfinite ? 0 : e.toInt(),
                            )
                            .toList(),
                      )
                      .toList(),
                  ticks: <int>[0, 25, 50, 75, 100],
                  features: <String>[
                    "Auto upper",
                    "Auto scoring%",
                    "Teleop upper",
                    "Teleop scoring%",
                    "Climb points",
                    "Climb%"
                  ],
                );
              },
            ),
          );
  }
}
