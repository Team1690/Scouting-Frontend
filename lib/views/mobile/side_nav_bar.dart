import "package:flutter/material.dart";
import "package:scouting_frontend/views/mobile/screens/coach_view.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view.dart";
import "package:scouting_frontend/views/mobile/screens/input_view.dart";
import "package:scouting_frontend/views/mobile/screens/pit_view.dart";
import "package:scouting_frontend/views/mobile/screens/specific_view.dart";

class SideNavBar extends StatelessWidget {
  const SideNavBar();

  @override
  Widget build(final BuildContext context) {
    return Drawer(
      child: ListView(
        primary: false,
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
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
          ListTile(
            leading: Icon(Icons.error_outline),
            title: const Text(
              "Match",
              style: TextStyle(
                fontSize: 25.0,
                letterSpacing: 1.0,
              ),
            ),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute<Specific>(
                builder: (final BuildContext context) => UserInput(),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: const Text(
              "Specific",
              style: TextStyle(
                fontSize: 25.0,
                letterSpacing: 1.0,
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<Specific>(
                  builder: (final BuildContext context) => Specific(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.build),
            title: const Text(
              "Pit",
              style: TextStyle(
                fontSize: 25.0,
                letterSpacing: 1.0,
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<PitView>(
                  builder: (final BuildContext context) => PitView(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.feed_outlined),
            title: const Text(
              "Coach",
              style: TextStyle(
                fontSize: 25.0,
                letterSpacing: 1.0,
              ),
            ),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute<Specific>(
                builder: (final BuildContext context) => CoachView(),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.construction),
            title: const Text(
              "Faults",
              style: TextStyle(
                fontSize: 25.0,
                letterSpacing: 1.0,
              ),
            ),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute<Specific>(
                builder: (final BuildContext context) => FaultView(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
