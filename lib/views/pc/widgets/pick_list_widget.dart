import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:scouting_frontend/views/pc/pick_list_screen.dart';
import 'package:scouting_frontend/views/pc/team_info_screen.dart';

class PickList extends StatefulWidget {
  const PickList({Key key, @required this.uiList, this.screen, this.onReorder});

  final List<PickListTeam> uiList;
  final CurrentPickList screen;
  final Function(List<PickListTeam> list) onReorder;

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
                      MaterialPageRoute(
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

class PickListTeam {
  PickListTeam(this.id, this.number, this.name, this.firstListIndex,
      this.secondListIndex, bool available) {
    if (id <= 0) {
      throw ArgumentError('Invalid ID');
    } else if (number < 0) {
      throw ArgumentError('Invalid Team Number');
    } else if (name == '') {
      throw ArgumentError('Invalid Team Name');
    }
    this.controller.value = available;
  }
  final int id;
  final int number;
  final String name;
  int firstListIndex;
  int secondListIndex;
  AdvancedSwitchController controller = AdvancedSwitchController();

  @override
  String toString() {
    return '${this.name} ${this.number}';
  }
}
