import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/common/no_team_selected.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_data.dart";
import "package:orbit_standard_library/orbit_standard_library.dart";

class TeamInfoScreen extends StatefulWidget {
  TeamInfoScreen({this.initalTeam});
  final TextEditingController controller = TextEditingController();
  final LightTeam? initalTeam;
  @override
  State<TeamInfoScreen> createState() => _TeamInfoScreenState(initalTeam);
}

class _TeamInfoScreenState extends State<TeamInfoScreen> {
  _TeamInfoScreenState(final LightTeam? team) {
    team.mapNullable((final LightTeam p0) {
      chosenTeam = team;
    });
  }
  LightTeam? chosenTeam;
  @override
  void initState() {
    super.initState();
    chosenTeam.mapNullable((final LightTeam element) {
      widget.controller.text = "${element.number} ${element.name}";
    });
  }

  @override
  Widget build(final BuildContext context) => DashboardScaffold(
        body: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: TeamSelectionFuture(
                      teams: TeamProvider.of(context).teams,
                      controller: widget.controller,
                      onChange: (final LightTeam newTeam) =>
                          setState(() => chosenTeam = newTeam),
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  Expanded(
                    flex: 2,
                    child: Container(),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Expanded(
                flex: 10,
                child: chosenTeam.mapNullable(
                      TeamInfoData.new,
                    ) ??
                    NoTeamSelected(),
              ),
            ],
          ),
        ),
      );
}
