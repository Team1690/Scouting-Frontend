import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/coach_team_info_data.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_screen.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_screen.dart";
import "package:flutter_switch/flutter_switch.dart";

class PickList extends StatelessWidget {
  PickList({
    required this.uiList,
    required this.screen,
    required this.onReorder,
  }) {
    uiList.sort((final PickListTeam a, final PickListTeam b) {
      return screen.getIndex(a).compareTo(screen.getIndex(b));
    });
  }

  final List<PickListTeam> uiList;
  final CurrentPickList screen;
  final void Function(List<PickListTeam> list) onReorder;

  void reorderData(final int oldindex, int newindex) {
    if (newindex > oldindex) {
      newindex -= 1;
    }
    final PickListTeam item = uiList.removeAt(oldindex);
    uiList.insert(newindex, item);
    for (int i = 0; i < uiList.length; i++) {
      screen.setIndex(uiList[i], i);
    }
    onReorder(uiList);
  }

  @override
  Widget build(final BuildContext context) {
    return Container(
      child: ReorderableListView(
        buildDefaultDragHandles: true,
        primary: false,
        children: uiList.map<Widget>((final PickListTeam pickListTeam) {
          return Card(
            color: bgColor,
            key: ValueKey<String>(pickListTeam.toString()),
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
                                    Spacer(),
                                    Expanded(
                                      child: Icon(
                                        pickListTeam.faultMessages.fold(
                                          () => Icons.check,
                                          (final List<String> _) =>
                                              Icons.warning,
                                        ),
                                        color: pickListTeam.faultMessages.fold(
                                          () => Colors.green,
                                          (final List<String> _) =>
                                              Colors.yellow[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        pickListTeam.faultMessages.mapNullable(
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
                              if (pickListTeam.amountOfMatches !=
                                  0) ...<Expanded>[
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Gamepiece points avg: ${pickListTeam.avgGamepiecePoints.toStringAsFixed(1)}",
                                  ),
                                ),
                              ] else
                                ...List<Spacer>.filled(
                                  4,
                                  Spacer(
                                    flex: 2,
                                  ),
                                ),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute<TeamInfoScreen>(
                                      builder: (final BuildContext context) =>
                                          TeamInfoScreen(
                                        initalTeam: pickListTeam.team,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "Team info",
                                  ),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                        ListTile(
                          title: Row(
                            children: <Widget>[
                              Spacer(),
                              Expanded(
                                child: Text(
                                  "Best Balance: ${pickListTeam.maxBalanceTitle}",
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Didn't work on field: ${pickListTeam.robotMatchStatusToAmount[RobotMatchStatus.didntWorkOnField]}",
                                  style: TextStyle(
                                    color: Colors.purple,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Didn't come to field: ${pickListTeam.robotMatchStatusToAmount[RobotMatchStatus.didntComeToField]}",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              Spacer()
                            ],
                          ),
                        )
                      ],
                      title: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              pickListTeam.toString(),
                            ),
                          ),
                          if (pickListTeam.amountOfMatches != 0) ...<Widget>[
                            Spacer(),
                            Expanded(
                              child:
                                  Text(pickListTeam.drivetrain ?? "No pit :("),
                            ),
                            Expanded(
                              child: Text(
                                "Worked: ${pickListTeam.robotMatchStatusToAmount[RobotMatchStatus.worked]}",
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Gamepiece avg: ${pickListTeam.avgGamepieces.toStringAsFixed(1)}",
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Auto Gamepieces: ${pickListTeam.autoGamepieceAvg.toStringAsFixed(1)}",
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Balance points: ${pickListTeam.avgAutoBalancePoints.toStringAsFixed(1)}/${pickListTeam.matchesBalanced}/${pickListTeam.amountOfMatches}",
                              ),
                            ),
                          ]
                        ]
                            .expand(
                              (final Widget element) => <Widget>[
                                SizedBox(
                                  width: 2,
                                ),
                                element,
                              ],
                            )
                            .toList(),
                      ),
                      trailing: SizedBox(),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (screen.getIndex(pickListTeam) + 1 <= 24)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                (screen.getIndex(pickListTeam) + 1).toString(),
                              ),
                            ),
                          FlutterSwitch(
                            value: pickListTeam.taken,
                            activeColor: Colors.red,
                            inactiveColor: primaryColor,
                            height: 25,
                            width: 100,
                            onToggle: (final bool val) {
                              pickListTeam.taken = val;
                              onReorder(uiList);
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
                                CoachTeamData(pickListTeam.team),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                pickListTeam.toString(),
                              ),
                            ),
                          ],
                        ),
                        trailing: SizedBox(),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (screen.getIndex(pickListTeam) + 1 <= 24)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  (screen.getIndex(pickListTeam) + 1)
                                      .toString(),
                                ),
                              ),
                            FlutterSwitch(
                              value: pickListTeam.taken,
                              activeColor: Colors.red,
                              inactiveColor: primaryColor,
                              height: 25,
                              width: 100,
                              onToggle: (final bool val) {
                                pickListTeam.taken = val;
                                onReorder(uiList);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        }).toList(),
        onReorder: reorderData,
      ),
    );
  }
}

int validateId(final int id) =>
    id <= 0 ? throw ArgumentError("Invalid Id") : id;
int validateNumber(final int number) =>
    number < 0 ? throw ArgumentError("Invalid Team Number") : number;
String validateName(final String name) =>
    name == "" ? throw ArgumentError("Invalid Team Name") : name;

class PickListTeam {
  PickListTeam({
    required this.firstListIndex,
    required this.secondListIndex,
    required this.taken,
    required this.avgGamepiecePoints,
    required this.avgAutoBalancePoints,
    required this.team,
    required this.faultMessages,
    required this.amountOfMatches,
    required this.robotMatchStatusToAmount,
    required this.autoGamepieceAvg,
    required this.avgGamepieces,
    required this.matchesBalanced,
    required this.maxBalanceTitle,
    required this.drivetrain,
  });
  final String? drivetrain;
  final String maxBalanceTitle;
  final int amountOfMatches;
  final double avgGamepiecePoints;
  final double avgAutoBalancePoints;
  final double autoGamepieceAvg;
  final double avgGamepieces;

  final LightTeam team;
  final List<String>? faultMessages;
  final Map<RobotMatchStatus, int> robotMatchStatusToAmount;
  final int matchesBalanced;

  int firstListIndex;
  int secondListIndex;
  bool taken;

  @override
  String toString() {
    return "${team.name} ${team.number}";
  }
}
