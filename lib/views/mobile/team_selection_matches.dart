import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/teams_search_box.dart";

class TeamSelectionMatches extends StatelessWidget {
  TeamSelectionMatches({
    required this.match,
    this.dontValidate = false,
    required this.buildWithTeam,
    this.onSelected,
    this.buildWithoutTeam,
    this.initialTeam,
  });
  final LightTeam? initialTeam;
  final ScheduleMatch? match;
  final bool dontValidate;
  final void Function(LightTeam)? onSelected;
  final Widget Function(
    BuildContext,
    LightTeam,
    Widget searchBox,
    void Function(),
  ) buildWithTeam;
  final Widget Function(Widget, void Function())? buildWithoutTeam;

  @override
  Widget build(final BuildContext context) {
    final Map<String, int> provider = IdProvider.of(context).matchType.nameToId;
    final bool isUnofficial = <int>[
      provider["Practice"]!,
      provider["Pre scouting"]!
    ].contains(match?.matchTypeId);
    return TeamsSearchBox(
      buildSuggestion: (final LightTeam p0) => match!.getTeamStation(p0)!,
      teams: match == null
          ? <LightTeam>[]
          : isUnofficial
              ? TeamProvider.of(context).teams
              : <LightTeam>[...match!.blueAlliance, ...match!.redAlliance],
      dontValidate: dontValidate,
      buildWithTeam: buildWithTeam,
      onSelected: onSelected,
      buildWithoutTeam: buildWithoutTeam,
      initalTeam: initialTeam,
    );
  }
}
