import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/dashboard_linechart.dart";
import "package:scouting_frontend/views/constants.dart";
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
                alignment: const Alignment(-0.4, -1),
                child: RichText(
                  text: TextSpan(
                    children: <InlineSpan>[
                      if (isPC(context)) ...<TextSpan>[
                        const TextSpan(
                          text: " Full Defense ",
                          style: TextStyle(color: Colors.green),
                        ),
                        const TextSpan(
                          text: " Half Defense ",
                          style: TextStyle(color: Colors.blue),
                        ),
                        const TextSpan(
                          text: " Didnt Come ",
                          style: TextStyle(color: Colors.purple),
                        ),
                        const TextSpan(
                          text: " Didnt Work ",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                      const TextSpan(
                        text: " Top ",
                        style: TextStyle(color: Colors.green),
                      ),
                      const TextSpan(
                        text: " Mid ",
                        style: TextStyle(color: Colors.yellow),
                      ),
                      const TextSpan(
                        text: " Low ",
                        style: TextStyle(color: Colors.orange),
                      ),
                      const TextSpan(
                        text: " Delivered ",
                        style: TextStyle(color: Colors.blue),
                      ),
                      const TextSpan(
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
              bottom: 30.0,
              left: 20.0,
              right: 20.0,
              top: 30,
            ),
            child: DashboardLineChart(
              showShadow: false,
              gameNumbers: data.gameNumbers,
              inputedColors: const <Color>[
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.blue,
                Colors.red,
              ],
              distanceFromHighest: 4,
              dataSet: data.points,
              robotMatchStatuses: data.robotMatchStatuses,
              defenseAmounts: data.defenseAmounts,
            ),
          ),
        ],
      );
}
