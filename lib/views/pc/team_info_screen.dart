import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/team_selection_future.dart";
import "package:scouting_frontend/views/pc/widgets/card.dart";
import "package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart";

class TeamInfoScreen extends StatefulWidget {
  TeamInfoScreen({this.chosenTeam}) {
    if (chosenTeam != null) {
      controller.text = chosenTeam!.number.toString();
    }
  }
  final TextEditingController controller = TextEditingController();
  LightTeam? chosenTeam;
  @override
  State<TeamInfoScreen> createState() => _TeamInfoScreenState();
}

class _TeamInfoScreenState extends State<TeamInfoScreen> {
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
                        setState(() => widget.chosenTeam = newTeam),
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
              child: widget.chosenTeam.mapNullable(
                    (final LightTeam team) => TeamInfoScreen(chosenTeam: team),
                  ) ??
                  noTeamSelected(),
            )
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
