import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/dashboard_linechart.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class BallLineChart<E extends num> extends StatelessWidget {
  const BallLineChart(this.data);
  final LineChartData<E> data;
  @override
  Widget build(final BuildContext context) => Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(0.7, -1),
            child: RichText(
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: " Upper ",
                    style: TextStyle(color: Colors.green),
                  ),
                  TextSpan(
                    text: " Lower ",
                    style: TextStyle(color: Colors.yellow),
                  ),
                  TextSpan(
                    text: " Missed ",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment(-1, -1),
            child: Text(
              data.title,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              top: 40,
            ),
            child: DashboardLineChart<E>(
              gameNumbers: data.gameNumbers,
              inputedColors: <Color>[
                Colors.green,
                Colors.red,
                Colors.yellow[700]!
              ],
              distanceFromHighest: 4,
              dataSet: data.points,
            ),
          ),
        ],
      );
}
