import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";

class NoTeamSelected extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => DashboardCard(
        title: "",
        body: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Icon(
                Icons.search,
                size: 100,
              ),
              SizedBox(height: defaultPadding),
              Text("Please choose a team in order to display data"),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
      );
}
