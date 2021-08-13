import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/globals.dart' as globals;

class SecondRobotList extends StatefulWidget {
  @override
  _SecondRobotListState createState() => _SecondRobotListState();
}

class _SecondRobotListState extends State<SecondRobotList> {
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
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "second robot list",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
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
