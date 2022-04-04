import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class QuickDataCard extends StatelessWidget {
  const QuickDataCard(this.data);
  final QuickData data;
  @override
  Widget build(final BuildContext context) => DashboardCard(
        title: "Quick data",
        body: data.amoutOfMatches == 0
            ? Container()
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    Column(
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
                    Column(
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
                    Column(
                      children: <Widget>[
                        Text(
                          "Points",
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text("Balls: ${data.avgBallPoints.toStringAsFixed(1)}"),
                        Text(
                          "Climb: ${data.avgClimbPoints.toStringAsFixed(1)}/${data.matchesClimbed}/${data.amoutOfMatches}",
                        ),
                        Spacer(
                          flex: 2,
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "Misc",
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "Ball sum: ${(data.avgAutoLowScored + data.avgAutoUpperScored + data.avgTeleLowScored + data.avgTeleUpperScored).toStringAsFixed(1)}",
                        ),
                        Text(
                          "Best climb: ${data.highestLevelTitle}",
                        ),
                        Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "Picklist",
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text("First: ${data.firstPicklistIndex + 1}"),
                        Text("Second: ${data.secondPicklistIndex + 1}"),
                        Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "Aim",
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "Auto: ${(data.avgAutoUpperScored + data.avgAutoLowScored).toStringAsFixed(1)}/${(data.avgAutoUpperScored + data.avgAutoLowScored + data.avgAutoMissed).toStringAsFixed(1)}",
                        ),
                        Text(
                          "Teleop: ${(data.avgTeleUpperScored + data.avgTeleLowScored).toStringAsFixed(1)}/${(data.avgTeleUpperScored + data.avgTeleLowScored + data.avgTeleMissed).toStringAsFixed(1)}",
                        ),
                        Spacer(
                          flex: 2,
                        )
                      ],
                    ),
                  ]
                      .expand(
                        (final Widget element) =>
                            <Widget>[element, SizedBox(width: 40)],
                      )
                      .toList(),
                ),
              ),
      );
}
