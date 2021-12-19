import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/mobile/SpecificVars.dart';
import 'package:scouting_frontend/views/mobile/TeamSelection.dart';
import 'package:scouting_frontend/views/mobile/match_dropdown.dart';
import 'package:scouting_frontend/views/mobile/submit_button.dart';
import 'package:scouting_frontend/views/mobile/teams_dropdown.dart';
import 'package:scouting_frontend/models/match_model.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';

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
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(15)),
              TeamSelection(
                onChange: (team) {
                  vars.teamId = team.id;
                },
                controller: teamSelectionController,
              ),
              Padding(padding: EdgeInsets.all(14.0)),
              TextField(
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
                    borderSide: BorderSide(color: Colors.grey, width: 14.0),
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
                  vars: vars.toHasuraVars(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
