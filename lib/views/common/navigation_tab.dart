import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/scatter/scatters_screen.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_screen.dart";
import "package:scouting_frontend/views/pc/status/status_screen.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_screen.dart";
import "package:scouting_frontend/views/pc/compare/compare_screen.dart";
import "package:scouting_frontend/views/pc/team_view/screen.dart";

class NavigationTab extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
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
            title: const Text("Team Info"),
            leading: Icon(Icons.info_outline),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<TeamInfoScreen>(
                  builder: (final BuildContext context) => TeamInfoScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("Pick List"),
            leading: Icon(Icons.list),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<PickListScreen>(
                  builder: (final BuildContext context) => PickListScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("Compare"),
            leading: Icon(Icons.compare_arrows_rounded),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<CompareScreen<int>>(
                  builder: (final BuildContext context) =>
                      CompareScreen<double>(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("General Scatter"),
            leading: Icon(Icons.bar_chart_rounded),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<ScattersScreen>(
                  builder: (final BuildContext context) => ScattersScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("Status"),
            leading: Icon(Icons.mobile_friendly),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<ScattersScreen>(
                  builder: (final BuildContext context) => StatusScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("Team view"),
            leading: Icon(Icons.addchart_sharp),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<TeamView>(
                  builder: (final BuildContext context) => TeamView(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
