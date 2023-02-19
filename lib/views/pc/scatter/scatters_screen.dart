import "package:flutter/material.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/pc/scatter/scatter.dart";

//TODo: need to get some fake data to test it.

class ScattersScreen extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => DashboardScaffold(
        body: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: DashboardCard(
                  title: "Scatter",
                  body: Scatter(),
                ),
              ),
            ],
          ),
        ),
      );
}
