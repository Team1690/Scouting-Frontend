import 'package:flutter/material.dart';

class Switcher extends StatefulWidget {
  final List<String> labels;
  final List<Color> colors;
  final Function(int)? onChange;
  final double height;
  int? selected;

  Switcher({
    required final this.labels,
    required final this.colors,
    final this.height = 70,
    final this.onChange,
  });
  @override
  State<Switcher> createState() => _SwitcherState();
}

class _SwitcherState extends State<Switcher> {
  RoundedRectangleBorder getBorder(final int index) {
    return RoundedRectangleBorder(
      borderRadius: index == 0
          ? BorderRadius.horizontal(
              left: Radius.circular(20),
            )
          : index == widget.labels.length - 1
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
                    style: const TextStyle(fontSize: 15),
                  ),
                  textColor:
                      widget.selected == i ? widget.colors[i] : Colors.black,
                  splashColor:
                      widget.selected == i ? widget.colors[i] : Colors.grey,
                  shape: getBorder(i),
                  onPressed: () => setState(() {
                    i = i == widget.selected ? -1 : i;
                    widget.onChange?.call(i);
                    widget.selected = i;
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
