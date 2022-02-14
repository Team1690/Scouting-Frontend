import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/specific/scouting_specific.dart";

class SpecificCard extends StatelessWidget {
  const SpecificCard(this.data);
  final SpecificData data;
  @override
  Widget build(final BuildContext context) {
    return DashboardCard(
      title: "Scouting Specific",
      body: ScoutingSpecific(
        msg: data,
      ),
    );
  }
}
