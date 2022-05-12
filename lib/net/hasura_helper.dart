import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/team_model.dart";

GraphQLClient getClient() {
  final HttpLink httpLink = HttpLink(
    "https://orbitdb.hasura.app/v1/graphql",
  );
  final WebSocketLink webSocketLink = WebSocketLink(
    "wss://orbitdb.hasura.app/v1/graphql",
    config: SocketClientConfig(),
  );
  return GraphQLClient(
    link: Link.split(
      (final Request request) => request.isSubscription,
      webSocketLink,
      httpLink,
    ),
    cache: GraphQLCache(),
  );
}

extension MapQueryResult<A> on QueryResult<A> {
  A mapQueryResult() => (hasException
      ? throw exception!
      : data == null
          ? (throw Exception("Data returned null"))
          : parsedData!);
}

A queryResultToParsed<A>(final QueryResult<A> result) =>
    result.mapQueryResult();

extension MapSnapshot<T> on AsyncSnapshot<T> {
  V mapSnapshot<V>({
    required final V Function(T) onSuccess,
    required final V Function() onWaiting,
    required final V Function() onNoData,
    required final V Function(Object) onError,
  }) =>
      hasError
          ? onError(error!)
          : (ConnectionState.waiting == connectionState
              ? onWaiting()
              : (hasData ? onSuccess(data!) : onNoData()));
}

Future<List<LightTeam>> fetchTeams() async {
  final GraphQLClient client = getClient();
  final String query = """
query FetchTeams {
  team {
    id
    number
    name
    colors_index
  }
}
  """;

  final QueryResult<List<LightTeam>> result = await client.query(
    QueryOptions<List<LightTeam>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> teams) =>
          (teams["team"] as List<dynamic>)
              .map(
                (final dynamic e) => LightTeam(
                  e["id"] as int,
                  e["number"] as int,
                  e["name"] as String,
                  e["colors_index"] as int,
                ),
              )
              .toList(),
    ),
  );

  return result.mapQueryResult();
}
