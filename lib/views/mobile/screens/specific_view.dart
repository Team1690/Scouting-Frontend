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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController intakeController = TextEditingController();
  final TextEditingController drivingController = TextEditingController();
  final TextEditingController placementController = TextEditingController();
  final TextEditingController defenseController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController faultController = TextEditingController();
  final SpecificVars vars = SpecificVars();
  final FocusNode node = FocusNode();

  @override
  Widget build(final BuildContext context) {
    return TeamAndMatchSelection(
      onChange: (
        final ScheduleMatch selectedMatch,
        final LightTeam? selectedTeam,
      ) {
        setState(() {
          vars.team = selectedTeam;
          vars.scheduleMatch = selectedMatch;
        });
      },
      buildWithoutTeam: (final Widget teamAndMatchBox, final _) =>
          outerBody(context, teamAndMatchBox, appBar()),
      buildWithTeam: (
        final BuildContext context,
        final LightTeam team,
        final Widget teamAndMatchBox,
        final void Function() resetSearchbox,
      ) =>
          outerBody(
        context,
        Column(
          children: <Widget>[
            teamAndMatchBox,
            TextFormField(
              controller: nameController,
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
                  vars.drivetrainAndDriving = vars.drivetrainAndDriving.onNull(
                    drivingController.text,
                  );
                });
              },
              value: vars.drivetrainAndDriving,
              onChange: (final String p0) => vars.drivetrainAndDriving = p0,
              controller: drivingController,
              label: "Driving & Drivetrain",
            ),
            SizedBox(height: 15.0),
            DropdownLine<String>(
              onTap: () {
                setState(() {
                  vars.intake = vars.intake.onNull(
                    intakeController.text,
                  );
                });
              },
              value: vars.intake,
              onChange: (final String p0) => vars.intake = p0,
              controller: intakeController,
              label: "Intake",
            ),
            SizedBox(height: 15.0),
            DropdownLine<String>(
              value: vars.placement,
              onTap: () {
                setState(() {
                  vars.placement = vars.placement.onNull(
                    placementController.text,
                  );
                });
              },
              onChange: (final String p0) => vars.placement = p0,
              controller: placementController,
              label: "Placement",
            ),
            SizedBox(height: 15.0),
            DropdownLine<String>(
              onTap: () {
                setState(() {
                  vars.defense = vars.defense.onNull(
                    defenseController.text,
                  );
                });
              },
              value: vars.defense,
              onChange: (final String p0) => vars.defense = p0,
              controller: defenseController,
              label: "Defense",
            ),
            SizedBox(height: 15.0),
            DropdownLine<String>(
              onTap: () {
                setState(() {
                  vars.generalNotes = vars.generalNotes.onNull(
                    notesController.text,
                  );
                });
              },
              value: vars.generalNotes,
              onChange: (final String p0) => vars.generalNotes = p0,
              controller: notesController,
              label: "General Notes",
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
                      selectedBorderColor: Color.fromARGB(170, 244, 67, 54),
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
                controller: faultController,
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
                    nameController.clear();
                    intakeController.clear();
                    drivingController.clear();
                    placementController.clear();
                    defenseController.clear();
                    faultController.clear();
                    notesController.clear();
                    resetSearchbox();
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
        appBar(team),
      ),
    );
  }

  GestureDetector outerBody(
    final BuildContext context,
    final Widget body,
    final AppBar appBar,
  ) {
    return GestureDetector(
      onTap: node.unfocus,
      child: Scaffold(
        drawer: SideNavBar(),
        appBar: appBar,
        body: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: body,
            ),
          ),
        ),
      ),
    );
  }

  AppBar appBar([final LightTeam? team]) {
    return AppBar(
      actions: <Widget>[
        if (team != null) RobotImageButton(teamId: () => team.id)
      ],
      centerTitle: true,
      title: Text("Specific"),
    );
  }
}
