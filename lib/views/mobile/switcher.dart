import "package:flutter/material.dart";

class Switcher extends StatefulWidget {
  Switcher({
    required final this.labels,
    required final this.colors,
    required this.onChange,
    final this.height = 70,
  });

  final List<String> labels;
  final List<Color> colors;
  final Function(int) onChange;
  final double height;

  @override
  State<Switcher> createState() => _SwitcherState();
}

class _SwitcherState extends State<Switcher> {
  int selected = -1;
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
        children: <Widget>[
          for (int i = 0; i < widget.labels.length; i++)
            Expanded(
              child: SizedBox(
                height: widget.height,
                child: TextButton(
                  child: Text(
                    widget.labels[i],
                    style: TextStyle(
                      fontSize: 15,
                      color: selected == i ? widget.colors[i] : Colors.black,
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      getBorder(i),
                    ),
                    overlayColor: MaterialStateColor.resolveWith(
                      (final Set<MaterialState> states) =>
                          selected == i ? widget.colors[i] : Colors.grey,
                    ),
                  ),
                  onPressed: () => setState(() {
                    i = i == selected ? -1 : i;
                    widget.onChange(i);
                    selected = i;
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
