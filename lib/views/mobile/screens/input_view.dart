import 'package:flutter/material.dart';
import 'package:scouting_frontend/net/send_match_api.dart';
import 'package:scouting_frontend/models/match_model.dart';
import 'package:scouting_frontend/views/mobile/counter.dart';
import 'package:scouting_frontend/views/mobile/match_dropdown.dart';
import 'package:scouting_frontend/views/mobile/section_divider.dart';
import 'package:scouting_frontend/views/mobile/submit_button.dart';
import 'package:scouting_frontend/views/mobile/switcher.dart';
import 'package:scouting_frontend/views/mobile/teams_dropdown.dart';

class UserInput extends StatefulWidget {
  final TextEditingController matchNumberController = TextEditingController();

  final TextEditingController teamNumberController = TextEditingController();

  @override
  _UserInputState createState() => _UserInputState();
}

class _UserInputState extends State<UserInput> {
  Match match = Match();
  int selectedClimbIndex = -1; // -1 means nothing

  void clearForm() {
    setState(() {
      match = new Match();
      selectedClimbIndex = -1;

      widget.matchNumberController.clear();
      widget.teamNumberController.clear();
    });
  }

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Column(
          children: [
            SectionDivider(label: 'Match Details'),
            MatchTextBox(
              onChange: (final int value) =>
                  setState(() => match.matchNumber = value),
              controller: widget.matchNumberController,
            ),
            SizedBox(
              height: 15,
            ),
            TeamsDropdown(
              onChange: (final int value) =>
                  setState(() => match.teamNumber = value),
              typeAheadController: widget.teamNumberController,
            ),
            SectionDivider(label: 'Auto'),
            Counter(
              label: 'Upper Goal:',
              icon: Icons.adjust,
              onChange: (final int count) =>
                  setState(() => match.autoUpperGoal = count),
              count: match.autoUpperGoal,
            ),
            Counter(
              label: 'Bottom Goal:',
              icon: Icons.surround_sound_outlined,
              onChange: (final int count) =>
                  setState(() => match.autoBottomGoal = count),
              count: match.autoBottomGoal,
            ),
            SectionDivider(label: 'Teleop'),
            Counter(
              label: 'Upper Goal:',
              icon: Icons.adjust,
              onChange: (final int count) =>
                  setState(() => match.teleUpperGoal = count),
              count: match.teleUpperGoal,
            ),
            SectionDivider(label: 'End Game'),
            Switcher(
              labels: [
                'Climbed',
                'Failed',
                'No attempt',
              ],
              colors: [
                Colors.green,
                Colors.pink,
                Colors.amber,
              ],
              selected: selectedClimbIndex,
              onChange: (final int index) => setState(() {
                selectedClimbIndex = index == selectedClimbIndex ? -1 : index;
                match.climbStatus = intToClimbOption(selectedClimbIndex);
              }),
            ),
            // const SizedBox(height: 20),
            SectionDivider(label: 'Send Data'),
            SubmitButton(
              mutation:
                  """mutation MyMutation(\$auto_balls: Int, \$climb_id: Int, \$number: Int, \$team_id: Int, \$teleop_inner: Int, \$teleop_outer: Int, \$match_type_id : Int, \$initiation_line: Boolean, \$defended_by: Int) {
  insert_match(objects: {auto_balls: \$auto_balls, climb_id: \$climb_id, number: \$number, team_id: \$team_id, teleop_inner: \$teleop_inner, teleop_outer: \$teleop_outer, match_type_id: \$match_type_id, initiation_line: \$initiation_line, defended_by: \$defended_by}) {
    returning {
      auto_balls
      climb_id
      number
      team_id
      teleop_inner
      teleop_outer
    }
  }
}
              """,
              vars: {
                "auto_balls": match.autoUpperGoal,
                "climb_id": 2,
                "number": match.matchNumber,
                "team_id": 1,
                "teleop_inner": match.teleUpperGoal,
                "teleop_outer": match.teleUpperGoal,
                "match_type_id": 1,
                "defended_by": 254,
                "initiation_line": true,
              },
              onPressed: clearForm,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
