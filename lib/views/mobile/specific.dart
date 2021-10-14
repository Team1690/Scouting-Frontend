import 'dart:ffi';
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
        padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 30.0),
        child: Column(
        children: <Widget> [
          MatchTextBox(onChange: onChange, controller: controller),
          Padding(padding: EdgeInsets.all(23.0)),
          
          TeamsDropdown(onChange: onChange, typeAheadController: typeAheadController),
          Padding(padding: EdgeInsets.all(11.0)),
          
          Container(
            color: Colors.green,
          ),
          TextField(
            style: TextStyle(color: Colors.pink),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 10.0),
              ),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 5.0),
              ),
            ),

          ),
          Padding(padding: EdgeInsets.all(23.0)),
          
          TeamsDropdown(onChange: onChange, typeAheadController: typeAheadController),
          Padding(padding: EdgeInsets.all(11.0)),
          
          TextField(),
          Padding(padding: EdgeInsets.all(23.0)),
          
          TeamsDropdown(onChange: onChange, typeAheadController: typeAheadController),
          TextField(),
        ],
        ),
 

      ),
      
         );
  }
}