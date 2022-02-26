import "dart:math";

import "package:flutter/material.dart";
import "package:scouting_frontend/views/pc/compare/models/compare_classes.dart";
import "package:scouting_frontend/views/common/dashboard_linechart.dart";

class CompareLineChart<E extends num> extends StatelessWidget {
  const CompareLineChart(this.data);
  final List<CompareLineChartData<E>> data;
  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment(-1, -1),
          child: Text(data[0].title),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            top: 40,
          ),
          child: DashboardLineChart<E>(
            inputedColors:
                data.map((final CompareLineChartData<E> e) => e.color).toList(),
            gameNumbers: List<int>.generate(
              data
                  .map((final CompareLineChartData<E> e) => e.points.length)
                  .reduce(max),
              (final int index) => index + 1,
            ),
            distanceFromHighest: 4,
            dataSet: data
                .map(
                  (final CompareLineChartData<E> e) => e.points,
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
