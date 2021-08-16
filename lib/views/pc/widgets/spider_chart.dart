import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/spider_chart_lib.dart';

// ignore: must_be_immutable
class SpiderChart extends StatelessWidget {
  SpiderChart(
      {Key key,
      @required this.xAxisText,
      @required this.data,
      @required this.compareData})
      : super(key: key);

  final List<String> xAxisText;
  final List<double> data;
  final List<double> compareData;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Radar(
        dataSource: [
          RadarDataSourceConfig(data,
              fill: true, fillColor: Colors.green.withOpacity(0.8)),
          RadarDataSourceConfig(compareData,
              lineColor: Colors.blue,
              dotColor: Colors.blue,
              dotRadius: 2,
              fill: true,
              showDot: true,
              showLine: true,
              lineWidth: 0.5,
              fillColor: Colors.yellowAccent.withOpacity(0.3))
        ],
        coordinateStyle: CoordinateStyle(1.0,
            yAxisTexts: ["0.0", "1.0", "2.0", "3.0", "4.0", "5.0"],
            xAxisTexts: xAxisText,
            lineColor: primaryWhite,
            lineWidth: 1,
            gridSpace: 10,
            showYAxisText: false,
            xScaleCount: 4,
            yScaleCount: 6),
        size: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.width),
      ),
    );
  }
}
