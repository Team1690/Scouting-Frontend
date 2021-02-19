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
            label: const Text('Upper Goal:'),
            icon: Icons.precision_manufacturing_outlined,
          ),
          Counter(
            label: const Text('Bottom Goal:'),
            icon: Icons.precision_manufacturing_outlined,
          ),
          Counter(
            label: const Text('Missed:'),
            icon: Icons.precision_manufacturing_outlined,
          ),
          SectionDivider(label: 'Teleop'),
          Counter(
            label: const Text('Upper Goal:'),
            icon: Icons.gamepad,
          ),
          Counter(
            label: const Text('Missed:'),
            icon: Icons.gamepad,
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
