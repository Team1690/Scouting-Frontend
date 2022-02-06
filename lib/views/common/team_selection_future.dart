import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/teams_search_box.dart";

class TeamSelectionFuture extends StatelessWidget {
  TeamSelectionFuture({
    required this.onChange,
    required this.controller,
  });

  final TextEditingController controller;
  final void Function(LightTeam) onChange;

  @override
  Widget build(final BuildContext context) {
    if (TeamProvider.of(context).teams.isEmpty) {
      return Text("No teams available :(");
    } else {
      return TeamsSearchBox(
        typeAheadController: controller,
        teams: TeamProvider.of(context).teams,
        onChange: onChange,
      );
    }
  }
}
