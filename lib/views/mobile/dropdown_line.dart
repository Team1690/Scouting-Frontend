import "package:flutter/material.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";

class DropdownLine<T> extends StatelessWidget {
  DropdownLine({
    required this.onChange,
    required this.controller,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final T? value;
  final void Function() onTap;
  final void Function(String) onChange;
  final TextEditingController controller;

  @override
  Widget build(final BuildContext context) => Column(
        children: <Widget>[
          GestureDetector(
            onTap: onTap,
            child: SectionDivider(label: label),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: value == null
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Container(),
            secondChild: Column(
              children: <Widget>[
                TextField(
                  controller: controller,
                  textDirection: TextDirection.rtl,
                  onChanged: onChange,
                  decoration: InputDecoration(hintText: label),
                ),
              ],
            ),
          ),
        ],
      );
}
