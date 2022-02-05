import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/pit/pit_scouting_card.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/pit/robot_image_card.dart";

class PitScouting extends StatelessWidget {
  const PitScouting(this.p0);

  final PitData? p0;

  @override
  Widget build(final BuildContext context) {
    return p0.mapNullable(
          (final PitData p0) => Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: RobotImageCard(p0.url),
              ),
              SizedBox(
                height: defaultPadding,
              ),
              Expanded(
                flex: 6,
                child: PitScoutingCard(p0),
              ),
            ],
          ),
        ) ??
        Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: DashboardCard(
                title: "Robot Image",
                body: Container(),
              ),
            ),
            SizedBox(
              height: defaultPadding,
            ),
            Expanded(
              flex: 6,
              child: DashboardCard(
                title: "Pit Scouting",
                body: Container(),
              ),
            ),
          ],
        );
  }
}
