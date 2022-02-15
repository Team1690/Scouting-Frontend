import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/fault_view_list.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";

class FaultView extends StatefulWidget {
  @override
  State<FaultView> createState() => _FaultViewState();
}

class _FaultViewState extends State<FaultView> {
  final Map<int, bool> teamIdToState = <int, bool>{};
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      drawer: SideNavBar(),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Color.fromARGB(0, 0, 0, 0),
                  content: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
              saveDeletedFaults(
                teamIdToState.entries
                    .where(
                      (final MapEntry<int, bool> element) => element.value,
                    )
                    .map((final MapEntry<int, bool> e) => e.key)
                    .toList(),
              ).then((final void value) {
                ScaffoldMessenger.of(context).clearSnackBars();
                setState(() {});
              });
            },
            icon: Icon(Icons.save),
          )
        ],
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
                  teamIdToState.addEntries(
                    data.map(
                      (final FaultTeam e) =>
                          MapEntry<int, bool>(e.team.id, false),
                    ),
                  );
                  return FaultViewList(data,
                      (final int teamId, final bool value) {
                    teamIdToState[teamId] = value;
                  });
                }) ??
                (throw Exception("No data"));
          }
        },
      ),
    );
  }
}

const String mutation = """
mutation MyMutation(\$teams: [Int!]) {
  delete_broken_robots(where: {team_id: {_in: \$teams}}) {
    affected_rows
  }
}
""";

Future<void> saveDeletedFaults(final List<int> teamIds) async {
  final GraphQLClient client = getClient();
  if (teamIds.isEmpty) return;
  await client.mutate(
    MutationOptions(
      document: gql(mutation),
      variables: <String, dynamic>{"teams": teamIds},
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
