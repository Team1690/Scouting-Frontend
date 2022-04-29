import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view/add_fault.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view/change_fault_status.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view/delete_fault.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view/update_fault_message.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";

class FaultView extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      drawer: SideNavBar(),
      appBar: AppBar(
        title: Text("Robot faults"),
        centerTitle: true,
        actions: <Widget>[
          AddFault(
            onFinished: handleQueryResult(context),
          )
        ],
      ),
      body: StreamBuilder<List<FaultEntry>>(
        stream: fetchFaults(),
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
                                child: FaultTile(e),
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

class FaultTile extends StatelessWidget {
  const FaultTile(this.e);
  final FaultEntry e;

  @override
  Widget build(final BuildContext context) {
    return ExpansionTile(
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          EditFault(
            onFinished: handleQueryResult(context),
            faultMessage: e.faultMessage,
            faultId: e.id,
          ),
          DeleteFault(
            faultId: e.id,
            onFinished: handleQueryResult(context),
          ),
          ChangeFaultStatus(
            faultId: e.id,
            onFinished: handleQueryResult(context),
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
    );
  }
}

void Function(QueryResult) handleQueryResult(final BuildContext context) =>
    (final QueryResult result) {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (result.hasException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 5),
            content: Text("Error: ${result.exception}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    };

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

Stream<List<FaultEntry>> fetchFaults() {
  final GraphQLClient client = getClient();
  final Stream<QueryResult> result =
      client.subscribe(SubscriptionOptions(document: gql(query)));
  return result.map(
    (final QueryResult event) => event.mapQueryResult(
      (final Map<String, dynamic>? data) =>
          data.mapNullable<List<FaultEntry>>(
            (final Map<String, dynamic> data) {
              return (data["faults"] as List<dynamic>)
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
    ),
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
subscription MyQuery {
  faults(order_by: {fault_status: {order: asc}, team: {number: asc} }) {
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
