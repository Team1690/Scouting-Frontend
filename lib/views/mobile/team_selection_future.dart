import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/widgets/teams_search_box.dart";

class TeamSelectionFuture extends StatefulWidget {
  TeamSelectionFuture({
    this.onChange = ignore,
    required this.controller,
  });
  final TextEditingController controller;
  final void Function(LightTeam) onChange;
  @override
  State<TeamSelectionFuture> createState() => _TeamSelectionFutureState();
}

class _TeamSelectionFutureState extends State<TeamSelectionFuture> {
  @override
  Widget build(final BuildContext context) {
    if (TeamProvider.of(context).teams.isEmpty) {
      return Text("No teams available :(");
    } else {
      return TeamsSearchBox(
        typeAheadController: widget.controller,
        teams: TeamProvider.of(context).teams,
        onChange: (final LightTeam lightTeam) {
          setState(() {
            widget.onChange(lightTeam);
          });
        },
      );
    }
  }
}
