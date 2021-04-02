import 'package:flutter/cupertino.dart';

class SegmentControl extends StatefulWidget {
  List<Widget> children = const <Widget>[];
  List<String> headers = const <String>[];

  SegmentControl({@required this.children, @required this.headers});
  @override
  _SegmentControlState createState() => _SegmentControlState();
}

class _SegmentControlState extends State<SegmentControl> {
  int currentSegemnt = 0;

  @override
  Widget build(BuildContext context) {
    Widget currentWidget = widget.children[currentSegemnt];
    // currentSegemnt = widget.controller;
    return Column(
      children: [
        Container(
          width: 230,
          child: CupertinoSlidingSegmentedControl(
              children: {
                0: Text(widget.headers[0]),
                1: Text(widget.headers[1]),
              },
              groupValue: currentSegemnt,
              onValueChanged: (newValue) {
                setState(() {
                  currentSegemnt = newValue;
                  currentWidget = widget.children[currentSegemnt];
                });
              }),
        ),
        SizedBox(
          height: 20,
        ),
        AnimatedSwitcher(
          child: currentWidget,
          duration: Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) =>
              ScaleTransition(
            scale: animation,
            child: child,
          ),
        )
      ],
    );
  }
}
