import "dart:math";

import "package:flutter/material.dart";

class Counter extends StatelessWidget {
  Counter({
    required this.label,
    required this.icon,
    required this.onChange,
    this.plus = Colors.green,
    this.minus = Colors.red,
    this.stepValue = 1,
    this.upperLimit = 100,
    this.lowerLimit = 0,
    this.longPressedValue = 2,
    required this.count,
  });
  final String label;
  final IconData icon;
  final Color plus;
  final Color minus;
  final void Function(int) onChange;
  final int stepValue;
  final int upperLimit;
  final int lowerLimit;
  final int longPressedValue;

  final int count;
  @override
  Widget build(final BuildContext context) => Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Spacer(),
              Expanded(
                child: Icon(
                  icon,
                  color: Colors.blue,
                  size: 30,
                  semanticLabel: "Text to announce in accessibility modes",
                ),
              ),
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      label,
                      maxLines: 1,
                      textScaleFactor: 1.5,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const Spacer(
                flex: 2,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Spacer(),
                Expanded(
                  flex: 6,
                  child: RoundedIconButton(
                    color: minus,
                    icon: Icons.remove,
                    onPress: () => onChange(max(lowerLimit, count - stepValue)),
                    onLongPress: () =>
                        onChange(max(lowerLimit, count - longPressedValue)),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    "$count",
                    style: const TextStyle(fontSize: 40),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: RoundedIconButton(
                    color: plus,
                    icon: Icons.add,
                    onPress: () {
                      onChange(min(upperLimit, count + stepValue));
                    },
                    onLongPress: () {
                      onChange(min(upperLimit, count + longPressedValue));
                    },
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      );
}

class RoundedIconButton extends StatelessWidget {
  RoundedIconButton({
    required this.icon,
    required this.onPress,
    required this.onLongPress,
    final Color? color,
  }) : color = color ?? Colors.amber;

  final IconData icon;
  final void Function() onPress;
  final void Function() onLongPress;
  final Color color;

  @override
  Widget build(final BuildContext context) => RawMaterialButton(
        elevation: 6.0,
        onPressed: onPress,
        onLongPress: onLongPress,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        fillColor: color,
        child: Icon(
          icon,
          color: Colors.white,
          size: 40,
        ),
      );
}

class CounterSpec {
  const CounterSpec(
    this.label,
    this.icon,
    this.plus,
    this.minus,
    this.getValues,
    this.updateValues,
  );

  const CounterSpec.amberColors(
    final String label,
    final IconData icon,
    final int Function() getValues,
    final void Function(int) updateValues,
  ) : this(
          label,
          icon,
          Colors.amber,
          Colors.amber,
          getValues,
          updateValues,
        );

  const CounterSpec.purpleColors(
    final String label,
    final IconData icon,
    final int Function() getValues,
    final void Function(int) updateValues,
  ) : this(
          label,
          icon,
          Colors.deepPurple,
          Colors.deepPurple,
          getValues,
          updateValues,
        );
  final String label;
  final IconData icon;
  final Color plus;
  final Color minus;
  final int Function() getValues;
  final void Function(int) updateValues;
}
