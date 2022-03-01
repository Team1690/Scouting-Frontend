import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";

class FaultView extends StatefulWidget {
  @override
  State<FaultView> createState() => _FaultViewState();
}

class _FaultViewState extends State<FaultView> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      drawer: SideNavBar(),
      appBar: AppBar(
        title: Text("Robot faults"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<FaultTeam>>(
        future: fetchFaults(),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<FaultTeam>> snapshot,
        ) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return snapshot.data.mapNullable((final List<FaultTeam> data) {
                  return SingleChildScrollView(
                    primary: false,
                    child: Column(
                      children: data
                          .map(
                            (final FaultTeam e) => Card(
                              elevation: 2,
                              color: bgColor,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: defaultPadding / 4,
                                ),
                                child: ExpansionTile(
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor:
                                              Color.fromARGB(0, 0, 0, 0),
                                          content: Align(
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      );
                                      saveDeletedFaults(e.team.id)
                                          .then((final void value) {
                                        ScaffoldMessenger.of(context)
                                            .clearSnackBars();
                                        setState(() {});
                                      });
                                    },
                                  ),
                                  title: Text(
                                    "${e.team.number} ${e.team.name}",
                                  ),
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(e.faultMessage),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                }) ??
                (throw Exception("No data"));
          }
        },
      ),
    );
  }
}

const String mutation = """
mutation MyMutation(\$team: Int) {
  delete_broken_robots(where: {team_id: {_eq: \$team}}) {
    affected_rows
  }
}
""";

Future<void> saveDeletedFaults(final int teamID) async {
  final GraphQLClient client = getClient();
  await client.mutate(
    MutationOptions(
      document: gql(mutation),
      variables: <String, dynamic>{"team": teamID},
    ),
  );
}

Future<List<FaultTeam>> fetchFaults() async {
  final GraphQLClient client = getClient();
  final QueryResult result =
      await client.query(QueryOptions(document: gql(query)));
  return result.mapQueryResult(
    (final Map<String, dynamic>? data) =>
        data.mapNullable<List<FaultTeam>>(
          (final Map<String, dynamic> data) {
            return (data["broken_robots"] as List<dynamic>)
                .map(
                  (final dynamic e) => FaultTeam(
                    e["message"] as String,
                    LightTeam(
                      e["team"]["id"] as int,
                      e["team"]["number"] as int,
                      e["team"]["name"] as String,
                      e["team"]["colors_index"] as int,
                    ),
                  ),
                )
                .toList();
          },
        ) ??
        (throw Exception("No data")),
  );
}

class FaultTeam {
  const FaultTeam(this.faultMessage, this.team);
  final String faultMessage;
  final LightTeam team;
}

const String saveMutation = """
mutation MyMutation(\$teams: [Int!]) {
  delete_broken_robots(where: {team_id: {_in: \$teams}}) {
    affected_rows
  }
}
""";

const String query = """
query MyQuery {
  broken_robots {
    team {
      colors_index
      name
      number
      id
    }
    message
  }
}

""";
