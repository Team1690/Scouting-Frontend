import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/teams_search_box.dart";

class TeamSelectionFuture extends StatelessWidget {
  TeamSelectionFuture({
    this.teams,
    required this.buildWithTeam,
    this.dontValidate = false,
    this.buildWithoutTeam,
    this.onSelected,
  });
  final void Function(LightTeam)? onSelected;
  final bool dontValidate;
  final List<LightTeam>? teams;
  final Widget Function(
    BuildContext,
    LightTeam,
    Widget searchBox,
    void Function() resetSearchBox,
  ) buildWithTeam;
  final Widget Function(
    Widget searchBox,
    void Function() resetSearchBox,
  )? buildWithoutTeam;

  @override
  Widget build(final BuildContext context) {
    if (TeamProvider.of(context).teams.isEmpty) {
      return Text("No teams available :(");
    } else {
      return TeamsSearchBox(
        buildSuggestion: (final LightTeam p0) => "${p0.number} ${p0.name}",
        dontValidate: dontValidate,
        teams: teams ?? TeamProvider.of(context).teams,
        buildWithTeam: buildWithTeam,
        buildWithoutTeam: buildWithoutTeam,
        onSelected: onSelected,
      );
    }
  }
}
