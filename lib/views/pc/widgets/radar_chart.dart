import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:scouting_frontend/views/constants.dart';

// ignore: must_be_immutable
class SpiderChart extends StatefulWidget {
  SpiderChart({
    required this.numberOfFeatures,
    required this.data,
    required this.ticks,
    required this.features,
  });

  final double numberOfFeatures;
  List<List<int>> data;
  final List<int> ticks;
  List<String> features;
  @override
  _SpiderChart createState() => _SpiderChart();
}

class _SpiderChart extends State<SpiderChart> {
  bool darkMode = false;
  bool useSides = false;

  @override
  Widget build(BuildContext context) {
    widget.features =
        widget.features.sublist(0, widget.numberOfFeatures.floor());
    widget.data = widget.data
        .map((graph) => graph.sublist(0, widget.numberOfFeatures.floor()))
        .toList();

    return Container(
      child: RadarChart(
        graphColors: colors,
        reverseAxis: false,
        data: widget.data,
        features: widget.features,
        ticks: widget.ticks,
        // ticksTextStyle: Theme.of(context).textTheme.subtitle1,
        axisColor: primaryWhite,
        outlineColor: secondaryWhite,

        featuresTextStyle: Theme.of(context).textTheme.bodyText2!,
      ),
    );
  }
}
