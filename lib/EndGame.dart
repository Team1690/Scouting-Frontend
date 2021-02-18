import 'package:flutter/cupertino.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter/material.dart';

class EndGame extends StatelessWidget {
  List<String> options = [];
  EndGame({
    final this.options,
  });

  @override
  Widget build(final BuildContext context) {
    return ToggleSwitch(
      labels: options,
      minWidth: 120,
      minHeight: 50,
      cornerRadius: 20.0,
      inactiveBgColor: Colors.grey[300],
      activeBgColors: [Colors.blue, Colors.pink, Colors.amber],
    );
  }
}
