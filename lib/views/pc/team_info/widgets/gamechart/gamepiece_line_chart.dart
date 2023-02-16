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
              Spacer(),
              Align(
                alignment: Alignment(0.7, -1),
                child: RichText(
                  text: TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: " Top ",
                        style: TextStyle(color: Colors.green),
                      ),
                      TextSpan(
                        text: " Mid ",
                        style: TextStyle(color: Colors.yellow),
                      ),
                      TextSpan(
                        text: " Low ",
                        style: TextStyle(color: Colors.orange),
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
            child: DashboardLineChart(
              showShadow: false,
              gameNumbers: data.gameNumbers,
              inputedColors: <Color>[
                Colors.green,
                Colors.yellow,
                Colors.orange,
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