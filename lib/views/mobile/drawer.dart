import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/mobile/specific.dart';



class Drawer1 extends StatefulWidget {
  const Drawer1({ Key key }) : super(key: key);
  
  @override
  _Drawer1State createState() => _Drawer1State();
}

class _Drawer1State extends State<Drawer1> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children:  [
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
            leading: Icon(Icons.favorite),
            title: const Text(
              'Match',
              style: TextStyle(
                fontSize: 25.0,
                letterSpacing: 1.0,
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold()));
            },
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => specific()));
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold()));
          },
          ),
        ],
      ),
    );
  }
}