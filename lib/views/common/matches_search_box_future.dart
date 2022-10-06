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
    required this.team,
  });

  final TextEditingController controller;
  final void Function(ScheduleMatch) onChange;
  final List<ScheduleMatch> matches;
  final LightTeam? team;
  @override
  Widget build(final BuildContext context) {
    if (team == null) {
      return Text("No team selected :(");
    }
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
