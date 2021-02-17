import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

class Counter extends StatelessWidget {
  final Text label;
  Counter({
    final this.label,
  });

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 50,
          child: Icon(
            Icons.animation,
            color: Colors.blue,
            size: 24,
            semanticLabel: 'Text to announce in accessibility modes',
          ),
        ),
        // Text('data'),
        Expanded(
          child: label,
        ),
        Expanded(
          child: SpinBox(
            min: 0,
            max: 100,
            value: 0,
            onChanged: print,
          ),
        ),
      ],
    );
  }
}
