import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:scouting_frontend/views/constants.dart';

// ignore: must_be_immutable
class SpiderChart extends StatefulWidget {
  SpiderChart({
    Key key,
    @required this.numberOfFeatures,
    @required this.data,
    @required this.ticks,
    @required this.features,
  }) : super(key: key);

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
        reverseAxis: false,
        data: widget.data,
        features: widget.features,
        ticks: widget.ticks,
        axisColor: primaryWhite,
        outlineColor: secondaryWhite,
        featuresTextStyle: TextStyle(color: primaryWhite, fontSize: 10),
      ),
    );
  }
}
