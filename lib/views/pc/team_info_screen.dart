import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/team_selection_future.dart";
import "package:scouting_frontend/views/pc/widgets/card.dart";
import "package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart";
import 'package:scouting_frontend/views/pc/widgets/team_info_data.dart';
import 'package:scouting_frontend/views/pc/widgets/team_info_data2.dart';

class TeamInfoScreen extends StatefulWidget {
  TeamInfoScreen({this.initalTeam});
  final TextEditingController controller = TextEditingController();
  final LightTeam? initalTeam;
  @override
  State<TeamInfoScreen> createState() => _TeamInfoScreenState(initalTeam);
}

class _TeamInfoScreenState extends State<TeamInfoScreen> {
  _TeamInfoScreenState(final LightTeam? team) {
    team.mapNullable((final LightTeam p0) => chosenTeam = team);
  }
  LightTeam? chosenTeam;
  @override
  Widget build(final BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: TeamSelectionFuture(
                    controller: widget.controller,
                    onChange: (final LightTeam newTeam) =>
                        setState(() => chosenTeam = newTeam),
                  ),
                ),
                SizedBox(width: defaultPadding),
                Expanded(
                  flex: 2,
                  child: ToggleButtons(
                    children: <Widget>[
                      Icon(Icons.shield_rounded),
                      Icon(Icons.remove_moderator_outlined),
                    ],
                    isSelected: <bool>[false, false],
                    onPressed: (final int index) {},
                  ),
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            Expanded(
              flex: 10,
              child: chosenTeam.mapNullable(
                    (final LightTeam team) => TeamInfoData(
                      team: team,
                    ),
                  ) ??
                  noTeamSelected(),
            ),
            TeamInfoDataNew(LightTeam(6, 1690, "Orbit"))
          ],
        ),
      ),
    );
  }
}

Widget noTeamSelected() {
  return DashboardCard(
    title: "",
    body: Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Icon(
            Icons.search,
            size: 100,
          ),
          SizedBox(height: defaultPadding),
          Text("Please choose a team in order to display data"),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    ),
  );
}
