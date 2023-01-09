import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/teams_search_box.dart";

class TeamSelectionMatches extends StatelessWidget {
  TeamSelectionMatches({
    required this.match,
    this.dontValidate = false,
    required this.controller,
    required this.onChange,
  });
  final ScheduleMatch? match;
  final bool dontValidate;
  final void Function(LightTeam) onChange;
  final TextEditingController controller;

  @override
  Widget build(final BuildContext context) {
    final bool isNotOfficial = match == null ||
        match!.matchTypeId ==
            IdProvider.of(context).matchType.nameToId["Practice"]! ||
        match!.matchTypeId ==
            IdProvider.of(context).matchType.nameToId["Pre scouting"]!;
    return TeamsSearchBox(
      buildSuggestion: (final LightTeam p0) => isNotOfficial
          ? "${p0.number} ${p0.name}"
          : match!.getTeamStation(p0)!,
      teams: isNotOfficial
          ? TeamProvider.of(context).teams
          : <LightTeam>[...match!.blueAlliance, ...match!.redAlliance],
      typeAheadController: controller,
      dontValidate: dontValidate,
      onChange: onChange,
    );
  }
}
