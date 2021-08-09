import 'package:flutter/material.dart';

class SecondRobotList extends StatefulWidget {
  @override
  _SecondRobotListState createState() => _SecondRobotListState();
}

class _SecondRobotListState extends State<SecondRobotList> {
  List<String> teams = ['1', '2', '3', '4', '5', '6'];

  void reorderData(final int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final String item = teams.removeAt(oldindex);
      teams.insert(newindex, item);
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
          for (final item in teams)
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
