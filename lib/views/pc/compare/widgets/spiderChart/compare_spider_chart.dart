import "dart:collection";
import "dart:math";

import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/pc/compare/widgets/spiderChart/radar_chart.dart";

class CompareSpiderChart<E extends num> extends StatelessWidget {
  const CompareSpiderChart(this.data);
  final SplayTreeSet<CompareTeam<E>> data;

  Iterable<CompareTeam<E>> get emptyTeams => data
      .where((final CompareTeam<E> team) => team.climbData.points.length < 2);

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
                          (final CompareTeam<E> e) => e.avgAutoUpperScored,
                        )
                        .reduce(max);
                final double teleRatio = 100 /
                    data
                        .map(
                          (final CompareTeam<E> e) => e.avgTeleUpperScored,
                        )
                        .reduce(max);
                final double climbPointsRatio = 100 /
                    data
                        .map(
                          (final CompareTeam<E> e) => e.avgClimbPoints,
                        )
                        .reduce(max);
                return SpiderChart(
                  colors: data
                      .map(
                        (final CompareTeam<E> element) =>
                            colors[element.team.colorsIndex],
                      )
                      .toList(),
                  numberOfFeatures: 6,
                  data: data
                      .map<List<int>>(
                        (final CompareTeam<E> e) => <int>[
                          (e.avgAutoUpperScored * autoRatio).toInt(),
                          e.autoUpperScoredPercentage.toInt(),
                          (e.avgTeleUpperScored * teleRatio).toInt(),
                          e.teleUpperScoredPercentage.toInt(),
                          (e.avgClimbPoints * climbPointsRatio).toInt(),
                          e.climbPercentage.toInt()
                        ],
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
