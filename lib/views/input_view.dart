import 'package:flutter/material.dart';
import 'package:scouting_frontend/net/send_match_api.dart';
import 'package:scouting_frontend/views/widgets/counter.dart';
import 'package:scouting_frontend/views/widgets/match_dropdown.dart';
import 'package:scouting_frontend/views/widgets/section_divider.dart';
import 'package:scouting_frontend/views/widgets/switcher.dart';
import 'package:scouting_frontend/views/widgets/submit_button.dart';
import 'package:scouting_frontend/models/match_model.dart';
import 'package:scouting_frontend/views/widgets/teams_dropdown.dart';

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
              uploadData: () async => await SendMatchApi.sendData(match),
              onPressed: clearForm,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
