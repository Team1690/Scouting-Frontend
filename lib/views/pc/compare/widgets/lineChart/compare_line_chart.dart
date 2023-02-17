import "dart:math";

import "package:flutter/material.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/common/dashboard_linechart.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class CompareLineChart extends StatelessWidget {
  const CompareLineChart(this.data, this.colors, this.title);
  final List<CompareLineChartData> data;
  final List<Color> colors;
  final String title;
  @override
  Widget build(final BuildContext context) => Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Text(title),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              top: 40,
            ),
            child: DashboardLineChart(
              robotMatchStatuses: data
                  .map((final CompareLineChartData e) => e.matchStatuses)
                  .toList(),
              showShadow: false,
              inputedColors: colors,
              gameNumbers: List<MatchIdentifier>.generate(
                data
                    .map((final CompareLineChartData e) => e.points.length)
                    .reduce(max),
                (final int index) => MatchIdentifier(
                  number: index + 1,
                  type: "Quals",
                  isRematch: false,
                ),
              ),
              dataSet: data
                  .map(
                    (final CompareLineChartData e) => e.points,
                  )
                  .toList(),
            ),
          ),
        ],
      );
}
