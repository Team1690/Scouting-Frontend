import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/models/map_nullable.dart";

GraphQLClient getClient() {
  final Map<String, String> headers = <String, String>{};
  headers["x-hasura-admin-secret"] = dotenv.env["HASURA_ADMIN_SECRET"]!;
  final HttpLink link = HttpLink(
    "https://orbitdb.hasura.app/v1/graphql",
    defaultHeaders: headers,
  );
  return GraphQLClient(link: link, cache: GraphQLCache());
}

extension MapQueryResult on QueryResult {
  T mapQueryResult<T>(final T Function(Map<String, dynamic>?) f) =>
      hasException ? throw exception! : f(data);
}

extension MapSnapshot<T> on AsyncSnapshot<T> {
  V mapSnapshot<V>(
    final V Function(T) f,
    final V Function() onWaiting,
    final V Function() onNoData,
    final V Function() onError,
  ) =>
      hasError
          ? onError()
          : (ConnectionState.waiting == connectionState
              ? onWaiting()
              : (hasData ? f(data!) : onNoData()));
}

Future<List<LightTeam>> fetchTeams() async {
  final GraphQLClient client = getClient();
  final String query = """
query FetchTeams {
  team {
    id
    number
    name
  }
}
  """;

  final QueryResult result =
      await client.query(QueryOptions(document: gql(query)));

  return result.mapQueryResult(
        (final Map<String, dynamic>? data) => data.mapNullable(
          (final Map<String, dynamic> teams) => (teams["team"] as List<dynamic>)
              .map(
                (final dynamic e) => LightTeam(
                  e["id"] as int,
                  e["number"] as int,
                  e["name"] as String,
                ),
              )
              .toList(),
        ),
      ) ??
      (throw Exception("No teams queried"));
}
