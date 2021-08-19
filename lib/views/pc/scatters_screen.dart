import 'package:flutter/material.dart';
import 'package:scouting_frontend/net/get_teams_api.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/scatter.dart';

//TODO: need to get some fake data to test it.

class ScattersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Scatter(
          teams: GetTeamsApi.teamsList,
        ),
      ),
    );
  }
}
