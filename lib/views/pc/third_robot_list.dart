import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/globals.dart' as globals;

class ThirdRobotList extends StatefulWidget {
  @override
  _ThirdRobotListState createState() => _ThirdRobotListState();
}

class _ThirdRobotListState extends State<ThirdRobotList> {
  void reorderData(final int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final String item = globals.thirdList.removeAt(oldindex);
      globals.thirdList.insert(newindex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "third robot list",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ReorderableListView(
        children: <Widget>[
          for (final item in globals.thirdList)
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
