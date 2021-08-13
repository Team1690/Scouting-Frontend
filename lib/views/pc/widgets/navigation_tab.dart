import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/pc/Settings.dart';
import 'package:scouting_frontend/views/pc/Stats.dart';
import 'package:scouting_frontend/views/pc/second_robot_List.dart';
import 'package:scouting_frontend/views/pc/team_info_screen.dart';
import 'package:scouting_frontend/views/pc/third_robot_list.dart';

class NavigationTab extends StatefulWidget {
  @override
  _NavigationTab createState() => _NavigationTab();
}

class _NavigationTab extends State<NavigationTab> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'menu',
            textScaleFactor: 2,
          ),
        ),
        ListTile(
          title: const Text('Team Info'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TeamInfoScreen()),
            );
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
              MaterialPageRoute(builder: (context) => SecondRobotList()),
            );
          },
        ),
        ListTile(
          title: const Text('third robot list'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ThirdRobotList()),
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
    ));
  }
}
