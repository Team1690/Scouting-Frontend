import "package:flutter/material.dart";
import "package:flutter_radar_chart/flutter_radar_chart.dart";
import "package:scouting_frontend/views/constants.dart";

class SpiderChart extends StatelessWidget {
  SpiderChart({
    required final int numberOfFeatures,
    required final List<List<int>> data,
    required final List<int> ticks,
    required final List<String> features,
    required final List<Color> colors,
  }) : this.inner(
          colors: colors,
          ticks: ticks,
          features: features.sublist(0, numberOfFeatures),
          data: data
              .map((final List<int> e) => e.sublist(0, numberOfFeatures))
              .toList(),
        );

  SpiderChart.inner({
    required this.colors,
    required this.data,
    required this.features,
    required this.ticks,
  });

  final List<Color> colors;
  final List<List<int>> data;
  final List<int> ticks;
  final List<String> features;

  @override
  Widget build(final BuildContext context) => Container(
        child: RadarChart(
          graphColors: colors,
          reverseAxis: false,
          data: data,
          features: features,
          ticks: ticks,
          axisColor: primaryWhite,
          outlineColor: secondaryWhite,
          featuresTextStyle: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontSize: isPC(context) ? null : 10),
          ticksTextStyle: const TextStyle(fontSize: 0),
        ),
      );
}
