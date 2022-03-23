import "package:dotenv/dotenv.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";

class LightTeam {
  LightTeam(
    final int id,
    final int number,
    final String name,
    final int colorsIndex,
  ) : this._inner(
          id,
          number,
          name,
          colorsIndex,
        );
  LightTeam.fromJson(final dynamic e)
      : this(
          e["id"] as int,
          e["number"] as int,
          e["name"] as String,
          e["colors_index"] as int,
        );
  LightTeam._inner(
    this.id,
    this.number,
    this.name,
    this.colorsIndex,
  );

  @override
  String toString() {
    return "$number $name";
  }

  final int id;
  final int number;
  final String name;
  final int colorsIndex;
}

void main(final List<String> args) async {
  load("dev.env");
  final QueryResult result =
      await getClient().query(QueryOptions(document: gql(query)));
  result.mapQueryResult(
    (final Map<String, dynamic>? p0) =>
        p0.mapNullable((final Map<String, dynamic> data) {
      (data["team"] as List<dynamic>)
          .where((final dynamic element) => element["pit"] == null)
          .map(LightTeam.fromJson)
          .forEach(print);
    }),
  );
}

const String query = """
query NoPit{
  team{
    pit{
      id
    }
    id
    number
    name
    colors_index
  }
}
""";

extension MapQueryResult on QueryResult {
  T mapQueryResult<T>(final T Function(Map<String, dynamic>?) f) =>
      hasException ? throw exception! : f(data);
}

GraphQLClient getClient() {
  final HttpLink httpLink = HttpLink(
    "https://orbitdb.hasura.app/v1/graphql",
    defaultHeaders: <String, String>{
      "x-hasura-admin-secret": env["HASURA_ADMIN_SECRET"]!
    },
  );
  final WebSocketLink webSocketLink = WebSocketLink(
    "wss://orbitdb.hasura.app/v1/graphql",
    config: SocketClientConfig(
      initialPayload: <String, dynamic>{
        "headers": <String, dynamic>{
          "x-hasura-admin-secret": env["HASURA_ADMIN_SECRET"]
        },
      },
    ),
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
