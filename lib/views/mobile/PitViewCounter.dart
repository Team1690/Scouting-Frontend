import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/mobile/counter.dart';

import '../constants.dart';

class PitViewCounter extends StatefulWidget {
  PitViewCounter({Key key, this.onChange, this.amount}) : super(key: key);
  final Function(int) onChange;
  int amount;
  @override
  State<PitViewCounter> createState() => _PitViewCounterState();
}

class _PitViewCounterState extends State<PitViewCounter> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: defaultPadding, bottom: defaultPadding),
      child: Counter(
        label: 'Drive Motors',
        icon: Icons.adjust,
        count: widget.amount,
        upperLimit: 10,
        lowerLimit: 2,
        stepValue: 2,
        longPressedValue: 4,
        onChange: (newValue) {
          widget.onChange(newValue);
        },
      ),
    );
  }
}
