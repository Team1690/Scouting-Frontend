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

class TeamInfoData<E extends num> extends StatefulWidget {
  TeamInfoData(this.team);
  final LightTeam team;

  @override
  _TeamInfoDataState<E> createState() => _TeamInfoDataState<E>();
}

class _TeamInfoDataState<E extends num> extends State<TeamInfoData<E>> {
  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<Team<E>>(
      future: fetchTeamInfo<E>(widget.team),
      builder: (
        final BuildContext context,
        final AsyncSnapshot<Team<E>> snapShot,
      ) {
        if (snapShot.hasError) {
          return Center(child: Text(snapShot.error.toString()));
        } else if (snapShot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return snapShot.data.mapNullable<Widget>(
              (final Team<E> data) => Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: QuickDataCard(data.quickData),
                        ),
                        SizedBox(height: defaultPadding),
                        Expanded(
                          flex: 6,
                          child: Gamechart<E>(data),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: defaultPadding),
                  Expanded(
                    flex: 2,
                    child: SpecificCard(data.specificData.msg),
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
}
