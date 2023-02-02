import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/common/no_team_selected.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_data.dart";
import "package:scouting_frontend/models/map_nullable.dart";

class TeamInfoScreen extends StatelessWidget {
  TeamInfoScreen({this.initalTeam});

  final LightTeam? initalTeam;

  @override
  Widget build(final BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: TeamSelectionFuture(
          teams: TeamProvider.of(context).teams,
          buildWithoutTeam: (final Widget searchBox, final _) => Align(
            alignment: Alignment.topCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: searchBox,
                ),
                Expanded(
                  flex: 2,
                  child: Container(),
                )
              ],
            ),
          ),
          buildWithTeam: (
            final BuildContext context,
            final LightTeam team,
            final Widget searchBox,
            final _,
          ) =>
              Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(flex: 1, child: searchBox),
                  SizedBox(width: defaultPadding),
                  Expanded(
                    flex: 2,
                    child: Container(),
                  ),
                ],
              ),
              SizedBox(height: defaultPadding),
              Expanded(
                flex: 10,
                child: team.mapNullable(
                      TeamInfoData.new,
                    ) ??
                    NoTeamSelected(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
