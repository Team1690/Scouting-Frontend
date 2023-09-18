import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:orbit_standard_library/orbit_standard_library.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view/add_fault.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view/fault_tile.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";

class FaultView extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => Scaffold(
        drawer: SideNavBar(),
        appBar: AppBar(
          title: const Text("Robot faults"),
          centerTitle: true,
          actions: <Widget>[
            AddFault(
              onFinished: handleQueryResult(context),
            ),
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
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return snapshot.data.mapNullable(
                    (final List<FaultEntry> data) => SingleChildScrollView(
                      primary: false,
                      child: Column(
                        children: data
                            .map(
                              (final FaultEntry e) => Card(
                                elevation: 2,
                                color: bgColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: defaultPadding / 4,
                                  ),
                                  child: FaultTile(e),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ) ??
                  (throw Exception("No data"));
            }
          },
        ),
      );
}

void Function(QueryResult<T>) handleQueryResult<T>(
  final BuildContext context,
) =>
    (final QueryResult<T> result) {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (result.hasException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text("Error: ${result.exception}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    };

void showLoadingSnackBar(final BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
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
  final Stream<QueryResult<List<FaultEntry>>> result = client.subscribe(
    SubscriptionOptions<List<FaultEntry>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> data) =>
          (data["faults"] as List<dynamic>)
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
                  e["match_number"] as int?,
                  e["match_type_id"] as int?,
                ),
              )
              .toList(),
    ),
  );
  return result.map(queryResultToParsed);
}

class NewFault {
  const NewFault(
    this.message,
    this.team,
    this.matchNumber,
    this.matchTypeId,
  );
  final String message;
  final LightTeam team;
  final int? matchNumber;
  final int? matchTypeId;
}

class FaultEntry {
  const FaultEntry(
    this.faultMessage,
    this.team,
    this.id,
    this.faultStatus,
    this.matchNumber,
    this.matchType,
  );
  final int? matchType;
  final int? matchNumber;
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
    match_type_id
    match_number
  }
}

""";
