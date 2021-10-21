import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';

GraphQLClient getClient() {
  Map<String, String> headers = new Map<String, String>();
  headers["x-hasura-admin-secret"] =
      "j0eAGMVfVfeYlyUnlTfYVQc64typ3OTfNbJrpQWXrqKp0qQnon7TpNzvabMC1Pi0";
  final link = HttpLink("https://orbitdb.hasura.app/v1/graphql",
      defaultHeaders: headers);
  return GraphQLClient(link: link, cache: GraphQLCache());
}
