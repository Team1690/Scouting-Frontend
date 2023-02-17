import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/team_info/models/fetch_team_info.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/gamechart/gamechart_card.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/pit/pit_scouting.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/quick_data/quick_data.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/specific/specific_card.dart";

class TeamInfoData extends StatelessWidget {
  TeamInfoData(this.team);
  final LightTeam team;

  @override
  Widget build(final BuildContext context) => FutureBuilder<Team>(
        future: fetchTeamInfo(team, context),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<Team> snapShot,
        ) {
          if (snapShot.hasError) {
            return Center(child: Text(snapShot.error.toString()));
          } else if (snapShot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return snapShot.data.mapNullable<Widget>(
                (final Team data) => Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: QuickDataCard(data.quickData),
                          ),
                          SizedBox(height: defaultPadding),
                          Expanded(
                            flex: 6,
                            child: Gamechart(data),
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: defaultPadding),
                    Expanded(
                      flex: 2,
                      child: SpecificCard(data.specificData),
                    ),
                    SizedBox(
                      width: defaultPadding,
                    ),
                    Expanded(
                      flex: 2,
                      child: PitScouting(data.pitViewData),
                    ),
                  ],
                ),
              ) ??
              Text("No data available");
        },
      );
}
