import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/get_teams_api.dart';
import 'package:scouting_frontend/views/pc/scatters_screen.dart';
import 'package:scouting_frontend/views/pc/pick_list_screen.dart';
import 'package:scouting_frontend/views/pc/team_info_screen.dart';
import 'package:scouting_frontend/views/pc/compare_screen.dart';

import '../../constants.dart';

class NavigationTab extends StatefulWidget {
  NavigationTab({apiData});

  List<Team> apiData;

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
            // decoration: BoxDecoration(
            //   color: Colors.blue,
            // ),
            child: Image.asset(
              "lib/assets/logo.png",
            ),
            padding: EdgeInsets.symmetric(vertical: defaultPadding * 2),
          ),
          ListTile(
            title: const Text('Team Info'),
            leading: Icon(Icons.info_outline),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TeamInfoScreen(data: widget.apiData)),
              );
            },
          ),
          ListTile(
            title: const Text('Pick List'),
            leading: Icon(Icons.list),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PickListScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Compare'),
            leading: Icon(Icons.compare_arrows_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CompareScreen(
                          teams: widget.apiData,
                        )),
              );
            },
          ),
          ListTile(
            title: const Text('General Scatter'),
            leading: Icon(Icons.bar_chart_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ScattersScreen(
                          teams: widget.apiData,
                        )),
              );
            },
          ),
        ],
      ),
    );
  }
}
