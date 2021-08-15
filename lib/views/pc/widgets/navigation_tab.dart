import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/pc/scatters_screen.dart';
import 'package:scouting_frontend/views/pc/pick_list_screen.dart';
import 'package:scouting_frontend/views/pc/team_info_screen.dart';
import 'package:scouting_frontend/views/pc/compare_screen.dart';

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
            title: const Text('Pick List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PickListScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Compare'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CompareScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('General Scatter'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScattersScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
