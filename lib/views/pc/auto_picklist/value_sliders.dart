import "package:flutter/material.dart";
import "package:scouting_frontend/views/mobile/counter.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";

class ValueSliders extends StatefulWidget {
  const ValueSliders({required this.onButtonPress});

  final Function(double slider0, double slider1, double slider2) onButtonPress;

  @override
  State<ValueSliders> createState() => _ValueSlidersState();
}

class _ValueSlidersState extends State<ValueSliders> {
  double gamepiecesSumValue = 0.5;
  double gamepiecesPointsValue = 0.5;
  double autoBalancePointsValue = 0.5;
  @override
  Widget build(final BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SectionDivider(label: "GamePiece Sum"),
          ...<Widget>[
            Slider(
              value: gamepiecesSumValue,
              onChanged: (final double newValue) => setState(() {
                gamepiecesSumValue = newValue;
              }),
            ),
            SectionDivider(label: "GamePiece Points"),
            Slider(
              value: gamepiecesPointsValue,
              onChanged: (final double newValue) => setState(() {
                gamepiecesPointsValue = newValue;
              }),
            ),
            SectionDivider(label: "Auto Balance Points"),
            Slider(
              value: autoBalancePointsValue,
              onChanged: (final double newValue) => setState(() {
                autoBalancePointsValue = newValue;
              }),
            ),
          ].expand(
            (final Widget element) => <Widget>[
              const SizedBox(
                height: 10,
              ),
              element,
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          RoundedIconButton(
            onPress: () => widget.onButtonPress(
              gamepiecesPointsValue,
              gamepiecesSumValue,
              autoBalancePointsValue,
            ),
            icon: Icons.calculate_outlined,
            onLongPress: () => widget.onButtonPress(
              gamepiecesPointsValue,
              gamepiecesSumValue,
              autoBalancePointsValue,
            ),
          ),
        ],
      );
}
