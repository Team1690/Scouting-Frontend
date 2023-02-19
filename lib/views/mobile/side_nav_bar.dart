import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/screens/coach_team_info_data.dart";
import "package:scouting_frontend/views/mobile/screens/coach_view.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view.dart";
import "package:scouting_frontend/views/mobile/screens/input_view.dart";
import "package:scouting_frontend/views/mobile/screens/new_specific_view.dart";
import "package:scouting_frontend/views/mobile/screens/pit_view.dart";
import "package:scouting_frontend/views/pc/compare/compare_screen.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_screen.dart";

class SideNavBar extends StatelessWidget {
  SideNavBar();
  final TextEditingController teamSelectionController = TextEditingController();
  @override
  Widget build(final BuildContext context) => Drawer(
        child: ListView(
          primary: false,
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF2A2D3E),
              ),
              child: Text(
                "Options",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TeamSelectionFuture(
                teams: TeamProvider.of(context).teams,
                onChange: (final LightTeam team) {
                  teamSelectionController.clear();
                  Navigator.of(context).push(
                    MaterialPageRoute<CoachTeamData>(
                      builder: (final BuildContext contxt) =>
                          CoachTeamData(team),
                    ),
                  );
                },
                controller: teamSelectionController,
              ),
            ),
            const NavbarTile(
              icon: Icons.error_outline,
              title: "Match",
              widget: UserInput.new,
            ),
            const NavbarTile(
              icon: Icons.search,
              title: "Specific",
              widget: Specific2.new,
            ),
            const NavbarTile(
              icon: Icons.feed_outlined,
              title: "Coach",
              widget: CoachView.new,
            ),
            const NavbarTile(
              icon: Icons.build,
              title: "Pit",
              widget: PitView.new,
            ),
            const NavbarTile(
              icon: Icons.construction,
              title: "Faults",
              widget: FaultView.new,
            ),
            const NavbarTile(
              icon: Icons.list,
              title: "Picklist",
              widget: PickListScreen.new,
            ),
            const NavbarTile(
              icon: Icons.compare_arrows_rounded,
              title: "Compare",
              widget: CompareScreen.new,
            )
          ],
        ),
      );
}

class NavbarTile extends StatelessWidget {
  const NavbarTile({
    required this.icon,
    required this.title,
    required this.widget,
  });
  final String title;
  final IconData icon;
  final Widget Function() widget;
  @override
  Widget build(final BuildContext context) => ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 25.0,
            letterSpacing: 1.0,
          ),
        ),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<Widget>(
              builder: (final BuildContext context) => widget(),
            ),
          );
        },
      );
}
