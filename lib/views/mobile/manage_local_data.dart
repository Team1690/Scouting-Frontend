import "dart:convert";
import "package:connectivity_plus/connectivity_plus.dart";
import "package:scouting_frontend/models/match_model.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";

class ManageLocalData extends StatefulWidget {
  ManageLocalData(
      {required this.mutation,
      required this.prefs,
      required this.onChange,
      this.vars});
  final String mutation;
  final SharedPreferences prefs;
  final Function() onChange;
  final Match? vars;

  @override
  State<ManageLocalData> createState() => _ManageLocalDataState();
}

class _ManageLocalDataState extends State<ManageLocalData> {
  Connectivity connectivity = Connectivity();
  bool isOffline = true;

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        child: Column(children: [
          ...widget.prefs.getKeys().map(
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
                            String errorMessage =
                                "Could not submit match. Error message: $exception";
                            if (exception != null) {
                              final List<GraphQLError> errors =
                                  exception.graphqlErrors;
                              if (errors.length == 1) {
                                final GraphQLError error = errors.single;
                                errorMessage = error.extensions?["code"]
                                            ?.toString() ==
                                        "constraint-violation"
                                    ? "That match already exisits check if you scouted that correct robot/wrote the correct match"
                                    : error.message;
                              } else {
                                errorMessage = errors.join(", ");
                              }
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
                                          errorMessage,
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
              ),
          ElevatedButton(
              onPressed: () {
                widget.prefs.getKeys().map(
                  (e) async {
                    final GraphQLClient client = getClient();
                    final QueryResult<void> queryResult = await client.mutate(
                      MutationOptions<void>(
                        document: gql(widget.mutation),
                        variables: jsonDecode(
                          widget.prefs.getString(e) ?? "",
                        ) as Map<String, dynamic>,
                      ),
                    );
                    final OperationException? exception = queryResult.exception;
                    String errorMessage =
                        "Could not submit match. Error message: $exception";
                    if (exception != null) {
                      final List<GraphQLError> errors = exception.graphqlErrors;
                      if (errors.length == 1) {
                        final GraphQLError error = errors.single;
                        errorMessage = error.extensions?["code"]?.toString() ==
                                "constraint-violation"
                            ? "That match already exisits check if you scouted that correct robot/wrote the correct match"
                            : error.message;
                      } else {
                        errorMessage = errors.join(", ");
                      }
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
                                  errorMessage,
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
                );
              },
              child: const Text("Send all"))
        ]),
      );
}
