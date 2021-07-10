import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/match_model.dart';

class Switcher extends StatelessWidget {
  final List<String> labels;
  final List<Color> colors;
  final Function(String, bool) onChange;
  final double height;
  final int selected;

  Switcher({
    @required final this.labels,
    @required final this.colors,
    @required final this.selected,
    final this.height = 70,
    final this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      width: MediaQuery.of(context).size.width,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: SizedBox(
                height: height,
                child: FlatButton(
                  child: Text(
                    labels[i],
                    style: TextStyle(fontSize: 15),
                  ),
                  textColor: _pressed[i] ? colors[i] : Colors.black,
                  splashColor: !_pressed[i] ? colors[i] : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: i == 0
                        ? BorderRadius.horizontal(
                            left: Radius.circular(20),
                          )
                        : i == labels.length - 1
                            ? BorderRadius.horizontal(
                                right: Radius.circular(20),
                              )
                            : BorderRadius.zero,
                  ),
                  onPressed: () {},
                ),
              ),
            ),
        ],
      ),
    );
  }
}
