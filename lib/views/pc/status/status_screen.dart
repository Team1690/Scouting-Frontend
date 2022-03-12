import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";

class StatusScreen extends StatelessWidget {
  final List<MatchReceived> matches = List.generate(
      50,
      (index) => MatchReceived(
            teams: [
              LightTeam(1, 1690, "ORBIT", 2),
              LightTeam(1, 1690, "ORBIT", 2),
              LightTeam(1, 1577, "ORBIT", 2),
              LightTeam(1, 1690, "ORBIT", 2),
              LightTeam(1, 1690, "ORBIT", 2),
              LightTeam(1, 1690, "ORBIT", 2),
            ],
            receivedMatch: [false, true, true, false, false, true],
          ));

  @override
  Widget build(final BuildContext context) {
    return DashboardScaffold(
      body: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: DashboardCard(
            title: "Status",
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              primary: false,
              child: Column(
                children: matches
                    .map((e) => Card(
                        color: bgColor,
                        elevation: 2,
                        margin: EdgeInsets.fromLTRB(5, 0, 5, defaultPadding),
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(
                              defaultPadding,
                              defaultPadding / 4,
                              defaultPadding,
                              defaultPadding / 4,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(defaultPadding / 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Quals #3'),
                                  ...e.teams
                                      .asMap()
                                      .entries
                                      .map(
                                        (team) => Container(
                                          width: 80,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(
                                            defaultPadding / 3,
                                          ),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                color: primaryWhite,
                                                width: 1,
                                              ),
                                              color: e.receivedMatch[team.key]
                                                  ? Colors.green
                                                  : null,
                                              borderRadius:
                                                  defaultBorderRadius / 2),
                                          child: Text(
                                              team.value.number.toString()),
                                        ),
                                      )
                                      .toList()
                                ],
                              ),
                            ))))
                    .toList(),
              ),
            ),
          )),
    );
  }
}

class MatchReceived {
  MatchReceived({
    required this.teams,
    required this.receivedMatch,
  });

  final List<LightTeam> teams;
  final List<bool> receivedMatch;
}
