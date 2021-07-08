import 'dart:developer';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/net/send_match_api.dart';
import 'package:scouting_frontend/views/widgets/counter.dart';
import 'package:scouting_frontend/views/widgets/match_dropdown.dart';
import 'package:scouting_frontend/views/widgets/section_divider.dart';
import 'package:scouting_frontend/views/widgets/switcher.dart';
import 'package:scouting_frontend/views/widgets/submit_button.dart';
import 'package:scouting_frontend/models/match_model.dart';
import 'package:scouting_frontend/views/widgets/teams_dropdown.dart';

class UserInput extends StatelessWidget {
  final List<String> teams =
      List<String>.generate(10, (index) => Random().nextInt(5000).toString());
  final String selectedTeam = '';

  Match match = Match();
  Future<int> response;
  TextEditingController _controller = TextEditingController();
  TextEditingController _controller2 = TextEditingController();

  @override
  Widget build(final BuildContext context) {
    void clearForm() => {_controller.clear(), _controller2.clear()};
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
              onChange: (value) => match.matchNumber = value,
              controller: _controller,
            ),
            SizedBox(
              height: 15,
            ),
            TeamsDropdown(
              onChange: (value) => match.teamNumber = value,
              typeAheadController: _controller2,
            ),
            SectionDivider(label: 'Auto'),
            Counter(
              label: 'Upper Goal:',
              icon: Icons.adjust,
              onChange: (int count) => match.autoUpperGoal = count,
            ),
            Counter(
              label: 'Bottom Goal:',
              icon: Icons.surround_sound_outlined,
              onChange: (int count) => match.autoBottomGoal = count,
            ),
            SectionDivider(label: 'Teleop'),
            Counter(
              label: 'Upper Goal:',
              icon: Icons.adjust,
              onChange: (int count) => match.teleUpperGoal = count,
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
              onValueChanged: (climbOptions) =>
                  match.climbStatus = climbOptions,
            ),
            // const SizedBox(height: 20),
            SectionDivider(label: 'Send Data'),
            SubmitButton(
              uploadData: () async => await SendMatchApi.sendData(match),
              onPressed: clearForm,

              // print(match.matchNumber);
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
