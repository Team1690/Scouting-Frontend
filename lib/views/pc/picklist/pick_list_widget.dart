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
        children: uiList.map<Widget>((final PickListTeam e) {
          return Card(
            color: bgColor,
            key: ValueKey<String>(e.toString()),
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
                                    Expanded(
                                      child: Icon(
                                        e.faultMessages.fold(
                                          () => Icons.check,
                                          (final List<String> _) =>
                                              Icons.warning,
                                        ),
                                        color: e.faultMessages.fold(
                                          () => Colors.green,
                                          (final List<String> _) =>
                                              Colors.yellow[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        e.faultMessages.mapNullable(
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
                              if (e.amountOfMatches != 0) ...<Expanded>[
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Ball point avg: ${e.avgBallPoints.toStringAsFixed(1)}",
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Tele aim: ${(e.teleUpper + e.teleLower).toStringAsFixed(1)}/${(e.teleUpper + e.teleLower + e.teleMissed).toStringAsFixed(1)}",
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Auto aim: ${(e.autoUpper + e.autoLower).toStringAsFixed(1)}/${(e.autoUpper + e.autoLower + e.autoMissed).toStringAsFixed(1)}",
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
                                        initalTeam: e.team,
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
                                child: Text("Best climb: ${e.maxClimbTitle}"),
                              ),
                              Expanded(
                                child: Text(
                                  "Didn't work on field: ${e.robotMatchStatusToAmount[RobotMatchStatus.didntWorkOnField]}",
                                  style: TextStyle(
                                    color: Colors.purple,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Didn't come to field: ${e.robotMatchStatusToAmount[RobotMatchStatus.didntComeToField]}",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Worked: ${e.robotMatchStatusToAmount[RobotMatchStatus.worked]}",
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
                              e.toString(),
                            ),
                          ),
                          if (e.amountOfMatches != 0) ...<Widget>[
                            Expanded(
                              child: Text(e.drivetrain ?? "No pit :("),
                            ),
                            Expanded(
                              child: Text(
                                "Worked: ${e.robotMatchStatusToAmount[RobotMatchStatus.worked]}",
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Ball avg: ${e.avgBalls.toStringAsFixed(1)}",
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Climb points: ${e.avgClimbPoints.toStringAsFixed(1)}/${e.matchesClimbed}/${e.amountOfMatches}",
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Auto balls: ${e.autoBallAvg.toStringAsFixed(1)}",
                              ),
                            ),
                          ]
                        ],
                      ),
                      trailing: SizedBox(),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (screen.getIndex(e) + 1 <= 24)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                (screen.getIndex(e) + 1).toString(),
                              ),
                            ),
                          FlutterSwitch(
                            value: e.taken,
                            activeColor: Colors.red,
                            inactiveColor: primaryColor,
                            height: 25,
                            width: 100,
                            onToggle: (final bool val) {
                              e.taken = val;
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
                                CoachTeamData(e.team),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                e.toString(),
                              ),
                            ),
                          ],
                        ),
                        trailing: SizedBox(),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (screen.getIndex(e) + 1 <= 24)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  (screen.getIndex(e) + 1).toString(),
                                ),
                              ),
                            FlutterSwitch(
                              value: e.taken,
                              activeColor: Colors.red,
                              inactiveColor: primaryColor,
                              height: 25,
                              width: 100,
                              onToggle: (final bool val) {
                                e.taken = val;
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
    required this.avgBallPoints,
    required this.avgClimbPoints,
    required this.autoLower,
    required this.teleUpper,
    required this.teleLower,
    required this.autoUpper,
    required this.team,
    required this.faultMessages,
    required this.amountOfMatches,
    required this.robotMatchStatusToAmount,
    required this.autoBallAvg,
    required this.avgBalls,
    required this.matchesClimbed,
    required this.autoMissed,
    required this.teleMissed,
    required this.maxClimbTitle,
    required this.drivetrain,
  });
  final String? drivetrain;
  final String maxClimbTitle;
  final int amountOfMatches;
  final double avgBallPoints;
  final double avgClimbPoints;
  final double autoBallAvg;
  final double avgBalls;
  final double autoUpper;
  final double autoLower;
  final double autoMissed;
  final double teleUpper;
  final double teleLower;
  final double teleMissed;

  final LightTeam team;
  final List<String>? faultMessages;
  final Map<RobotMatchStatus, int> robotMatchStatusToAmount;
  final int matchesClimbed;

  int firstListIndex;
  int secondListIndex;
  bool taken;

  @override
  String toString() {
    return "${team.name} ${team.number}";
  }
}
