import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:scouting_frontend/views/constants.dart";

class ManageLocalData extends StatefulWidget {
  @override
  State<ManageLocalData> createState() => _ManageLocalDataState();
}

class _ManageLocalDataState extends State<ManageLocalData> {
  late SharedPreferences prefs;

  @override
  Widget build(final BuildContext context) => SizedBox(
        width: 200,
        child: AlertDialog(
            content: FutureBuilder(
                future: getPrefs(),
                builder: (context, snapshot) => ListView(
                      children: prefs
                          .getKeys()
                          .map((e) => Card(
                              color: bgColor,
                              child: ListTile(
                                title: Text(e),
                              )))
                          .toList(),
                    ))),
      );

  Future<void> getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
}
