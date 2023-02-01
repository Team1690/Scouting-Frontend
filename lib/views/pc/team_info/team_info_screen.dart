import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_data.dart";

class TeamInfoScreen extends StatefulWidget {
  TeamInfoScreen({final LightTeam? initalTeam});
  @override
  State<TeamInfoScreen> createState() => _TeamInfoScreenState();
}

class _TeamInfoScreenState extends State<TeamInfoScreen> {
  final TextEditingController team = TextEditingController();
  @override
  Widget build(final BuildContext context) => DashboardScaffold(
        body: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: TeamSelectionFuture(
                      teams: TeamProvider.of(context).teams,
                      controller: team,
                      buildWithTeam:
                          (final BuildContext context, final LightTeam team) =>
                              Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("hi"),
                          SizedBox(height: defaultPadding),
                          TeamInfoData(team),
                        ],
                      )
                      //       Column(
                      // children: <Widget>[
                      //   SizedBox(width: defaultPadding),
                      //   Expanded(
                      //     flex: 2,
                      //     child: Container(),
                      //   ),
                      //   SizedBox(height: defaultPadding),
                      //   Expanded(
                      //     flex: 10,
                      //     child: TeamInfoData(team),
                      //   ),
                      // ],
                      // ),
                      ,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
