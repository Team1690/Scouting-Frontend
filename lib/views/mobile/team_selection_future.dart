import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_helpers.dart";
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
    return Builder(
      builder: (
        final BuildContext context,
      ) {
        if (TeamHelper.teams.isEmpty) {
          return Text("No teams available :(");
        } else {
          return TeamsSearchBox(
            typeAheadController: widget.controller,
            teams: TeamHelper.teams,
            onChange: (final LightTeam LightTeam) {
              setState(() {
                widget.onChange(LightTeam);
              });
            },
          );
        }
      },
    );
  }
}
