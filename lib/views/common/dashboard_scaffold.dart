import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:scouting_frontend/views/pc/compare/compare_screen.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_screen.dart";
import "package:scouting_frontend/views/pc/scatter/scatters_screen.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_screen.dart";

import "package:scouting_frontend/views/common/navigation_tab.dart";

class DashboardScaffold extends StatelessWidget {
  DashboardScaffold({
    required this.body,
  });

  final Widget body;

  @override
  Widget build(final BuildContext context) => RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: (final RawKeyEvent event) {
          keyboardShortcut<TeamInfoScreen>(
            context,
            event,
            TeamInfoScreen(),
            (final RawKeyEvent event) =>
                event.isControlPressed &&
                event.physicalKey == PhysicalKeyboardKey.keyM &&
                event.runtimeType == RawKeyDownEvent,
          );

          keyboardShortcut<PickListScreen>(
            context,
            event,
            PickListScreen(),
            (final RawKeyEvent event) =>
                event.isControlPressed &&
                event.physicalKey == PhysicalKeyboardKey.comma &&
                event.runtimeType == RawKeyDownEvent,
          );

          keyboardShortcut<CompareScreen>(
            context,
            event,
            CompareScreen(),
            (final RawKeyEvent event) =>
                event.isControlPressed &&
                event.physicalKey == PhysicalKeyboardKey.period &&
                event.runtimeType == RawKeyDownEvent,
          );

          keyboardShortcut<ScattersScreen>(
            context,
            event,
            ScattersScreen(),
            (final RawKeyEvent event) =>
                event.isControlPressed &&
                event.physicalKey == PhysicalKeyboardKey.slash &&
                event.runtimeType == RawKeyDownEvent,
          );
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          // appBar: AppBar(title: Text('Orbit Scouting')),
          body: SafeArea(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: NavigationTab(),
                ),
                Expanded(flex: 5, child: body),
              ],
            ),
          ),
        ),
      );
}

void keyboardShortcut<E extends Widget>(
  final BuildContext context,
  final RawKeyEvent event,
  final E widget,
  final bool Function(RawKeyEvent) predicate,
) {
  if (predicate(event)) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<E>(
        builder: (final BuildContext context) => widget,
      ),
    );
  }
}
