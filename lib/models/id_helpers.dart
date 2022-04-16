import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/models/map_nullable.dart";

String tablesToQuerys(
  final List<String> tables,
  final List<String> tablesToOrderByOrderColumn,
) {
  String querys = "";
  for (final String table in tables) {
    querys += """
    $table(order_by: {${tablesToOrderByOrderColumn.contains(table) ? "order" : "id"}: asc}) {
        id
        title
    }
""";
  }
  return querys;
}

Future<Map<String, Map<String, int>>> fetchEnums(
  final List<String> tables,
  final List<String> tablesToOrderByOrderColumn,
) async {
  final String query = """
query {
   ${tablesToQuerys(tables, tablesToOrderByOrderColumn)}
}
""";
  return (await getClient().query(QueryOptions(document: gql(query))))
      .mapQueryResult(
    (final Map<String, dynamic>? data) =>
        data.mapNullable(
          (final Map<String, dynamic> result) => <String, Map<String, int>>{
            for (final String table in tables)
              table: <String, int>{
                for (final dynamic entry in (result[table] as List<dynamic>))
                  entry["title"] as String: entry["id"] as int
              }
          },
        ) ??
        (throw Exception("Query $tables returned null")),
  );
}
