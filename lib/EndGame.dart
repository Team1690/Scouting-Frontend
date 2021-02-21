import 'package:flutter/cupertino.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter/material.dart';

class EndGame extends StatelessWidget {
  final List<String> labels;

  EndGame({@required final this.labels});

  @override
  Widget build(final BuildContext context) {
    return ToggleSwitch(
      labels: labels,
      minWidth: 115,
      minHeight: 50,
      cornerRadius: 20,
      inactiveBgColor: Colors.grey[300],
      activeBgColors: [Colors.green, Colors.pink, Colors.amber],
    );
  }
}
