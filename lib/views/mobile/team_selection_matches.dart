import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/map_nullable.dart";
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
  Widget build(final BuildContext context) => TeamsSearchBox(
        buildSuggestion: match.mapNullable(
              (final ScheduleMatch match) => match.getTeamStationText,
            ) ??
            (final LightTeam team) => "Please Select A Match",
        teams: match.mapNullable(
              (final ScheduleMatch match) => match.getTeams(context),
            ) ??
            <LightTeam>[],
        dontValidate: dontValidate,
        buildWithTeam: buildWithTeam,
        onSelected: onSelected,
        buildWithoutTeam: buildWithoutTeam,
        initalTeam: initialTeam,
      );
}
