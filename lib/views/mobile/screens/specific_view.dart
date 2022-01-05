import 'package:flutter/material.dart';

import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/mobile/specific_vars.dart';
import 'package:scouting_frontend/views/mobile/team_selection_future.dart';
import 'package:scouting_frontend/views/mobile/submit_button.dart';

class Specific extends StatefulWidget {
  @override
  State<Specific> createState() => _SpecificState();
}

class _SpecificState extends State<Specific> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController teamSelectionController = TextEditingController();
  final SpecificVars vars = SpecificVars();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Specific'),
      ),
      body: Padding(
        padding: EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(15)),
              TeamSelectionFuture(
                onChange: (team) {
                  vars.teamId = team.id;
                },
                controller: teamSelectionController,
              ),
              Padding(padding: EdgeInsets.all(14.0)),
              TextField(
                textDirection: TextDirection.rtl,
                controller: messageController,
                onChanged: (text) {
                  vars.message = text;
                },
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 4.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 4.0),
                  ),
                  fillColor: secondaryColor,
                  filled: true,
                ),
                maxLines: 18,
              ),
              Padding(padding: EdgeInsets.all(11.0)),
              Align(
                alignment: Alignment.bottomCenter,
                child: SubmitButton(
                  resetForm: () {
                    setState(() {
                      vars.reset();
                      teamSelectionController.clear();
                      messageController.clear();
                    });
                  },
                  mutation:
                      """mutation MyMutation (\$team_id: Int, \$message: String){
  insert_specific(objects: {team_id: \$team_id, message: \$message}) {
    returning {
      team_id
      message
    }
  }
}
                  """,
                  vars: vars,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
