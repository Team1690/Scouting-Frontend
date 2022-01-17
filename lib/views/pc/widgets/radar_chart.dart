import "package:flutter/material.dart";
import "package:flutter_radar_chart/flutter_radar_chart.dart";
import "package:scouting_frontend/views/constants.dart";

class SpiderChart extends StatelessWidget {
  SpiderChart({
    required final int numberOfFeatures,
    required final List<List<int>> data,
    required final List<int> ticks,
    required final List<String> features,
  }) : this.inner(
          ticks: ticks,
          numberOfFeatures: numberOfFeatures,
          features: features.sublist(0, numberOfFeatures),
          data: data
              .map((final List<int> e) => e.sublist(0, numberOfFeatures))
              .toList(),
        );

  SpiderChart.inner({
    required this.data,
    required this.features,
    required this.numberOfFeatures,
    required this.ticks,
  });

  final int numberOfFeatures;
  final List<List<int>> data;
  final List<int> ticks;
  final List<String> features;
  final bool darkMode = false;
  final bool useSides = false;

  @override
  Widget build(final BuildContext context) {
    return Container(
      child: RadarChart(
        graphColors: colors,
        reverseAxis: false,
        data: data,
        features: features,
        ticks: ticks,
        // ticksTextStyle: Theme.of(context).textTheme.subtitle1,
        axisColor: primaryWhite,
        outlineColor: secondaryWhite,
        featuresTextStyle: Theme.of(context).textTheme.bodyText2!,
      ),
    );
  }
}
