import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/fetch_matches.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/matches/change_match.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_screen.dart";

class MatchesScreen extends StatelessWidget {
  const MatchesScreen();

  @override
  Widget build(final BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: DashboardCard(
          title: "Matches",
          titleWidgets: <Widget>[
            IconButton(
              onPressed: () async {
                (await showDialog<ScheduleMatch>(
                  context: context,
                  builder: ((final BuildContext dialogContext) =>
                      ChangeMatch()),
                ));
              },
              icon: Icon(Icons.add_circle_outline_outlined),
            ),
          ],
          body: StreamBuilder<List<ScheduleMatch>>(
            stream: fetchMatchesSubscription(),
            builder: (
              final BuildContext context,
              final AsyncSnapshot<List<ScheduleMatch>> snapshot,
            ) =>
                snapshot.mapSnapshot(
              onWaiting: () => Center(
                child: CircularProgressIndicator(),
              ),
              onError: (final Object error) => Text(error.toString()),
              onNoData: () => Center(
                child: Text("No data"),
              ),
              onSuccess: (final List<ScheduleMatch> data) => ListView(
                children: data
                    .map(
                      (final ScheduleMatch e) => Card(
                        color: bgColor,
                        child: ListTile(
                          title: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  style: TextStyle(
                                    color: e.happened
                                        ? Colors.green
                                        : Colors.white,
                                  ),
                                  "${IdProvider.of(context).matchType.idToName[e.matchTypeId]} ${e.matchNumber}",
                                ),
                              ),
                              ...<LightTeam?>[
                                e.blue0,
                                e.blue1,
                                e.blue2,
                                e.blue3
                              ]
                                  .whereType<LightTeam>()
                                  .map(
                                    (final LightTeam e) => Expanded(
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute<TeamInfoScreen>(
                                            builder:
                                                (final BuildContext context) =>
                                                    TeamInfoScreen(
                                              initalTeam: e,
                                            ),
                                          ),
                                        ),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                            secondaryColor,
                                          ),
                                        ),
                                        child: Text(
                                          e.number.toString(),
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              ...<LightTeam?>[e.red0, e.red1, e.red2, e.red3]
                                  .whereType<LightTeam>()
                                  .map(
                                    (final LightTeam e) => Expanded(
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute<TeamInfoScreen>(
                                            builder:
                                                (final BuildContext context) =>
                                                    TeamInfoScreen(
                                              initalTeam: e,
                                            ),
                                          ),
                                        ),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                            secondaryColor,
                                          ),
                                        ),
                                        child: Text(
                                          e.number.toString(),
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ),
                              IconButton(
                                onPressed: () async {
                                  (await showDialog<ScheduleMatch>(
                                    context: context,
                                    builder:
                                        (final BuildContext dialogContext) =>
                                            ChangeMatch(
                                      e,
                                    ),
                                  ));
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: Duration(seconds: 5),
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Deleting",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                  final GraphQLClient client = getClient();

                                  final QueryResult<void> result =
                                      await client.mutate(
                                    MutationOptions<void>(
                                      document: gql(mutation),
                                      variables: <String, dynamic>{"id": e.id},
                                    ),
                                  );
                                  if (result.hasException) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(seconds: 5),
                                        content:
                                            Text("Error: ${result.exception}"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(seconds: 2),
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              "Saved",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final String mutation = """mutation DeleteMatch(\$id: Int!){
  delete_matches_by_pk(id: \$id){
  	id
  }
}""";
