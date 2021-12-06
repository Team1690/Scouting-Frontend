import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_line_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/radar_chart.dart';
import 'package:scouting_frontend/views/pc/widgets/scatter.dart';

//TODO: need to get some fake data to test it.

class ScattersScreen extends StatefulWidget {
  @override
  State<ScattersScreen> createState() => _ScattersScreenState();
}

class _ScattersScreenState extends State<ScattersScreen> {
  Team displayTeam;

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Row(
          children: [
            Expanded(
                flex: 4,
                child: DashboardCard(
                  title: 'Scatter',
                  body: Scatter(
                    teams: widget.teams,
                    onHover: (Team team) => setState(() => displayTeam = team),
                  )),
            ),

          ],
        ),
      ),
    );
  }
}
