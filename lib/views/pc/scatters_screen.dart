import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/widgets/card.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';
import 'package:scouting_frontend/views/pc/widgets/scatter.dart';

//TODO: need to get some fake data to test it.

class ScattersScreen extends StatefulWidget {
  @override
  State<ScattersScreen> createState() => _ScattersScreenState();
}

class _ScattersScreenState extends State<ScattersScreen> {
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
                    onHover: identity,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
