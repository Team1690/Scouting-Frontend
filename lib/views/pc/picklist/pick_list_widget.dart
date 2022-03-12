import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/coach_team_info_data.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_screen.dart";
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
                              Spacer(),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Icon(
                                        e.faultMessage.fold(
                                          () => Icons.check,
                                          (final String _) => Icons.warning,
                                        ),
                                        color: e.faultMessage.fold(
                                          () => Colors.green,
                                          (final String _) =>
                                              Colors.yellow[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        e.faultMessage.orElse("No fault"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              if (e.amountOfMatches != 0) ...<Expanded>[
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "Ball avg: ${e.avgBallPoints.toStringAsFixed(1)}",
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "Climb avg: ${e.avgClimbPoints.toStringAsFixed(1)}",
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "Tele aim: ${e.teleAim.toStringAsFixed(1)}%",
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "Auto aim: ${e.autoAim.toStringAsFixed(1)}%",
                                  ),
                                ),
                              ] else
                                ...List<Spacer>.filled(
                                  4,
                                  Spacer(
                                    flex: 3,
                                  ),
                                ),
                              Expanded(
                                flex: 3,
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
                              Spacer()
                            ],
                          ),
                        )
                      ],
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
    required final int colorsIndex,
    required final int id,
    required final int number,
    required final String name,
    required final int firstListIndex,
    required final int secondListIndex,
    required final bool taken,
    required final double avgBallPoints,
    required final double avgClimbPoints,
    required final double autoAim,
    required final double teleAim,
    required final String? faultMessage,
    required final int amountOfMatches,
  }) : this.controller(
          firstListIndex,
          secondListIndex,
          taken,
          avgBallPoints,
          avgClimbPoints,
          autoAim,
          teleAim,
          LightTeam(
            validateId(id),
            validateNumber(number),
            validateName(name),
            colorsIndex,
          ),
          faultMessage,
          amountOfMatches,
        );

  PickListTeam.controller(
    this.firstListIndex,
    this.secondListIndex,
    this.taken,
    this.avgBallPoints,
    this.avgClimbPoints,
    this.autoAim,
    this.teleAim,
    this.team,
    this.faultMessage,
    this.amountOfMatches,
  );

  final int amountOfMatches;
  final double avgBallPoints;
  final double avgClimbPoints;
  final double autoAim;
  final double teleAim;
  final LightTeam team;
  final String? faultMessage;
  int firstListIndex;
  int secondListIndex;
  bool taken;

  @override
  String toString() {
    return "${team.name} ${team.number}";
  }
}
