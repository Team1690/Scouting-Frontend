import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/screens/fault_view.dart";
import "package:orbit_standard_library/orbit_standard_library.dart";

class ChangeFaultStatus extends StatelessWidget {
  const ChangeFaultStatus({required this.faultId, required this.onFinished});
  final int faultId;
  final void Function(QueryResult<void>) onFinished;
  @override
  Widget build(final BuildContext context) => IconButton(
        onPressed: () async {
          int? statusIdState;
          await (await showDialog<int>(
            context: context,
            builder: (final BuildContext context) {
              final Map<int, int?> indexToId = <int, int?>{
                -1: null,
                0: IdProvider.of(
                  context,
                ).faultStatus.nameToId["Fixed"],
                1: IdProvider.of(
                  context,
                ).faultStatus.nameToId["In progress"],
                2: IdProvider.of(
                  context,
                ).faultStatus.nameToId["No progress"],
              };
              return StatefulBuilder(
                builder: (
                  final BuildContext context,
                  final void Function(
                    void Function(),
                  ) alertDialogSetState,
                ) =>
                    AlertDialog(
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        statusIdState.mapNullable(
                          Navigator.of(context).pop,
                        );
                      },
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                  title: const Text(
                    "Change fault status",
                  ),
                  content: Switcher(
                    borderRadiusGeometry: defaultBorderRadius,
                    selected: <int?, int>{
                      for (final MapEntry<int, int?> entry in indexToId.entries)
                        entry.value: entry.key,
                    }[statusIdState]!,
                    onChange: (final int index) {
                      alertDialogSetState(() {
                        statusIdState = indexToId[index];
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
                      "No progress",
                    ],
                  ),
                ),
              );
            },
          ))
              .mapNullable((final int p0) async {
            showLoadingSnackBar(context);
            final QueryResult<void> result =
                await updateFaultStatus(faultId, p0);
            onFinished(result);
          });
        },
        icon: const Icon(Icons.build),
      );
}

Future<QueryResult<void>> updateFaultStatus(
  final int id,
  final int faultStatusId,
) async =>
    getClient().mutate(
      MutationOptions<void>(
        document: gql(_updateFaultStatusMutation),
        variables: <String, dynamic>{
          "id": id,
          "fault_status_id": faultStatusId,
        },
      ),
    );

const String _updateFaultStatusMutation = r"""
mutation UpdateFaultStatus($id: Int!, $fault_status_id: Int!) {
  update_faults_by_pk(pk_columns: {id: $id}, _set: {fault_status_id: $fault_status_id}) {
    id
  }
}

""";
