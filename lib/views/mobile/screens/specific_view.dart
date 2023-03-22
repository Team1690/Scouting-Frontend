import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/dropdown_line.dart";

import "package:scouting_frontend/views/mobile/screens/robot_image.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/specific_vars.dart";
import "package:scouting_frontend/views/mobile/submit_button.dart";
import "package:scouting_frontend/views/mobile/team_and_match_selection.dart";

class Specific extends StatefulWidget {
  @override
  State<Specific> createState() => _SpecificState();
}

class _SpecificState extends State<Specific> {
  final GlobalKey<FormState> formKey = GlobalKey();
  List<TextEditingController> controllers =
      List<TextEditingController>.generate(
    9,
    (final int i) => TextEditingController(),
  );
  final SpecificVars vars = SpecificVars();
  final FocusNode node = FocusNode();

  @override
  Widget build(final BuildContext context) => GestureDetector(
        onTap: node.unfocus,
        child: Scaffold(
          drawer: SideNavBar(),
          appBar: AppBar(
            actions: <Widget>[RobotImageButton(teamId: () => vars.team?.id)],
            centerTitle: true,
            title: const Text("Specific"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(defaultPadding),
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
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        hintText: "Scouter names",
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TeamAndMatchSelection(
                      matchController:
                          controllers[1], //index of matchController
                      teamNumberController:
                          controllers[2], //index of teamNumberController
                      onChange: (
                        final ScheduleMatch selectedMatch,
                        final LightTeam? selectedTeam,
                      ) {
                        setState(() {
                          vars.team = selectedTeam;
                          vars.scheduleMatch = selectedMatch;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ToggleButtons(
                      fillColor: const Color.fromARGB(10, 244, 67, 54),
                      selectedColor: Colors.red,
                      selectedBorderColor: Colors.red,
                      children: const <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
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
                    const SizedBox(height: 15.0),
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
                    const SizedBox(height: 15.0),
                    DropdownLine<String>(
                      onTap: () {
                        setState(() {
                          vars.intake = vars.intake.onNull(
                            controllers[4].text,
                          ); //index of intakeController
                        });
                      },
                      value: vars.intake,
                      onChange: (final String p0) => vars.intake = p0,
                      controller: controllers[4], //index of intakeController
                      label: "Intake",
                    ),
                    const SizedBox(height: 15.0),
                    DropdownLine<String>(
                      value: vars.placement,
                      onTap: () {
                        setState(() {
                          vars.placement = vars.placement.onNull(
                            controllers[5].text,
                          ); //index of shooterController
                        });
                      },
                      onChange: (final String p0) => vars.placement = p0,
                      controller: controllers[5], //index of shooterController
                      label: "Placement",
                    ),
                    const SizedBox(height: 15.0),
                    DropdownLine<String>(
                      onTap: () {
                        setState(() {
                          vars.defense = vars.defense.onNull(
                            controllers[6].text,
                          ); //index of defenseController
                        });
                      },
                      value: vars.defense,
                      onChange: (final String p0) => vars.defense = p0,
                      controller: controllers[6], //index of defenseController
                      label: "Defense",
                    ),
                    const SizedBox(height: 15.0),
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
                    const SizedBox(
                      height: 15,
                    ),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(
                              "Robot fault:     ",
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: ToggleButtons(
                              fillColor: const Color.fromARGB(10, 244, 67, 54),
                              focusColor:
                                  const Color.fromARGB(170, 244, 67, 54),
                              highlightColor:
                                  const Color.fromARGB(170, 244, 67, 54),
                              selectedBorderColor:
                                  const Color.fromARGB(170, 244, 67, 54),
                              selectedColor: Colors.red,
                              children: const <Widget>[
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
                    const SizedBox(
                      height: 15,
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: vars.faultMessage == null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Container(),
                      secondChild: TextField(
                        controller: controllers[8], //index of faultController
                        textDirection: TextDirection.rtl,
                        onChanged: (final String value) {
                          vars.faultMessage = value;
                        },
                        decoration:
                            const InputDecoration(hintText: "Robot fault"),
                      ),
                    ),
                    const SizedBox(
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
                              if (controller != controllers[0]) {
                                controller.clear();
                              }
                            }
                          });
                        },
                        mutation: """
mutation A(\$defense: String, \$drivetrain_and_driving: String, \$general_notes: String, \$intake: String, \$is_rematch: Boolean, \$placement: String, \$scouter_name: String, \$team_id: Int, \$schedule_match_id: Int, \$fault_message:String){
  insert__2023_specific(objects: {defense: \$defense, drivetrain_and_driving: \$drivetrain_and_driving, general_notes: \$general_notes, intake: \$intake, is_rematch: \$is_rematch, placement: \$placement, scouter_name: \$scouter_name, team_id: \$team_id, schedule_match_id: \$schedule_match_id}) {
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
