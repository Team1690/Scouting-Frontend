import "package:flutter/material.dart";
import "package:scouting_frontend/views/mobile/counter.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";

class ValueSliders extends StatefulWidget {
  const ValueSliders({required this.onButtonPress});

  final Function(
    double slider0,
    double slider1,
    double slider2,
    bool swerve,
    bool taken,
  ) onButtonPress;

  @override
  State<ValueSliders> createState() => _ValueSlidersState();
}

class _ValueSlidersState extends State<ValueSliders> {
  double gamepiecesSumValue = 0.5;
  double gamepiecesPointsValue = 0.5;
  double autoBalancePointsValue = 0.5;
  bool filterSwerve = false;
  bool filterTaken = false;
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
          SectionDivider(label: "Filters"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ToggleButtons(
                children: const <Text>[Text("Filter Taken")],
                isSelected: <bool>[filterTaken],
                onPressed: (final int unused) => setState(() {
                  filterTaken = !filterTaken;
                }),
              ),
              const SizedBox(
                width: 20,
              ),
              ToggleButtons(
                children: const <Text>[Text("Filter Swerve")],
                isSelected: <bool>[filterSwerve],
                onPressed: (final int unused) => setState(() {
                  filterSwerve = !filterSwerve;
                }),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          RoundedIconButton(
            color: Colors.green,
            onPress: () => widget.onButtonPress(
              gamepiecesPointsValue,
              gamepiecesSumValue,
              autoBalancePointsValue,
              filterSwerve,
              filterTaken,
            ),
            icon: Icons.calculate_outlined,
            onLongPress: () => widget.onButtonPress(
              gamepiecesPointsValue,
              gamepiecesSumValue,
              autoBalancePointsValue,
              filterSwerve,
              filterTaken,
            ),
          ),
        ],
      );
}
