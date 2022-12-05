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
    return TeamsSearchBox(
      suggestionBuilder: (final LightTeam p0) {
        final ScheduleMatch? match = this.match;
        if (match == null) return "No match schedule";
        if (match.matchTypeId ==
            IdProvider.of(context).matchType.nameToId["Practice"]!) {
          return "${p0.number} ${p0.name}";
        }
        if (p0.id == match.blue0.id) return "blue1 ${p0.number} ${p0.name}";
        if (p0.id == match.blue1.id) return "blue2 ${p0.number} ${p0.name}";
        if (p0.id == match.blue2.id) return "blue3 ${p0.number} ${p0.name}";
        if (p0.id == match.red0.id) return "red1 ${p0.number} ${p0.name}";
        if (p0.id == match.red1.id) return "red2 ${p0.number} ${p0.name}";
        if (p0.id == match.red2.id) return "red3 ${p0.number} ${p0.name}";
        if (p0.id == match.blue3?.id) return "blue4 ${p0.number} ${p0.name}";
        if (p0.id == match.red3?.id) return "red4 ${p0.number} ${p0.name}";
        throw Exception("team not in match");
      },
      teams: match == null
          ? <LightTeam>[]
          : match!.matchTypeId ==
                  IdProvider.of(context).matchType.nameToId["Practice"]!
              ? TeamProvider.of(context).teams
              : <LightTeam?>[
                  match!.blue0,
                  match!.blue1,
                  match!.blue2,
                  match!.blue3,
                  match!.red0,
                  match!.red1,
                  match!.red2,
                  match!.red3
                ].whereType<LightTeam>().toList(),
      typeAheadController: controller,
      dontValidate: dontValidate,
      onChange: onChange,
    );
  }
}
