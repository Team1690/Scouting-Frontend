import "package:flutter/material.dart";

import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import 'package:scouting_frontend/views/mobile/Selector.dart';
import "package:scouting_frontend/views/mobile/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/counter.dart";
import "package:scouting_frontend/views/mobile/match_dropdown.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/submit_button.dart";
import "package:scouting_frontend/views/mobile/switcher.dart";

class UserInput extends StatefulWidget {
  @override
  State<UserInput> createState() => _UserInputState();
}

class _UserInputState extends State<UserInput> {
  final TextEditingController matchNumberController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController teamNumberController = TextEditingController();
  Match match = new Match();
  // -1 means nothing
  void clearForm(final BuildContext context) {
    setState(() {
      matchNumberController.clear();
      teamNumberController.clear();
    });
  }

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: <Widget>[
              SectionDivider(label: "Match Details"),
              MatchTextBox(
                validate: (final String? p0) {
                  if (p0 == null || p0.isEmpty) {
                    return "Please enter a match number";
                  }
                  return null;
                },
                onChange: (final int value) => match.matchNumber = value,
                controller: matchNumberController,
              ),
              SizedBox(
                height: 15,
              ),
              FormField<LightTeam>(
                validator: (final LightTeam? value) {
                  if (value == null) return "Pick a Team";
                  return null;
                },
                builder: (final FormFieldState<LightTeam> state) =>
                    TeamSelectionFuture(
                  controller: teamNumberController,
                  onChange: (final LightTeam team) {
                    match.team = team;
                    state.didChange(team);
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SectionDivider(label: "Autonomous"),
              SizedBox(
                height: 20,
              ),
              Counter(
                label: "Upper scored",
                icon: Icons.adjust,
                count: match.autoHigh,
                onChange: (final int p0) => match.autoHigh = p0,
              ),
              SizedBox(
                height: 10,
              ),
              Counter(
                label: "Upper missed",
                icon: Icons.error,
                count: match.autoHighMissed,
                onChange: (final int p0) => match.autoHighMissed = p0,
              ),
              SizedBox(
                height: 10,
              ),
              Counter(
                label: "Lower scored",
                icon: Icons.adjust,
                count: match.autoLow,
                onChange: (final int p0) => match.autoLow = p0,
              ),
              SizedBox(
                height: 20,
              ),
              SectionDivider(label: "Teleoperated"),
              SizedBox(
                height: 20,
              ),
              Counter(
                label: "Upper scored",
                icon: Icons.adjust,
                count: match.teleHigh,
                onChange: (final int p0) => match.teleHigh = p0,
              ),
              SizedBox(
                height: 10,
              ),
              Counter(
                label: "Upper missed",
                icon: Icons.error,
                count: match.teleHighMissed,
                onChange: (final int p0) => match.teleHighMissed = p0,
              ),
              SizedBox(
                height: 10,
              ),
              Counter(
                label: "Lower scored",
                icon: Icons.adjust,
                count: match.teleLow,
                onChange: (final int p0) => match.teleLow = p0,
              ),
              SizedBox(
                height: 20,
              ),
              SectionDivider(label: "Climb"),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Selector(
                  valueOnReRender: match.climbStatus,
                  values: [
                    "Choose a climb result",
                    "No attempt",
                    "Failed",
                    "Level 1",
                    "Level 2",
                    "Level 3",
                    "Level 4"
                  ],
                  initialValue: "Choose a climb result",
                  onChange: (final String p0) => match.climbStatus = p0,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SubmitButton(
                  resetForm: () {
                    setState(() {
                      match.clear();
                      teamNumberController.clear();
                      matchNumberController.clear();
                    });
                  },
                  validate: () {
                    return formKey.currentState!.validate();
                  },
                  vars: match,
                  mutation: mutation)
            ],
          ),
        ),
      ),
    );
  }
}

const String mutation = """
mutation MyMutation(\$auto_lower: Int, \$auto_upper: Int, \$auto_upper_missed: Int, \$climb_id: Int, \$match_number: Int, \$team_id: Int, \$tele_lower: Int, \$tele_upper: Int, \$tele_upper_missed: Int) {
  insert_match_2022(objects: {auto_lower: \$auto_lower, auto_upper: \$auto_upper, auto_upper_missed: \$auto_upper_missed, climb_id: \$climb_id, match_number: \$match_number, team_id: \$team_id, tele_lower: \$tele_lower, tele_upper: \$tele_upper, tele_upper_missed: \$tele_upper_missed}) {
    returning {
      id
    }
  }
}
""";
