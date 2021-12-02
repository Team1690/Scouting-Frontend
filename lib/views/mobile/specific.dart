import 'dart:html';
import 'package:flutter/material.dart';

import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:scouting_frontend/views/mobile/match_dropdown.dart';
import 'package:scouting_frontend/views/mobile/submit_button.dart';
import 'package:scouting_frontend/views/mobile/teams_dropdown.dart';

class Specific extends StatelessWidget {
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
        padding: EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              MatchTextBox(onChange: onChange, controller: controller),
              Padding(padding: EdgeInsets.all(14.0)),
              TeamsDropdown(
                  onChange: onChange, typeAheadController: typeAheadController),
              Padding(padding: EdgeInsets.all(9.0)),
              TextField(
                style: TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 4.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 3.0),
                  ),
                  fillColor: Colors.grey,
                  filled: true,
                ),
                maxLines: 4,
              ),
              Padding(padding: EdgeInsets.all(15.0)),
              TeamsDropdown(
                  onChange: onChange, typeAheadController: typeAheadController),
              Padding(padding: EdgeInsets.all(11.0)),
              TextField(
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 4.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 3.0),
                  ),
                  fillColor: Colors.grey,
                  filled: true,
                ),
                maxLines: 4,
              ),
              Padding(padding: EdgeInsets.all(15.0)),
              TeamsDropdown(
                  onChange: onChange, typeAheadController: typeAheadController),
              Padding(padding: EdgeInsets.all(11.0)),
              TextField(
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 4.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 3.0),
                  ),
                  fillColor: Colors.grey,
                  filled: true,
                ),
                maxLines: 4,
              ),
              Padding(padding: EdgeInsets.all(11.0)),
              Align(
                alignment: Alignment.bottomCenter,
                child: SubmitButton(
                  //uploadData: (),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
