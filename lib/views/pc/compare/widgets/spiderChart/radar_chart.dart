import "package:flutter/material.dart";
import "package:flutter_radar_chart/flutter_radar_chart.dart";

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
  bool isPC(final BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return false;

      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return true;
    }
  }

  final List<Color> colors;
  final List<List<int>> data;
  final List<int> ticks;
  final List<String> features;

  @override
  Widget build(final BuildContext context) {
    return Container(
      child: RadarChart(
        graphColors: colors,
        reverseAxis: false,
        data: data,
        features: features,
        ticks: ticks,
        axisColor: Colors.white,
        outlineColor: Colors.white54,
        featuresTextStyle: Theme.of(context)
            .textTheme
            .bodyText2!
            .copyWith(fontSize: isPC(context) ? null : 10),
        ticksTextStyle: TextStyle(fontSize: 0),
      ),
    );
  }
}
