import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

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
              color: bgColor,
              key: ValueKey(item),
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                    0, defaultPadding / 4, 0, defaultPadding / 4),
                child: ListTile(
                  title: Text(item),
                  leading: AdvancedSwitch(
                    controller: AdvancedSwitchController(),
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
            ),
        ],
        onReorder: reorderData,
      ),
    );
  }
}
