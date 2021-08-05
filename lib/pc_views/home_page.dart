import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/pc_views/Lists.dart';
import 'package:scouting_frontend/pc_views/Settings.dart';
import 'package:scouting_frontend/pc_views/Stats.dart';
import 'package:scouting_frontend/pc_views/Lists.dart';
import 'package:scouting_frontend/pc_views/Settings.dart';

class PcHomeView extends StatefulWidget {
  @override
  PcHomeViewState createState() => PcHomeViewState();
}

class PcHomeViewState extends State<PcHomeView> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Orbit Scouting')),
        body: const Center(
          child: Text('Home Page!'),
        ),
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
              title: const Text('Lists'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListsView()),
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
