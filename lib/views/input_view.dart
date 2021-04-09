import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:scouting_frontend/views/widgets/counter.dart';
import 'package:scouting_frontend/views/widgets/section_divider.dart';
import 'package:scouting_frontend/views/widgets/switcher.dart';
import 'package:scouting_frontend/views/widgets/submit_button.dart';

class UserInput extends StatelessWidget {
  final List<String> teams =
      List<String>.generate(10, (index) => Random().nextInt(5000).toString());
  final String selectedTeam = '';

  @override
  Widget build(final BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SectionDivider(label: 'Match Details'),
            DropDownField(
              // value: selectedTeam,
              required: false,
              strict: true,
              labelText: 'Team Number',
              // icon: Icon(Icons.format_list_numbered),
              items: teams,
              onValueChanged: (value) => (print(value)),
              // setter: (dynamic newValue) {
              //   selectedTeam = newValue;
              // }
            ),
            SizedBox(
              height: 15,
            ),
            DropDownField(
              required: false,
              strict: true,
              labelText: 'Match',
              // icon: Icon(Icons.format_list_numbered),
              items: teams,
              onValueChanged: (value) => (print(value)),
            ),
            SectionDivider(label: 'Auto'),
            Counter(
              label: 'Upper Goal:',
              icon: Icons.adjust,
            ),
            Counter(
              label: 'Bottom Goal:',
              icon: Icons.surround_sound_outlined,
            ),
            Counter(
              label: 'Missed:',
              icon: Icons.clear_rounded,
            ),
            SectionDivider(label: 'Teleop'),
            Counter(
              label: 'Upper Goal:',
              icon: Icons.adjust,
            ),
            Counter(
              label: 'Missed:',
              icon: Icons.clear_rounded,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Switcher(
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
              ),
            ),
            const SizedBox(height: 20),
            const SubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
