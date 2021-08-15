import 'package:flutter/material.dart';
import 'package:multi_charts/multi_charts.dart';
import 'package:scouting_frontend/views/constants.dart';

class SpiderChart extends StatelessWidget {
  const SpiderChart({
    Key key,
    @required this.values,
    @required this.labels,
    @required this.maxValue,
  }) : super(key: key);

  final List<double> values;
  final List<String> labels;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radar Chart Demo',
      theme: darkModeTheme,
      home: Container(
        width: 450,
        height: 450,
        //Radar Chart
        child: RadarChart(
          values: values,
          labels: labels,
          maxValue: maxValue,
          fillColor: Colors.blue,
          chartRadiusFactor: 0.7,
        ),
      ),
    );
  }
}
