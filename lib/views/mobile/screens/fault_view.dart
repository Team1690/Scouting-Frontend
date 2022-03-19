import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/switcher.dart";

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
              (await showDialog<NewFault>(
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
                          maxLines: 4,
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
                              .pop(NewFault(newMessage!, team!));
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
                  .mapNullable((final NewFault p0) {
                showLoadingSnackBar(context);
                addFaultTeam(p0.team.id, p0.message).then((final void _) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  setState(() {});
                });
              });
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: FutureBuilder<List<FaultEntry>>(
        future: fetchFaults(),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<FaultEntry>> snapshot,
        ) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return snapshot.data.mapNullable((final List<FaultEntry> data) {
                  return SingleChildScrollView(
                    primary: false,
                    child: Column(
                      children: data
                          .map(
                            (final FaultEntry e) => Card(
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
                                          controller.text = e.faultMessage;
                                          (await showDialog<String>(
                                            context: context,
                                            builder:
                                                (final BuildContext context) =>
                                                    AlertDialog(
                                              title: Text("Edit message"),
                                              content: TextField(
                                                maxLines: 4,
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
                                              e.id,
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
                                          saveDeletedFaults(e.id)
                                              .then((final void value) {
                                            setState(() {});
                                            ScaffoldMessenger.of(context)
                                                .clearSnackBars();
                                          });
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          int? statusIdState;
                                          (await showDialog<int>(
                                            context: context,
                                            builder:
                                                (final BuildContext context) {
                                              final Map<int, int?> indexToId =
                                                  <int, int?>{
                                                -1: null,
                                                0: IdProvider.of(
                                                  context,
                                                ).faultStatus.nameToId["Fixed"],
                                                1: IdProvider.of(
                                                  context,
                                                )
                                                    .faultStatus
                                                    .nameToId["In progress"],
                                                2: IdProvider.of(
                                                  context,
                                                )
                                                    .faultStatus
                                                    .nameToId["No progress"],
                                              };
                                              return StatefulBuilder(
                                                builder: (
                                                  final BuildContext context,
                                                  final void Function(
                                                    void Function(),
                                                  )
                                                      alertDialogSetState,
                                                ) =>
                                                    AlertDialog(
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        statusIdState
                                                            .mapNullable(
                                                          Navigator.of(context)
                                                              .pop,
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
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                  title: Text(
                                                    "Change fault status",
                                                  ),
                                                  content: Switcher(
                                                    selected: <int?, int>{
                                                      for (final MapEntry<int,
                                                              int?> entry
                                                          in indexToId.entries)
                                                        entry.value: entry.key
                                                    }[statusIdState]!,
                                                    onChange:
                                                        (final int index) {
                                                      alertDialogSetState(() {
                                                        statusIdState =
                                                            indexToId[index];
                                                      });
                                                    },
                                                    colors: const <Color>[
                                                      Colors.green,
                                                      Colors.yellow,
                                                      Colors.red,
                                                    ],
                                                    labels: const <String>[
                                                      "Fixed",
                                                      "In progress",
                                                      "No progress"
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ))
                                              .mapNullable((final int p0) {
                                            showLoadingSnackBar(context);
                                            updatrFaultStatus(e.id, p0)
                                                .then((final _) {
                                              ScaffoldMessenger.of(context)
                                                  .clearSnackBars();
                                              setState(() {});
                                            });
                                          });
                                        },
                                        icon: Icon(Icons.build),
                                      ),
                                    ],
                                  ),
                                  title: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          "${e.team.number} ${e.team.name}",
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          "Status: ${e.faultStatus}",
                                          style: TextStyle(
                                            color: faultTitleToColor(
                                              e.faultStatus,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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

Future<void> updatrFaultStatus(final int id, final int faultStatusId) async {
  print(
    await getClient().mutate(
      MutationOptions(
        document: gql(updateFaultStatus),
        variables: <String, dynamic>{
          "id": id,
          "fault_status_id": faultStatusId
        },
      ),
    ),
  );
}

Future<void> updateFaultMessage(final int id, final String message) async {
  final GraphQLClient client = getClient();
  await client.mutate(
    MutationOptions(
      document: gql(updateMessage),
      variables: <String, dynamic>{"id": id, "message": message},
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

Future<void> saveDeletedFaults(final int id) async {
  final GraphQLClient client = getClient();
  await client.mutate(
    MutationOptions(
      document: gql(deleteTeams),
      variables: <String, dynamic>{"id": id},
    ),
  );
}

Future<List<FaultEntry>> fetchFaults() async {
  final GraphQLClient client = getClient();
  final QueryResult result =
      await client.query(QueryOptions(document: gql(query)));
  return result.mapQueryResult(
    (final Map<String, dynamic>? data) =>
        data.mapNullable<List<FaultEntry>>(
          (final Map<String, dynamic> data) {
            return (data["broken_robots"] as List<dynamic>)
                .map(
                  (final dynamic e) => FaultEntry(
                    e["message"] as String,
                    LightTeam(
                      e["team"]["id"] as int,
                      e["team"]["number"] as int,
                      e["team"]["name"] as String,
                      e["team"]["colors_index"] as int,
                    ),
                    e["id"] as int,
                    e["fault_status"]["title"] as String,
                  ),
                )
                .toList();
          },
        ) ??
        (throw Exception("No data")),
  );
}

class NewFault {
  const NewFault(this.message, this.team);
  final String message;
  final LightTeam team;
}

class FaultEntry {
  const FaultEntry(
    this.faultMessage,
    this.team,
    this.id,
    this.faultStatus,
  );
  final String faultMessage;
  final int id;
  final LightTeam team;
  final String faultStatus;
}

Color faultTitleToColor(final String title) {
  switch (title) {
    case "Fixed":
      return Colors.green;
    case "In progress":
      return Colors.yellow;
    case "No progress":
      return Colors.red;
    case "Unknown":
      return Colors.orange;
  }
  throw Exception("$title not a known title");
}

const String query = """
query MyQuery {
  broken_robots(order_by: {fault_status: {order: asc}}) {
    fault_status{
      title
    }
    id
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
mutation MyMutation(\$id: Int, \$message: String) {
  update_broken_robots(where: {id: {_eq: \$id}}, _set: {message: \$message}) {
    affected_rows
  }
}

""";

const String updateFaultStatus = r"""
mutation MyMutation($id: Int!, $fault_status_id: Int!) {
  update_broken_robots_by_pk(pk_columns: {id: $id}, _set: {fault_status_id: $fault_status_id}) {
    id
  }
}

""";

const String deleteTeams = """
mutation MyMutation(\$id: Int) {
  delete_broken_robots(where: {id: {_eq: \$id}}) {
    affected_rows
  }
}
""";

const String addTeam = """
mutation Mymutation(\$team_id:Int,\$fault_message:String){
  insert_broken_robots(objects: {team_id: \$team_id, message: \$fault_message}) {
    affected_rows
  }
}
""";
