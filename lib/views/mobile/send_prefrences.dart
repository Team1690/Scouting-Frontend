import "dart:convert";

import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:shared_preferences/shared_preferences.dart";

Future<void> sendPrefrences(
  final String mutation,
  final BuildContext context,
) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getKeys().isNotEmpty) {
    final List<String> jsons = prefs
        .getKeys()
        .map((final String e) => prefs.getString(e) ?? "")
        .toList();
    for (final String json in jsons) {
      final GraphQLClient client = getClient();
      final QueryResult<void> queryResult = await client.mutate(
        MutationOptions<void>(
          document: gql(mutation),
          variables: jsonDecode(json) as Map<String, dynamic>,
        ),
      );
      final OperationException? exception = queryResult.exception;
      if (exception != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Could not submit one of the saved matches",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      } else {
        await prefs.remove(
          prefs.getKeys().firstWhere(
                (final String element) => prefs.getString(element) == json,
              ),
        );
      }
    }
  }
}
