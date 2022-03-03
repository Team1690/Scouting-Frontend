import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
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
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              LightTeam? team;
              String? newMessage;
              (await showDialog<FaultTeam>(
                context: context,
                builder: (final BuildContext innerContext) {
                  return AlertDialog(
                    title: Text("Add team"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TeamSelectionFuture(
                          onChange: (final LightTeam newTeam) {
                            team = newTeam;
                          },
                          controller: TextEditingController(),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          textDirection: TextDirection.rtl,
                          onChanged: (final String a) {
                            newMessage = a;
                          },
                          decoration: InputDecoration(
                            hintText: "Error message",
                            border: OutlineInputBorder(),
                          ),
                        )
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          if (team == null || newMessage == null) return;
                          Navigator.of(context)
                              .pop(FaultTeam(newMessage!, team!));
                        },
                        child: Text("Submit"),
                      ),
                      TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              ))
                  .mapNullable((final FaultTeam p0) {
                showLoadingSnackBar(context);
                addFaultTeam(p0.team.id, p0.faultMessage).then((final void _) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  setState(() {});
                });
              });
            },
            icon: Icon(Icons.add),
          )
        ],
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
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () async {
                                          final TextEditingController
                                              controller =
                                              TextEditingController();

                                          (await showDialog<String>(
                                            context: context,
                                            builder:
                                                (final BuildContext context) =>
                                                    AlertDialog(
                                              title: Text("Edit message"),
                                              content: TextField(
                                                controller: controller,
                                                autofocus: true,
                                                textDirection:
                                                    TextDirection.rtl,
                                                decoration: InputDecoration(
                                                  hintText: "Error message",
                                                ),
                                              ),
                                              actions: <TextButton>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop<String>(
                                                      controller.text,
                                                    );
                                                  },
                                                  child: Text(
                                                    "Submit",
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      Navigator.of(context).pop,
                                                  child: Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ))
                                              .mapNullable((
                                            final String message,
                                          ) {
                                            showLoadingSnackBar(context);

                                            updateFaultMessage(
                                              e.team.id,
                                              message,
                                            ).then((final void _) {
                                              setState(() {});
                                              ScaffoldMessenger.of(context)
                                                  .clearSnackBars();
                                            });
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          showLoadingSnackBar(context);
                                          saveDeletedFaults(e.team.id)
                                              .then((final void value) {
                                            setState(() {});
                                            ScaffoldMessenger.of(context)
                                                .clearSnackBars();
                                          });
                                        },
                                      ),
                                    ],
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

void showLoadingSnackBar(final BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(days: 365),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        content: Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
      ),
    );

Future<void> updateFaultMessage(final int teamId, final String message) async {
  final GraphQLClient client = getClient();
  await client.mutate(
    MutationOptions(
      document: gql(updateMessage),
      variables: <String, dynamic>{"team": teamId, "message": message},
    ),
  );
}

Future<void> addFaultTeam(final int teamId, final String message) async {
  final GraphQLClient client = getClient();
  print(
    await client.mutate(
      MutationOptions(
        document: gql(addTeam),
        variables: <String, dynamic>{
          "team_id": teamId,
          "fault_message": message
        },
      ),
    ),
  );
}

Future<void> saveDeletedFaults(final int teamID) async {
  final GraphQLClient client = getClient();
  await client.mutate(
    MutationOptions(
      document: gql(deleteTeams),
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

const String updateMessage = """
mutation MyMutation(\$team: Int, \$message: String) {
  update_broken_robots(where: {team_id: {_eq: \$team}}, _set: {message: \$message}) {
    affected_rows
  }
}

""";

const String deleteTeams = """
mutation MyMutation(\$team: Int) {
  delete_broken_robots(where: {team_id: {_eq: \$team}}) {
    affected_rows
  }
}
""";

const String addTeam = """
mutation Mymutation(\$team_id:Int,\$fault_message:String){
  insert_broken_robots(objects: {team_id: \$team_id, message: \$fault_message}) {
    affected_rows
  }}
""";
