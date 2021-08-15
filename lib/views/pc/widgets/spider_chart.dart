import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:scouting_frontend/views/constants.dart';

class SpiderChart extends StatefulWidget {
  const SpiderChart({
    Key key,
    @required this.ticks,
    @required this.features,
    @required this.data,
  }) : super(key: key);

  final List<int> ticks;
  final List<String> features;
  final List<int> data;

  @override
  _SpiderChart createState() => _SpiderChart();
}

class _SpiderChart extends State<SpiderChart> {
  bool darkMode = true;
  bool useSides = true;
  double numberOfFeatures = 6;

  @override
  Widget build(BuildContext context) {
    final ticks = widget.ticks;
    var features = widget.features;
    var data = [
      widget.data,
    ];

    features = features.sublist(0, numberOfFeatures.floor());
    data = data
        .map((graph) => graph.sublist(0, numberOfFeatures.floor()))
        .toList();

    return Container(
      color: darkMode ? secondaryColor : Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          ),
          Expanded(
            child: darkMode
                ? RadarChart.dark(
                    ticks: ticks,
                    features: features,
                    data: data,
                    reverseAxis: true,
                    useSides: useSides,
                  )
                : RadarChart.light(
                    ticks: ticks,
                    features: features,
                    data: data,
                    reverseAxis: true,
                    useSides: useSides,
                  ),
          ),
        ],
      ),
    );
  }
}

getData(List<int> data) {
  int count = 6;
  for (var i = 0; i < count; i++) {
    if (data[i] == null) {
      break;
    }
    data[i] = 100 - data[i];
  }
}
