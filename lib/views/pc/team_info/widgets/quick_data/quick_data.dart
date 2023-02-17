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
                        const Text(
                          "Auto",
                          style: TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        gamepieceRow(
                          "Top",
                          data.avgAutoConesTop,
                          data.avgAutoCubesTop,
                        ),
                        gamepieceRow(
                          "Mid",
                          data.avgAutoConesMid,
                          data.avgAutoCubesMid,
                        ),
                        gamepieceRow(
                          "Low",
                          data.avgAutoConesLow,
                          data.avgAutoCubesLow,
                        ),
                        gamepieceRow(
                          "Failed",
                          data.avgAutoConesFailed,
                          data.avgAutoCubesFailed,
                        ),
                        const Spacer()
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        const Text(
                          "Teleop",
                          style: TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        gamepieceRow(
                          "Top",
                          data.avgTeleConesTop,
                          data.avgTeleCubesTop,
                        ),
                        gamepieceRow(
                          "Mid",
                          data.avgTeleConesMid,
                          data.avgTeleCubesMid,
                        ),
                        gamepieceRow(
                          "Low",
                          data.avgTeleConesLow,
                          data.avgTeleCubesLow,
                        ),
                        gamepieceRow(
                          "Failed",
                          data.avgTeleConesFailed,
                          data.avgTeleCubesFailed,
                        ),
                        const Spacer()
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        const Text(
                          "Points",
                          style: TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        Text(
                          "Gamepieces: ${data.avgGamepiecePoints.toStringAsFixed(1)}",
                        ),
                        Text(
                          "Auto Balance: ${data.avgAutoBalancePoints.toStringAsFixed(1)}/${data.matchesBalancedAuto}/${data.amoutOfMatches}",
                        ),
                        Text(
                          "Endgame Balance: ${data.avgEndgameBalancePoints.toStringAsFixed(1)}/${data.matchesBalancedEndgame}/${data.amoutOfMatches}",
                        ),
                        const Spacer(
                          flex: 2,
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        const Text(
                          "Misc",
                          style: TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        Text(
                          "Gamepiece sum: ${data.avgGamepieces.toStringAsFixed(1)}",
                        ),
                        Text(
                          "Best Auto Balance: ${data.highestBalanceTitleAuto}",
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        const Text(
                          "Picklist",
                          style: TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        Text("First: ${data.firstPicklistIndex + 1}"),
                        Text("Second: ${data.secondPicklistIndex + 1}"),
                        const Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        const Text(
                          "Aim",
                          style: TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        Text(
                          "Auto: ${data.avgAutoGamepieces.toStringAsFixed(1)}/${(data.avgAutoGamepieces + data.avgAutoConesFailed + data.avgAutoCubesFailed).toStringAsFixed(1)}",
                        ),
                        Text(
                          "Teleop: ${data.avgTeleGamepieces.toStringAsFixed(1)}/${(data.avgTeleGamepieces + data.avgTeleConesFailed + data.avgTeleCubesFailed).toStringAsFixed(1)}",
                        ),
                        const Spacer(
                          flex: 2,
                        )
                      ],
                    ),
                  ]
                      .expand(
                        (final Widget element) =>
                            <Widget>[element, const SizedBox(width: 40)],
                      )
                      .toList(),
                ),
              ),
      );
}

Widget gamepieceRow(
  final String title,
  final double cones,
  final double cubes,
) =>
    Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text("$title: "),
        Text(
          style: const TextStyle(color: Colors.amber),
          cones.toStringAsFixed(1),
        ),
        const Text("/"),
        Text(
          style: const TextStyle(color: Colors.deepPurple),
          cubes.toStringAsFixed(1),
        ),
      ],
    );
