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
  Widget build(final BuildContext context) => DashboardScaffold(
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
                        const ChangeMatch()),
                  ));
                },
                icon: const Icon(Icons.add_circle_outline_outlined),
              ),
            ],
            body: StreamBuilder<List<ScheduleMatch>>(
              stream: fetchMatchesSubscription(),
              builder: (
                final BuildContext context,
                final AsyncSnapshot<List<ScheduleMatch>> snapshot,
              ) =>
                  snapshot.mapSnapshot(
                onWaiting: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                onError: (final Object error) => Text(error.toString()),
                onNoData: () => const Center(
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
                                ...e.blueAlliance.map(
                                  (final LightTeam currentTeam) => Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute<TeamInfoScreen>(
                                          builder: (
                                            final BuildContext context,
                                          ) =>
                                              TeamInfoScreen(
                                            initalTeam: currentTeam,
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
                                        currentTeam.number.toString(),
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ...e.redAlliance.map(
                                  (final LightTeam currentTeam) => Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute<TeamInfoScreen>(
                                          builder:
                                              (final BuildContext context) =>
                                                  TeamInfoScreen(
                                            initalTeam: currentTeam,
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
                                        currentTeam.number.toString(),
                                        style:
                                            const TextStyle(color: Colors.red),
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
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
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
                                            ),
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
                                        variables: <String, dynamic>{
                                          "id": e.id,
                                        },
                                      ),
                                    );
                                    if (result.hasException) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 5),
                                          content: Text(
                                            "Error: ${result.exception}",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
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
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.delete),
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

const String mutation = """mutation DeleteMatch(\$id: Int!){
  delete_matches_by_pk(id: \$id){
  	id
  }
}""";
