import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/auto_picklist/auto_picklist_screen.dart";
import "package:scouting_frontend/views/mobile/screens/pit_view/balance_check.dart";
import "package:scouting_frontend/views/pc/matches/matches_screen.dart";
import "package:scouting_frontend/views/pc/scatter/scatters_screen.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_screen.dart";
import "package:scouting_frontend/views/pc/status/status_screen.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_screen.dart";
import "package:scouting_frontend/views/pc/compare/compare_screen.dart";
import "package:scouting_frontend/views/pc/team_list/screen.dart";

class NavigationTab extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => Drawer(
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
              padding: const EdgeInsets.symmetric(vertical: defaultPadding * 2),
            ),
            ListTile(
              title: const Text("Team Info"),
              leading: const Icon(Icons.info_outline),
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
              leading: const Icon(Icons.list),
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
              title: const Text("Auto Pick List"),
              leading: const Icon(Icons.calculate_outlined),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<AutoPickListScreen>(
                    builder: (final BuildContext context) =>
                        const AutoPickListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Compare"),
              leading: const Icon(Icons.compare_arrows_rounded),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<CompareScreen>(
                    builder: (final BuildContext context) => CompareScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("General Scatter"),
              leading: const Icon(Icons.bar_chart_rounded),
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
              leading: const Icon(Icons.mobile_friendly),
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
              title: const Text("Team list"),
              leading: const Icon(Icons.list_alt),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<TeamList>(
                    builder: (final BuildContext context) => const TeamList(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Matches"),
              leading: const Icon(Icons.add_circle_outline),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<CompareScreen>(
                    builder: (final BuildContext context) =>
                        const MatchesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Triple Balance"),
              leading: const Icon(Icons.balance),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<CompareScreen>(
                    builder: (final BuildContext context) =>
                        const BalanceCheck(),
                  ),
                );
              },
            ),
          ],
        ),
      );
}
