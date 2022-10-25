import "package:flutter/material.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/matches_provider.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/matches_search_box.dart";

class MatchSelectionFuture extends StatelessWidget {
  MatchSelectionFuture({
    required this.onChange,
    required this.controller,
    required this.matches,
  });

  final TextEditingController controller;
  final void Function(ScheduleMatch) onChange;
  final List<ScheduleMatch> matches;
  @override
  Widget build(final BuildContext context) {
    if (MatchesProvider.of(context).matches.isEmpty) {
      return Text("No matches found :(");
    } else {
      return MatchSearchBox(
        typeAheadController: controller,
        matches: matches,
        onChange: onChange,
      );
    }
  }
}
