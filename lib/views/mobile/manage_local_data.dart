import "dart:convert";

import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:scouting_frontend/views/constants.dart";

class ManageLocalData extends StatefulWidget {
  ManageLocalData({
    required this.mutation,
    required this.prefs,
    required this.onChange,
  });
  final String mutation;
  final SharedPreferences prefs;
  final Function() onChange;

  @override
  State<ManageLocalData> createState() => _ManageLocalDataState();
}

class _ManageLocalDataState extends State<ManageLocalData> {
  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        child: Column(
          children: widget.prefs
              .getKeys()
              .map(
                (final String e) => Card(
                  color: bgColor,
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Text(e),
                        IconButton(
                          onPressed: () async {
                            final GraphQLClient client = getClient();
                            final QueryResult<void> queryResult =
                                await client.mutate(
                              MutationOptions<void>(
                                document: gql(widget.mutation),
                                variables: jsonDecode(
                                  widget.prefs.getString(e) ?? "",
                                ) as Map<String, dynamic>,
                              ),
                            );
                            final OperationException? exception =
                                queryResult.exception;
                            if (exception != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 5),
                                  content: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "Could not submit match. Error message: $exception",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              await widget.prefs.remove(e);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 5),
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Success!",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              widget.onChange();
                            }
                          },
                          icon: const Icon(Icons.send),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              widget.prefs.remove(e);
                              widget.onChange();
                            });
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
      );
}
