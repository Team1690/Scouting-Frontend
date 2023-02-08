import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";

class NoTeamSelected extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => DashboardCard(
        title: "",
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.search,
                size: 100,
              ),
              SizedBox(height: defaultPadding),
              Text("Please choose a team in order to display data"),
            ],
          ),
        ),
      );
}
