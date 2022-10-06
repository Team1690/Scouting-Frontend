import "package:flutter/material.dart";
import "package:scouting_frontend/models/matches_model.dart";

class MatchesProvider extends InheritedWidget {
  MatchesProvider({
    required super.child,
    required this.matches,
  });
  final List<ScheduleMatch> matches;
  @override
  bool updateShouldNotify(final MatchesProvider oldWidget) =>
      matches != oldWidget.matches;

  static MatchesProvider of(final BuildContext context) {
    final MatchesProvider? result =
        context.dependOnInheritedWidgetOfExactType<MatchesProvider>();
    assert(result != null, "No ScheduleMatches found in context");
    return result!;
  }
}
