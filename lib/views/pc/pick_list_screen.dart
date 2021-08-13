import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/globals.dart' as globals;
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';

class PickListScreen extends StatefulWidget {
  @override
  _PickListScreenState createState() => _PickListScreenState();
}

class _PickListScreenState extends State<PickListScreen> {
  void reorderData(final int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final String item = globals.secondList.removeAt(oldindex);
      globals.secondList.insert(newindex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      body: ReorderableListView(
        children: <Widget>[
          for (final item in globals.secondList)
            Card(
              color: Colors.blueGrey,
              key: ValueKey(item),
              elevation: 2,
              child: ListTile(
                title: Text(item),
                leading: Icon(
                  Icons.adb,
                  color: Colors.black,
                ),
              ),
            ),
        ],
        onReorder: reorderData,
      ),
    );
  }
}
