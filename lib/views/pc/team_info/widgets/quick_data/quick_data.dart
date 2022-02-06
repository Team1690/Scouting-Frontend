import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class QuickDataCard extends StatelessWidget {
  const QuickDataCard(this.data);
  final QuickData data;
  @override
  Widget build(final BuildContext context) => DashboardCard(
        title: "Quick data",
        body: data.scorePercentTele.isNaN
            ? Container()
            : Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Auto",
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "Upper: ${data.avgAutoUpperScored.toStringAsFixed(1)}",
                          style: TextStyle(color: Colors.green),
                        ),
                        Text(
                          "Lower: ${data.avgAutoLowScored.toStringAsFixed(1)}",
                          style: TextStyle(color: Colors.yellow),
                        ),
                        Text(
                          "Missed: ${data.avgAutoMissed.toStringAsFixed(1)}",
                          style: TextStyle(color: Colors.red),
                        ),
                        Spacer()
                      ],
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Teleop",
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "Upper: ${data.avgTeleUpperScored.toStringAsFixed(1)}",
                          style: TextStyle(color: Colors.green),
                        ),
                        Text(
                          "Lower: ${data.avgTeleLowScored.toStringAsFixed(1)}",
                          style: TextStyle(color: Colors.yellow),
                        ),
                        Text(
                          "Missed: ${data.avgTeleMissed.toStringAsFixed(1)}",
                          style: TextStyle(color: Colors.red),
                        ),
                        Spacer()
                      ],
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Points",
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text("Balls: ${data.avgBallPoints.toStringAsFixed(1)}"),
                        Text(
                          "Climb: ${data.avgClimbPoints.toStringAsFixed(1)}",
                        ),
                        Spacer(
                          flex: 2,
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Aim",
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "Auto: ${!data.scorePercentAuto.isNaN ? "${data.scorePercentAuto.toStringAsFixed(1)}%" : "No data"} ",
                        ),
                        Text(
                          "Teleop: ${!data.scorePercentTele.isNaN ? "${data.scorePercentTele.toStringAsFixed(1)}%" : "No data"} ",
                        ),
                        Spacer(
                          flex: 2,
                        )
                      ],
                    ),
                  ),
                  Spacer()
                ],
              ),
      );
}
