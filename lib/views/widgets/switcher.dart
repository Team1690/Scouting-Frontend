import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/match_model.dart';

class Switcher extends StatefulWidget {
  @override
  _SwitcherState createState() => _SwitcherState();

  final List<String> labels;
  final List<Color> colors;
  final Function(String, bool) onChange;
  final double height;
  final Function(ClimbOptions) onValueChanged;
  final int selected;

  Switcher({
    @required final this.labels,
    @required final this.colors,
    @required final this.selected,
    final this.height = 70,
    final this.onChange,
    this.onValueChanged,
  });
}

class _SwitcherState extends State<Switcher> {
  List<bool> _pressed;

  @override
  void initState() {
    super.initState();
    resetPressed();
  }

  void resetPressed() =>
      setState(() => _pressed = List<bool>.filled(widget.labels.length, false));

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      width: MediaQuery.of(context).size.width,
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < widget.labels.length; i++)
            Expanded(
              child: SizedBox(
                height: widget.height,
                child: FlatButton(
                  child: Text(
                    widget.labels[i],
                    style: TextStyle(fontSize: 15),
                  ),
                  textColor: _pressed[i] ? widget.colors[i] : Colors.black,
                  splashColor: !_pressed[i] ? widget.colors[i] : Colors.grey,
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
                  onPressed: () {
                    final bool wasPressed = _pressed[i];
                    resetPressed();
                    if (!wasPressed) setState(() => _pressed[i] = true);

                    if (widget.onChange != null)
                      widget.onChange(widget.labels[i], !wasPressed);

                    switch (i) {
                      case 0:
                        widget.onValueChanged(ClimbOptions.climbed);
                        break;
                      case 1:
                        widget.onValueChanged(ClimbOptions.failed);
                        break;
                      case 2:
                        widget.onValueChanged(ClimbOptions.notAttempted);
                        break;
                      default:
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
