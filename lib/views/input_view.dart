import 'dart:developer';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:scouting_frontend/net/get_teams_api.dart';
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
            MatchDropdown(onChange: (value) => match.matchNumber = value),
            SizedBox(
              height: 15,
            ),
            TeamsDropdown(onChange: (value) => match.teamNumber = value),
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
            Counter(
              label: 'Missed:',
              icon: Icons.clear_rounded,
              onChange: (int count) => match.teleMissed = count,
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
              onPressed: () => SendMatchApi.sendData(match),
              // statusCode: SendMatchApi().statusCode,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
