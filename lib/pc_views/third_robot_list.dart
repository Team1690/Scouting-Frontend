import 'package:flutter/material.dart';

class third_robot_list extends StatefulWidget {
  List<String> teams = ['1', '2', '3', '4', '5', '6'];
  @override
  _third_robot_listState createState() => _third_robot_listState();
}

class _third_robot_listState extends State<third_robot_list> {
  void reorderData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final items = widget.teams.removeAt(oldindex);
      widget.teams.insert(newindex, items);
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
          for (final items in widget.teams)
            Card(
              color: Colors.blueGrey,
              key: ValueKey(items),
              elevation: 2,
              child: ListTile(
                title: Text(items),
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
