import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/models/map_nullable.dart";

Future<Map<String, int>> fetchEnum(final String table) async {
  final String query = """
query {
    $table(order_by: {id: asc}) {
        id
        title
    }
}
""";
  return (await getClient().query(QueryOptions(document: gql(query))))
      .mapQueryResult(
    (final Map<String, dynamic>? data) =>
        data.mapNullable(
          (final Map<String, dynamic> result) => <String, int>{
            for (final dynamic entry in (result[table] as List<dynamic>))
              entry["title"] as String: entry["id"] as int
          },
        ) ??
        (throw Exception("Query $table returned null")),
  );
}
