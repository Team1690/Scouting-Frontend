import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/coach_team_info_data.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_widget.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_screen.dart";
import "package:flutter_switch/flutter_switch.dart";

class AutoPickList extends StatefulWidget {
  AutoPickList({
    required this.uiList,
  }) {
    uiList.sort(
      (final AutoPickListTeam a, final AutoPickListTeam b) =>
          (a.balancePointsValue + a.gamepiecePointsValue + a.gamepieceSumValue)
              .compareTo(
        b.balancePointsValue + b.gamepiecePointsValue + b.gamepieceSumValue,
      ),
    );
  }

  @override
  State<AutoPickList> createState() => _AutoPickListState();
  final List<AutoPickListTeam> uiList;
}

class _AutoPickListState extends State<AutoPickList> {
  @override
  Widget build(final BuildContext context) => Container(
        child: ListView(
          primary: false,
          children: widget.uiList
              .map<Widget>(
                (final AutoPickListTeam autoPickListTeam) => Card(
                  color: bgColor,
                  key: ValueKey<String>(autoPickListTeam.toString()),
                  elevation: 2,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      defaultPadding / 4,
                      0,
                      defaultPadding / 4,
                    ),
                    child: isPC(context)
                        ? ExpansionTile(
                            children: <Widget>[
                              ListTile(
                                title: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: <Widget>[
                                          const Spacer(),
                                          Expanded(
                                            child: Icon(
                                              autoPickListTeam
                                                  .picklistTeam.faultMessages
                                                  .fold(
                                                () => Icons.check,
                                                (final List<String> _) =>
                                                    Icons.warning,
                                              ),
                                              color: autoPickListTeam
                                                  .picklistTeam.faultMessages
                                                  .fold(
                                                () => Colors.green,
                                                (final List<String> _) =>
                                                    Colors.yellow[700],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              autoPickListTeam.picklistTeam
                                                      .faultMessages
                                                      .mapNullable(
                                                    (
                                                      final List<String> p0,
                                                    ) =>
                                                        "Faults: ${p0.length}",
                                                  ) ??
                                                  "No faults",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (autoPickListTeam
                                            .picklistTeam.amountOfMatches !=
                                        0) ...<Expanded>[
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Gamepiece points avg: ${autoPickListTeam.picklistTeam.avgGamepiecePoints.toStringAsFixed(1)}",
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Avg Gamepieces Delivered: ${autoPickListTeam.picklistTeam.avgDelivered.toStringAsFixed(1)}",
                                        ),
                                      ),
                                    ] else
                                      ...List<Spacer>.filled(
                                        4,
                                        const Spacer(
                                          flex: 2,
                                        ),
                                      ),
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute<TeamInfoScreen>(
                                            builder:
                                                (final BuildContext context) =>
                                                    TeamInfoScreen(
                                              initalTeam: autoPickListTeam
                                                  .picklistTeam.team,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "Team info",
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                              ListTile(
                                title: Row(
                                  children: <Widget>[
                                    const Spacer(),
                                    Expanded(
                                      child: Text(
                                        "Avg Balancing Robots: ${autoPickListTeam.picklistTeam.avgBalancePartners.toStringAsFixed(1)}",
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Best Balance: ${autoPickListTeam.picklistTeam.maxBalanceTitle}",
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Didn't work on field: ${autoPickListTeam.picklistTeam.robotMatchStatusToAmount[RobotMatchStatus.didntWorkOnField]}",
                                        style: const TextStyle(
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Didn't come to field: ${autoPickListTeam.picklistTeam.robotMatchStatusToAmount[RobotMatchStatus.didntComeToField]}",
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    const Spacer()
                                  ],
                                ),
                              )
                            ],
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    autoPickListTeam.toString(),
                                  ),
                                ),
                                if (autoPickListTeam
                                        .picklistTeam.amountOfMatches !=
                                    0) ...<Widget>[
                                  const Spacer(),
                                  Expanded(
                                    child: Text(
                                      autoPickListTeam
                                              .picklistTeam.drivetrain ??
                                          "No pit :(",
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Worked: ${autoPickListTeam.picklistTeam.robotMatchStatusToAmount[RobotMatchStatus.worked]}",
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Avg Scored Gamepieces : ${autoPickListTeam.picklistTeam.avgGamepieces.toStringAsFixed(1)}",
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Auto Gamepieces: ${autoPickListTeam.picklistTeam.autoGamepieceAvg.toStringAsFixed(1)}",
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Auto Balance: ${autoPickListTeam.picklistTeam.avgAutoBalancePoints.toStringAsFixed(1)}/${autoPickListTeam.picklistTeam.matchesBalanced}/${autoPickListTeam.picklistTeam.amountOfMatches}",
                                    ),
                                  ),
                                ]
                              ]
                                  .expand(
                                    (final Widget element) => <Widget>[
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      element,
                                    ],
                                  )
                                  .toList(),
                            ),
                            trailing: const SizedBox(),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(
                                  width: 10,
                                ),
                                FlutterSwitch(
                                  value: autoPickListTeam.picklistTeam.taken,
                                  activeColor: Colors.red,
                                  inactiveColor: primaryColor,
                                  height: 25,
                                  width: 100,
                                  onToggle: (final bool val) {
                                    autoPickListTeam.picklistTeam.taken = val;
                                  },
                                ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onDoubleTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<CoachTeamData>(
                                  builder: (final BuildContext context) =>
                                      CoachTeamData(
                                    autoPickListTeam.picklistTeam.team,
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      autoPickListTeam.toString(),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const SizedBox(),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FlutterSwitch(
                                    value: autoPickListTeam.picklistTeam.taken,
                                    activeColor: Colors.red,
                                    inactiveColor: primaryColor,
                                    height: 25,
                                    width: 50,
                                    onToggle: (final bool val) {
                                      autoPickListTeam.picklistTeam.taken = val;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              )
              .toList(),
        ),
      );
}

int validateId(final int id) =>
    id <= 0 ? throw ArgumentError("Invalid Id") : id;
int validateNumber(final int number) =>
    number < 0 ? throw ArgumentError("Invalid Team Number") : number;
String validateName(final String name) =>
    name == "" ? throw ArgumentError("Invalid Team Name") : name;

class AutoPickListTeam {
  AutoPickListTeam({
    required this.gamepiecePointsValue,
    required this.gamepieceSumValue,
    required this.balancePointsValue,
    required this.picklistTeam,
  });

  final PickListTeam picklistTeam;
  final int gamepiecePointsValue;
  final int gamepieceSumValue;
  final int balancePointsValue;

  @override
  String toString() => "${picklistTeam.team.name} ${picklistTeam.team.number}";
}
