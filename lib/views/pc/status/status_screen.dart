import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/pc/status/fetch_status.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class StatusScreen extends StatefulWidget {
  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool isSpecific = false;
  @override
  Widget build(final BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: DashboardCard(
          titleWidgets: <Widget>[
            IconButton(
              tooltip: "Matches",
              onPressed: () {
                if (isSpecific == false) return;
                setState(() {
                  isSpecific = false;
                });
              },
              icon: Icon(Icons.error_outline),
            ),
            IconButton(
              tooltip: "Specific",
              onPressed: () {
                if (isSpecific == true) return;
                setState(() {
                  isSpecific = true;
                });
              },
              icon: Icon(Icons.search),
            ),
            Text(isSpecific ? "Specific" : "Techincal")
          ],
          title: "Status",
          body: StreamBuilder<List<MatchReceived>>(
            stream: fetchStatus(isSpecific),
            builder: (
              final BuildContext context,
              final AsyncSnapshot<List<MatchReceived>> snapshot,
            ) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return snapshot.data.mapNullable(
                    (final List<MatchReceived> matches) =>
                        SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      primary: false,
                      child: Column(
                        children: matches.reversed
                            .map(
                              (final MatchReceived e) => Card(
                                color: e.matches.length != 6
                                    ? Colors.red
                                    : bgColor,
                                elevation: 2,
                                margin: EdgeInsets.fromLTRB(
                                  5,
                                  0,
                                  5,
                                  defaultPadding,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    defaultPadding,
                                    defaultPadding / 4,
                                    defaultPadding,
                                    defaultPadding / 4,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      defaultPadding / 2,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "${e.identifier.isRematch ? "Re " : ""}${e.identifier.type} ${e.identifier.number}",
                                        ),
                                        ...e.matches
                                            .map(
                                              (
                                                final Match match,
                                              ) =>
                                                  Container(
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
                                                  borderRadius:
                                                      defaultBorderRadius / 2,
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      match.team.number
                                                          .toString(),
                                                    ),
                                                    if (e.matches.length != 6)
                                                      Text(match.scouter)
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ) ??
                  (throw Exception());
            },
          ),
        ),
      ),
    );
  }
}

class MatchReceived {
  MatchReceived({
    required final List<Match> matches,
    required final MatchIdentifier identifier,
  }) : this._inner(
          identifier,
          matches
            ..sort(
              ((final Match a, final Match b) =>
                  a.team.number.compareTo(b.team.number)),
            ),
        );
  MatchReceived._inner(this.identifier, this.matches);
  final MatchIdentifier identifier;
  final List<Match> matches;
}

class Match {
  const Match({required this.scouter, required this.team});
  final LightTeam team;
  final String scouter;
}
