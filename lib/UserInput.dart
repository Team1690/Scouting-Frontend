import 'package:ScoutingFrontend/Counter.dart';
import 'package:ScoutingFrontend/EndGame.dart';
import 'package:ScoutingFrontend/SectionDivider.dart';
import 'package:flutter/material.dart';

class UserInput extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        children: [
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
          // SectionDivider(label: 'Endgame'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: EndGame(
              options: ['Climbed', 'Faild', 'No attemtp'],
            ),
          ),
        ],
      ),
    );
  }
}
