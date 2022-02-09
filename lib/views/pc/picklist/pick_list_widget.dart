import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:flutter_advanced_switch/flutter_advanced_switch.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_screen.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_screen.dart";

class PickList extends StatefulWidget {
  PickList({
    required this.uiList,
    required this.screen,
    required this.onReorder,
  });

  final List<PickListTeam> uiList;
  final CurrentPickList screen;
  final void Function(List<PickListTeam> list) onReorder;

  @override
  _PickListState createState() => _PickListState();
}

class _PickListState extends State<PickList> {
  void reorderData(final int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final PickListTeam item = widget.uiList.removeAt(oldindex);
      widget.uiList.insert(newindex, item);
      for (int i = 0; i < widget.uiList.length; i++) {
        widget.screen.setIndex(widget.uiList[i], i);
      }
    });
    widget.onReorder(widget.uiList);
  }

  @override
  Widget build(final BuildContext context) {
    return Container(
      child: ReorderableListView(
        primary: false,
        children: widget.uiList.map<Widget>((final PickListTeam e) {
          e.controller.addListener(() {
            widget.onReorder(widget.uiList);
          });
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
              child: ListTile(
                title: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute<TeamInfoScreen>(
                            builder: (final BuildContext context) =>
                                TeamInfoScreen(
                              initalTeam: LightTeam(e.id, e.number, e.name),
                            ),
                          ),
                        ),
                        child: Text(
                          e.toString(),
                        ),
                      ),
                    ),
                    if (!e.autoAim.isNaN) ...<Widget>[
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Ball avg: ${e.avgBallPoints.toStringAsFixed(1)}",
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Climb avg: ${e.avgClimbPoints.toStringAsFixed(1)}",
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Tele aim: ${e.teleAim.toStringAsFixed(1)}%",
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Auto aim: ${e.autoAim.toStringAsFixed(1)}%",
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
                                initalTeam: LightTeam(e.id, e.number, e.name),
                              ),
                            ),
                          ),
                          child: Text(
                            "Team info",
                          ),
                        ),
                      ),
                      Spacer()
                    ] else ...<Widget>[
                      Text("No data"),
                      Spacer(
                        flex: 3,
                      ),
                    ]
                  ],
                ),
                leading: AdvancedSwitch(
                  controller: e.controller,
                  activeColor: Colors.red,
                  inactiveColor: primaryColor,
                  activeChild: Text("Taken"),
                  inactiveChild: Text("Available"),
                  height: 25,
                  width: 100,
                  enabled: true,
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
  }) : this.controller(
          validateId(id),
          validateNumber(number),
          validateName(name),
          firstListIndex,
          secondListIndex,
          ValueNotifier<bool>(taken),
          avgBallPoints,
          avgClimbPoints,
          autoAim,
          teleAim,
        );

  PickListTeam.controller(
    this.id,
    this.number,
    this.name,
    this.firstListIndex,
    this.secondListIndex,
    this.controller,
    this.avgBallPoints,
    this.avgClimbPoints,
    this.autoAim,
    this.teleAim,
  );

  final double avgBallPoints;
  final double avgClimbPoints;
  final double autoAim;
  final double teleAim;
  final int id;
  final int number;
  final String name;
  int firstListIndex;
  int secondListIndex;
  final ValueNotifier<bool> controller;

  @override
  String toString() {
    return "$name $number";
  }
}