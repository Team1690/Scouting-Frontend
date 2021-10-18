import 'dart:html';

import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/mobile/match_dropdown.dart';
import 'package:scouting_frontend/views/mobile/teams_dropdown.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';





void main() => runApp(MaterialApp(
  home: specific()
));

class specific extends StatelessWidget {
  get controller => null;

  get onChange => null;

  get typeAheadController => null;

  get body => null;

  get title => null;


  @override  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),

      body: Padding(
        padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 20.0),
        child: Column(
          
        children: <Widget> [
          MatchTextBox(onChange: onChange, controller: controller),
          Padding(padding: EdgeInsets.all(14.0)),
          
          TeamsDropdown(onChange: onChange, typeAheadController: typeAheadController),
          Padding(padding: EdgeInsets.all(9.0)),
          
          
          TextField(
            
            style: TextStyle(color: Colors.pink),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 5.0),
              ),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 3.0),
              ),
            ),
            maxLines: 4,

          ),
          Padding(padding: EdgeInsets.all(15.0)),
          
          TeamsDropdown(onChange: onChange, typeAheadController: typeAheadController),
          Padding(padding: EdgeInsets.all(11.0)),
          
          TextField(
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,

              ),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 5.0),
              ),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 3.0),
              ),
            ),
            maxLines: 4,
          ),
          Padding(padding: EdgeInsets.all(15.0)),
          
          
          
          
          
          
          TeamsDropdown(onChange: onChange, typeAheadController: typeAheadController),
          Padding(padding: EdgeInsets.all(11.0)),

          Expanded(
            child: TextField(
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              
              ),
            
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 5.0),
              ),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 3.0),
              ),
              fillColor: Colors.green,
              filled: true,
            ),
            
            maxLines: 4,
          ),
          ),
          
        ],
        ),

      ),
         );
  }
}