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
                          "Scored",
                          data.avgAutoConesScored,
                          data.avgAutoCubesScored,
                        ),
                        gamepieceRow(
                          "Delivered",
                          data.avgAutoConesDelivered,
                          data.avgAutoCubesDelivered,
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
                          "Scored",
                          data.avgTeleConesScored,
                          data.avgTeleCubesScored,
                        ),
                        gamepieceRow(
                          "Delivered",
                          data.avgTeleConesDelivered,
                          data.avgTeleCubesDelivered,
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
                          "Cycles",
                          style: TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        Text(
                          "Cycle Time: ${(data.avgCycleTime / 1000).toStringAsFixed(1)}s",
                        ),
                        Text(
                          "Placement Time: ${(data.avgPlacementTime / 1000).toStringAsFixed(1)}s",
                        ),
                        Text(
                          "Feeder Time: ${(data.avgFeederTime / 1000).toStringAsFixed(1)}s",
                        ),
                        Text("Cycles: ${(data.avgCycles).toStringAsFixed(1)}"),
                        Text(
                          "Gamepieces: ${data.avgGamepieces.toStringAsFixed(1)}",
                        ),
                        const Spacer(
                          flex: 2,
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        const Text(
                          "Balance",
                          style: TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        Text(
                          "Auto Balance: ${data.avgAutoBalancePoints.toStringAsFixed(1)}/${data.matchesBalancedAuto}/${data.amoutOfMatches}",
                        ),
                        Text(
                          "Endgame Balance: ${data.avgEndgameBalancePoints.toStringAsFixed(1)}/${data.matchesBalancedEndgame}/${data.amoutOfMatches}",
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
                          "Auto: ${(data.avgAutoGamepieces / (data.avgAutoGamepieces + data.avgAutoConesFailed + data.avgAutoCubesFailed) * 100).toStringAsFixed(1)}%",
                        ),
                        Text(
                          "Teleop: ${(data.avgTeleGamepieces / (data.avgTeleGamepieces + data.avgTeleConesFailed + data.avgTeleCubesFailed) * 100).toStringAsFixed(1)}%",
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
