import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/mobile/specific.dart';
import 'package:scouting_frontend/views/mobile/screens/input_view.dart';

class SideNavBar extends StatefulWidget {
  const SideNavBar({Key key}) : super(key: key);

  @override
  _SideNavBarState createState() => _SideNavBarState();
}

class _SideNavBarState extends State<SideNavBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF2A2D3E),
            ),
            child: Text(
              'Options',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: const Text(
              'Specific',
              style: TextStyle(
                fontSize: 25.0,
                letterSpacing: 1.0,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => specific()));
            },
          ),
          ListTile(
            leading: Icon(Icons.error_outline),
            title: const Text(
              'Pit',
              style: TextStyle(
                fontSize: 25.0,
                letterSpacing: 1.0,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Scaffold()));
            },
          ),
        ],
      ),
    );
  }
}
