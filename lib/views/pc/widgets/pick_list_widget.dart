import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/globals.dart' as globals;
import 'package:toggle_switch/toggle_switch.dart';

class PickList extends StatefulWidget {
  const PickList({
    Key key,
    @required this.pickList,
  });

  final List<String> pickList;

  @override
  _PickListState createState() => _PickListState();
}

class _PickListState extends State<PickList> {
  void reorderData(final int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final String item = widget.pickList.removeAt(oldindex);
      widget.pickList.insert(newindex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ReorderableListView(
        children: <Widget>[
          for (final item in widget.pickList)
            Card(
              color: Colors.blueGrey,
              key: ValueKey(item),
              elevation: 2,
              child: ListTile(
                title: Text(item),
                leading: ToggleSwitch(totalSwitches: 2, labels: [
                  'available',
                  'taken'
                ], activeBgColors: [
                  [Colors.greenAccent],
                  [Colors.redAccent]
                ]),
              ),
            ),
        ],
        onReorder: reorderData,
      ),
    );
  }
}
