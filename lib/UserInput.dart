import 'package:ScoutingFrontend/Counter.dart';
import 'package:ScoutingFrontend/EndGame.dart';
import 'package:flutter/material.dart';

class UserInput extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    return Container(
      // width: 150,
      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
      // padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        children: [
          Counter(
            label: Text('Missed:'),
          ),
          Counter(
            label: Text('Bottom Goal:'),
          ),
          Counter(
            label: Text('Upper Goal:'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 25, 0, 25),
            child: EndGame(
              options: ['Climbed', 'Faild', 'No attemtp'],
            ),
          ),
        ],
      ),
    );
  }
}
