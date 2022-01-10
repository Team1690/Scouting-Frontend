import "package:flutter/material.dart";

import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
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

  final TextEditingController teamNumberController = TextEditingController();

  Match match = Match();

  int selectedClimbIndex = -1;
  // -1 means nothing
  void clearForm(final BuildContext context) {
    setState(() {
      match = new Match();
      selectedClimbIndex = -1;

      matchNumberController.clear();
      teamNumberController.clear();
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
          children: <Widget>[
            SectionDivider(label: "Match Details"),
            MatchTextBox(
              onChange: (final int value) => match.matchNumber = value,
              controller: matchNumberController,
            ),
            SizedBox(
              height: 15,
            ),

            TeamSelectionFuture(
              controller: teamNumberController,
              onChange: (final LightTeam team) {
                match.teamId = team.id;
                match.teamNumber = team.number;
              },
            ),
            SectionDivider(label: "Auto"),
            Counter(
              label: "Auto Balls:",
              icon: Icons.adjust,
              onChange: (final int count) => match.autoUpperGoal = count,
              count: match.autoUpperGoal,
            ),

            SectionDivider(label: "Teleop"),
            Counter(
              label: "Inner Port:",
              icon: Icons.adjust,
              onChange: (final int count) => match.teleInner = count,
              count: match.teleInner,
            ),
            Counter(
              label: "Outer Port:",
              icon: Icons.surround_sound_outlined,
              onChange: (final int count) => match.teleOuter = count,
              count: match.teleOuter,
            ),
            SectionDivider(label: "End Game"),
            Switcher(
              labels: <String>[
                "Climbed",
                "Failed",
                "No attempt",
              ],
              colors: <Color>[
                Colors.green,
                Colors.pink,
                Colors.amber,
              ],
              onChange: (final int index) => match.climbStatus = index,
            ),

            // const SizedBox(height: 20),
            SectionDivider(label: "Send Data"),
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
              vars: match,
              resetForm: () => clearForm(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
