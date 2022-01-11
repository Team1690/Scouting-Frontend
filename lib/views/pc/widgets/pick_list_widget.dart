import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:scouting_frontend/views/pc/pick_list_screen.dart';
import 'package:scouting_frontend/views/pc/team_info_screen.dart';

class PickList extends StatefulWidget {
  PickList(
      {required this.uiList, required this.screen, this.onReorder = ignore});

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
  Widget build(BuildContext context) {
    return Container(
      child: ReorderableListView(
        children: <Widget>[
          ...widget.uiList.map<Widget>((e) {
            e.controller.addListener(() {
              widget.onReorder(widget.uiList);
            });
            return Card(
              color: bgColor,
              key: ValueKey(e.toString()),
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                    0, defaultPadding / 4, 0, defaultPadding / 4),
                child: ListTile(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<TeamInfoScreen>(
                          builder: (context) => TeamInfoScreen(
                                chosenTeam: LightTeam(e.id, e.number, e.name),
                              ))),
                  title: Text(e.toString()),
                  leading: AdvancedSwitch(
                    controller: e.controller,
                    activeColor: Colors.red,
                    inactiveColor: primaryColor,
                    activeChild: Text('Taken'),
                    inactiveChild: Text('Available'),
                    height: 25,
                    width: 100,
                    enabled: true,
                  ),
                ),
              ),
            );
          })
        ],
        onReorder: reorderData,
      ),
    );
  }
}

int validateId(final int id) =>
    id <= 0 ? throw ArgumentError('Invalid Id') : id;
int validateNumber(final int number) =>
    number < 0 ? throw ArgumentError('Invalid Team Number') : number;
String validateName(final String name) =>
    name == "" ? throw ArgumentError("Invalid Team Name") : name;

class PickListTeam {
  PickListTeam(final int id, final int number, final String name,
      final int firstListIndex, final int secondListIndex, final bool available)
      : this.controller(
          validateId(id),
          validateNumber(number),
          validateName(name),
          firstListIndex,
          secondListIndex,
          ValueNotifier<bool>(available),
        );

  PickListTeam.controller(this.id, this.number, this.name, this.firstListIndex,
      this.secondListIndex, this.controller) {}

  final int id;
  final int number;
  final String name;
  int firstListIndex;
  int secondListIndex;
  final ValueNotifier<bool> controller;

  @override
  String toString() {
    return '${this.name} ${this.number}';
  }
}
