import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/pc_views/Settings.dart';
import 'package:scouting_frontend/pc_views/Stats.dart';
import 'package:scouting_frontend/pc_views/second_robot_List.dart';
import 'package:scouting_frontend/pc_views/Settings.dart';
import 'package:scouting_frontend/pc_views/third_robot_list.dart';

class PcHomeView extends StatefulWidget {
  @override
  PcHomeViewState createState() => PcHomeViewState();
}

class PcHomeViewState extends State<PcHomeView> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Orbit Scouting')),
        drawer: Drawer(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('menu'),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Stats'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatsView()),
                );
              },
            ),
            ListTile(
              title: const Text('second robot list'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Second_robot_list()),
                );
              },
            ),
            ListTile(
              title: const Text('third robot list'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => third_robot_list()),
                );
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsView()),
                );
              },
            ),
          ],
        )));
  }
}
