import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/matches_provider.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/matches_search_box_future.dart";

import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/robot_image.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/specific_vars.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/submit_button.dart";

class Specific extends StatefulWidget {
  @override
  State<Specific> createState() => _SpecificState();
}

class _SpecificState extends State<Specific> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController messageController = TextEditingController();
  final SpecificVars vars = SpecificVars();
  final TextEditingController matchNumberController = TextEditingController();
  final FocusNode node = FocusNode();

  final TextEditingController scouterNameController = TextEditingController();
  final TextEditingController teamNumberController = TextEditingController();
  final TextEditingController matchController = TextEditingController();
  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: node.unfocus,
      child: Scaffold(
        drawer: SideNavBar(),
        appBar: AppBar(
          actions: <Widget>[RobotImageButton(teamId: () => vars.team?.id)],
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
                  TextFormField(
                    controller: scouterNameController,
                    validator: (final String? value) =>
                        value != null && value.isNotEmpty
                            ? null
                            : "Please enter your name",
                    onChanged: (final String p0) {
                      vars.name = p0;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      hintText: "Scouter names",
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TeamSelectionFuture(
                    controller: teamNumberController,
                    onChange: (final LightTeam team) {
                      setState(() {
                        vars.team = team;
                      });
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MatchSelectionFuture(
                    controller: matchController,
                    team: vars.team,
                    matches: vars.team.mapNullable(
                          (final LightTeam p0) => MatchesProvider.of(context)
                              .matches
                              .where(
                                (final ScheduleMatch element) =>
                                    (element.red0.id == p0.id ||
                                        element.red1.id == p0.id ||
                                        element.red2.id == p0.id ||
                                        element.red3?.id == p0.id ||
                                        element.blue0.id == p0.id ||
                                        element.blue1.id == p0.id ||
                                        element.blue2.id == p0.id ||
                                        element.blue3?.id == p0.id),
                              )
                              .toList(),
                        ) ??
                        <ScheduleMatch>[],
                    onChange: (final ScheduleMatch selectedMatch) {
                      setState(() {
                        vars.matchesId = selectedMatch.id;
                      });
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ToggleButtons(
                    fillColor: Color.fromARGB(10, 244, 67, 54),
                    selectedColor: Colors.red,
                    selectedBorderColor: Colors.red,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text("Rematch"),
                      )
                    ],
                    isSelected: <bool>[vars.isRematch],
                    onPressed: (final int i) {
                      setState(() {
                        vars.isRematch = !vars.isRematch;
                      });
                    },
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
                  AnimatedCrossFade(
                    duration: Duration(milliseconds: 300),
                    crossFadeState: vars.faultMessage == null
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Container(),
                    secondChild: TextField(
                      textDirection: TextDirection.rtl,
                      onChanged: (final String value) {
                        vars.faultMessage = value;
                      },
                      decoration: InputDecoration(hintText: "Robot fault"),
                    ),
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
                          matchNumberController.clear();
                          scouterNameController.clear();
                          teamNumberController.clear();
                          messageController.clear();
                        });
                      },
                      mutation: """
mutation InsertSpecific(\$team_id: Int, \$message: String, \$fault_message: String, \$is_rematch: Boolean, \$scouter_name: String,\$matches_id:Int!) {
  insert_specific(objects: {team_id: \$team_id, message: \$message, is_rematch: \$is_rematch,  scouter_name: \$scouter_name,matches_id:\$matches_id}) {
    affected_rows
  }
                  ${vars.faultMessage == null ? "" : """
  insert_faults(objects: {team_id: \$team_id, message: \$fault_message}) {
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
