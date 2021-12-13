import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/mobile/switcher.dart';

class PitViewSwitcher extends StatefulWidget {
  PitViewSwitcher(
      {Key key, this.padding, this.onChange, this.labels, this.colors})
      : super(key: key);
  EdgeInsetsGeometry padding;
  int selectedIndex = -1;
  Function(int) onChange;
  List<String> labels;
  List<Color> colors;
  @override
  _PitViewSwitcherState createState() => _PitViewSwitcherState();
}

class _PitViewSwitcherState extends State<PitViewSwitcher> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Switcher(
        labels: widget.labels,
        colors: widget.colors,
        selected: widget.selectedIndex,
        onChange: (int index) => setState(() {
          index = index == widget.selectedIndex ? -1 : index;
          widget.onChange(index);
          widget.selectedIndex = index;
        }),
      ),
    );
  }
}
