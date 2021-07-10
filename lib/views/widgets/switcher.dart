import 'package:flutter/material.dart';

class Switcher extends StatelessWidget {
  final List<String> labels;
  final List<Color> colors;
  final Function(int) onChange;
  final double height;
  final int selected;

  Switcher({
    @required final this.labels,
    @required final this.colors,
    @required final this.selected,
    final this.height = 70,
    final this.onChange,
  });

  RoundedRectangleBorder getBorder(final int index) {
    return RoundedRectangleBorder(
      borderRadius: index == 0
          ? BorderRadius.horizontal(
              left: Radius.circular(20),
            )
          : index == labels.length - 1
              ? BorderRadius.horizontal(
                  right: Radius.circular(20),
                )
              : BorderRadius.zero,
    );
  }

  @override
  Widget build(final BuildContext context) {
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
                    style: const TextStyle(fontSize: 15),
                  ),
                  textColor: selected == i ? colors[i] : Colors.black,
                  splashColor: selected == i ? colors[i] : Colors.grey,
                  shape: getBorder(i),
                  onPressed: () => this.onChange(i),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
