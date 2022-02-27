import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";

import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/specific_vars.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/submit_button.dart";
import "package:scouting_frontend/views/mobile/switcher.dart";

class Specific extends StatefulWidget {
  @override
  State<Specific> createState() => _SpecificState();
}

class _SpecificState extends State<Specific> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController teamSelectionController = TextEditingController();
  final SpecificVars vars = SpecificVars();
  final FocusNode node = FocusNode();
  Map<int, int> indexToId() => <int, int>{
        0: IdProvider.of(context).robotRole.nameToId["Upper"]!,
        1: IdProvider.of(context).robotRole.nameToId["Lower"]!,
        2: IdProvider.of(context).robotRole.nameToId["Defender"]!,
      };
  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: node.unfocus,
      child: Scaffold(
        drawer: SideNavBar(),
        appBar: AppBar(
          centerTitle: true,
          title: Text("Specific"),
        ),
        body: Padding(
          padding: EdgeInsets.all(14),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(14)),
                  TeamSelectionFuture(
                    onChange: (final LightTeam team) {
                      vars.teamId = team.id;
                    },
                    controller: teamSelectionController,
                  ),
                  SizedBox(height: 14.0),
                  TextField(
                    focusNode: node,
                    textDirection: TextDirection.rtl,
                    controller: messageController,
                    onChanged: (final String text) {
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
                  SizedBox(height: 14),
                  Switcher(
                    labels: <String>[
                      "Upper",
                      "Lower",
                      "Defender",
                    ],
                    colors: <Color>[
                      Colors.green,
                      Colors.yellow,
                      Colors.deepPurple,
                    ],
                    onChange: (final int index) {
                      setState(() {
                        vars.roleId = indexToId()[index];
                      });
                    },
                    selected: <int, int>{
                          for (MapEntry<int, int> entry in indexToId().entries)
                            entry.value: entry.key
                        }[vars.roleId] ??
                        -1,
                  ),
                  SizedBox(height: 14),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text(
                            "Robot fault:     ",
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: ToggleButtons(
                            fillColor: Color.fromARGB(10, 244, 67, 54),
                            focusColor: Color.fromARGB(170, 244, 67, 54),
                            highlightColor: Color.fromARGB(170, 244, 67, 54),
                            selectedBorderColor:
                                Color.fromARGB(170, 244, 67, 54),
                            selectedColor: Colors.red,
                            children: <Widget>[
                              Icon(
                                Icons.cancel,
                              )
                            ],
                            isSelected: <bool>[vars.faultMessage != null],
                            onPressed: (final int index) {
                              assert(index == 0);
                              setState(() {
                                vars.faultMessage =
                                    vars.faultMessage.onNull("No input");
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  if (vars.faultMessage != null)
                    TextField(
                      textDirection: TextDirection.rtl,
                      onChanged: (final String value) {
                        vars.faultMessage = value;
                      },
                      decoration: InputDecoration(hintText: "Robot fault"),
                    ),
                  SizedBox(
                    height: 14,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SubmitButton(
                      validate: () => formKey.currentState!.validate(),
                      resetForm: () {
                        setState(() {
                          vars.reset();
                          teamSelectionController.clear();
                          messageController.clear();
                        });
                      },
                      mutation: """
                  mutation MyMutation (\$team_id: Int, \$message: String, \$robot_role_id: Int, \$fault_message: String){
                  insert_specific(objects: {team_id: \$team_id, message: \$message, robot_role_id: \$robot_role_id}) {
                    returning {
                  team_id
                  message
                    }
                  }
                  ${vars.faultMessage == null ? "" : """
  insert_broken_robots(objects: {team_id: \$team_id, message: \$fault_message}, on_conflict: {constraint: broken_robots_team_id_key, update_columns: message}) {
    affected_rows
  }"""}
                  }

                      """,
                      vars: vars,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
