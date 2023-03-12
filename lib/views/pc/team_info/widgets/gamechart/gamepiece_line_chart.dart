import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/dashboard_linechart.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class GamepiecesLineChart extends StatelessWidget {
  const GamepiecesLineChart(this.data);
  final LineChartData data;
  @override
  Widget build(final BuildContext context) => Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              const Spacer(),
              Align(
                alignment: const Alignment(0.7, -1),
                child: RichText(
                  text: const TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: " Scored ",
                        style: TextStyle(color: Colors.green),
                      ),
                      TextSpan(
                        text: " Delivered ",
                        style: TextStyle(color: Colors.blue),
                      ),
                      TextSpan(
                        text: " Failed ",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
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
            child: DashboardLineChart(
              showShadow: true,
              gameNumbers: data.gameNumbers,
              inputedColors: const <Color>[
                Colors.green,
                Colors.blue,
                Colors.red,
              ],
              distanceFromHighest: 4,
              dataSet: data.points,
              robotMatchStatuses: data.robotMatchStatuses,
            ),
          ),
        ],
      );
}
