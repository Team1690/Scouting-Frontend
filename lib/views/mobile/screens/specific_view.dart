import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/matches_provider.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/matches_search_box_future.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/dropdown_line.dart";

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
  List<TextEditingController> controllers =
      List<TextEditingController>.generate(
    11,
    (final int i) => TextEditingController(),
  );
  final SpecificVars vars = SpecificVars();
  final FocusNode node = FocusNode();

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
          padding: EdgeInsets.all(defaultPadding),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: controllers[0], //index of nameController
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
                  MatchSelectionFuture(
                    controller: controllers[1], //index of matchController
                    matches: MatchesProvider.of(context).matches,
                    onChange: (final ScheduleMatch selectedMatch) {
                      setState(() {
                        vars.matches = selectedMatch;
                      });
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TeamSelectionFuture(
                    teams: vars.matches?.matchTypeId ==
                            IdProvider.of(context)
                                .matchType
                                .nameToId["Practice"]!
                        ? TeamProvider.of(context).teams
                        : <LightTeam?>[
                            vars.matches?.blue0,
                            vars.matches?.blue1,
                            vars.matches?.blue2,
                            vars.matches?.blue3,
                            vars.matches?.red0,
                            vars.matches?.red1,
                            vars.matches?.red2,
                            vars.matches?.red3,
                          ].whereType<LightTeam>().toList(),
                    controller: controllers[2], //index of teamController
                    onChange: (final LightTeam team) {
                      setState(() {
                        vars.team = team;
                      });
                    },
                  ),
                  SizedBox(
                    height: 15,
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
                  SizedBox(height: 15.0),
                  DropdownLine<String>(
                    onTap: () {
                      setState(() {
                        vars.drivetrainAndDriving =
                            vars.drivetrainAndDriving.onNull(
                          controllers[3].text,
                        ); //index of drivingController
                      });
                    },
                    value: vars.drivetrainAndDriving,
                    onChange: (final String p0) =>
                        vars.drivetrainAndDriving = p0,
                    controller: controllers[3], //index of drivingController
                    label: "Driving & Drivetrain",
                  ),
                  SizedBox(height: 15.0),
                  DropdownLine<String>(
                    onTap: () {
                      setState(() {
                        vars.intakeAndConveyor = vars.intakeAndConveyor.onNull(
                          controllers[4].text,
                        ); //index of intakeController
                      });
                    },
                    value: vars.intakeAndConveyor,
                    onChange: (final String p0) => vars.intakeAndConveyor = p0,
                    controller: controllers[4], //index of intakeController
                    label: "Intake & Conveyor",
                  ),
                  SizedBox(height: 15.0),
                  DropdownLine<String>(
                    value: vars.shooter,
                    onTap: () {
                      setState(() {
                        vars.shooter = vars.shooter.onNull(
                          controllers[5].text,
                        ); //index of shooterController
                      });
                    },
                    onChange: (final String p0) => vars.shooter = p0,
                    controller: controllers[5], //index of shooterController
                    label: "Shooter",
                  ),
                  SizedBox(height: 15.0),
                  DropdownLine<String>(
                    onTap: () {
                      setState(() {
                        vars.climb = vars.climb.onNull(
                          controllers[6].text,
                        ); //index of climbController
                      });
                    },
                    value: vars.climb,
                    onChange: (final String p0) => vars.climb = p0,
                    controller: controllers[6], //index of climbController
                    label: "Climb",
                  ),
                  SizedBox(height: 15.0),
                  DropdownLine<String>(
                    onTap: () {
                      setState(() {
                        vars.generalNotes = vars.generalNotes.onNull(
                          controllers[7].text,
                        ); //index of notesController
                      });
                    },
                    value: vars.generalNotes,
                    onChange: (final String p0) => vars.generalNotes = p0,
                    controller: controllers[7], //index of notesController
                    label: "General Notes",
                  ),
                  SizedBox(height: 15.0),
                  DropdownLine<String>(
                    onTap: () {
                      setState(() {
                        vars.defense = vars.defense.onNull(
                          controllers[8].text,
                        ); //index of defenseController
                      });
                    },
                    value: vars.defense,
                    onChange: (final String p0) => vars.defense = p0,
                    controller: controllers[8], //index of defenseController
                    label: "Defense",
                  ),
                  SizedBox(
                    height: 15,
                  ),
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
                    height: 15,
                  ),
                  AnimatedCrossFade(
                    duration: Duration(milliseconds: 300),
                    crossFadeState: vars.faultMessage == null
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Container(),
                    secondChild: TextField(
                      controller: controllers[9], //index of faultController
                      textDirection: TextDirection.rtl,
                      onChanged: (final String value) {
                        vars.faultMessage = value;
                      },
                      decoration: InputDecoration(hintText: "Robot fault"),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SubmitButton(
                      validate: () => formKey.currentState!.validate(),
                      resetForm: () {
                        setState(() {
                          vars.reset();
                          for (final TextEditingController controller
                              in controllers) {
                            controller.clear();
                          }
                        });
                      },
                      mutation: """
mutation A(\$team_id: Int, \$is_rematch: Boolean, \$scouter_name: String, \$matches_id: Int, \$drivetrain_and_driving: String, \$intake_and_conveyor: String, \$shooter: String, \$climb: String, \$general_notes: String, \$defense: String, \$fault_message:String){
  insert_specific_2023(objects: { team_id: \$team_id, is_rematch: \$is_rematch, scouter_name: \$scouter_name, matches_id: \$matches_id, drivetrain_and_driving: \$drivetrain_and_driving, intake_and_conveyor: \$intake_and_conveyor, shooter: \$shooter, climb: \$climb, general_notes: \$general_notes, defense: \$defense}){
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
