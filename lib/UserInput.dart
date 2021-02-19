import 'package:ScoutingFrontend/Counter.dart';
import 'package:ScoutingFrontend/EndGame.dart';
import 'package:ScoutingFrontend/SectionDivider.dart';
import 'package:flutter/material.dart';

class UserInput extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    return Container(
      // width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      // padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        children: [
          // Container(
          //   child: Text(
          //     'Auto',
          //     textScaleFactor: 3,
          //   ),
          //   // color: Colors.grey,
          // ),
          SectionDivider(label: 'Auto'),
          Counter(
            label: Text('Upper Goal:'),
            icon: Icons.precision_manufacturing_outlined,
          ),
          Counter(
            label: Text('Bottom Goal:'),
            icon: Icons.precision_manufacturing_outlined,
          ),
          Counter(
            label: Text('Missed:'),
            icon: Icons.precision_manufacturing_outlined,
          ),
          SectionDivider(label: 'Teleop'),
          Counter(
            label: Text('Upper Goal:'),
            icon: Icons.gamepad,
          ),
          Counter(
            label: Text('Missed:'),
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
