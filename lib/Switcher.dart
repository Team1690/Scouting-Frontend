import 'package:flutter/material.dart';

class Switcher extends StatefulWidget {
  @override
  _SwitcherState createState() => _SwitcherState();

  final List<String> labels;
  final List<Color> colors;
  final Function(String) onChange;

  Switcher({
    @required final this.labels,
    @required final this.colors,
    final this.onChange,
  });
}

class _SwitcherState extends State<Switcher> {
  List<bool> pressed;

  @override
  void initState() {
    super.initState();
    resetPressed();
  }

  void resetPressed() {
    this.setState(() {
      this.pressed = List<bool>.filled(widget.labels.length, false);
    });
  }

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      width: 347,
      height: 50,
      child: Row(
        children: [
          for (int i = 0; i < widget.labels.length; i++)
            Container(
              width: 115,
              height: 50,
              child: OutlineButton(
                child: Text(widget.labels[i]),
                textColor: this.pressed[i] ? widget.colors[i] : Colors.black,
                splashColor: !this.pressed[i] ? widget.colors[i] : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: i == 0
                      ? BorderRadius.horizontal(
                          left: Radius.circular(20),
                        )
                      : i == widget.labels.length - 1
                          ? BorderRadius.horizontal(
                              right: Radius.circular(20),
                            )
                          : BorderRadius.zero,
                ),
                borderSide: BorderSide(color: Colors.transparent),
                highlightedBorderColor: Colors.transparent,
                onPressed: () {
                  final bool wasPressed = pressed[i];
                  resetPressed();
                  if (!wasPressed) this.setState(() => this.pressed[i] = true);

                  if (widget.onChange != null)
                    widget.onChange(widget.labels[i]);
                },
              ),
            ),
        ],
      ),
    );
  }
}
