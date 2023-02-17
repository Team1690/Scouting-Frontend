import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/teams_search_box.dart";

class TeamSelectionFuture extends StatelessWidget {
  TeamSelectionFuture({
    this.teams,
    required this.onChange,
    required this.controller,
    this.dontValidate = false,
  });
  final bool dontValidate;
  final List<LightTeam>? teams;
  final TextEditingController controller;
  final void Function(LightTeam) onChange;

  @override
  Widget build(final BuildContext context) {
    if (TeamProvider.of(context).teams.isEmpty) {
      return const Text("No teams available :(");
    } else {
      return TeamsSearchBox(
        buildSuggestion: (final LightTeam p0) => "${p0.number} ${p0.name}",
        dontValidate: dontValidate,
        typeAheadController: controller,
        teams: teams ?? TeamProvider.of(context).teams,
        onChange: onChange,
      );
    }
  }
}
