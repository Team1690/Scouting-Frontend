import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";

String tablesToQuerys(
  final List<String> tables,
  final List<String> tablesToOrderByOrderColumn,
) {
  String queries = "";
  for (final String table in tables) {
    queries += """
    $table(order_by: {${tablesToOrderByOrderColumn.contains(table) ? "order" : "id"}: asc}) {
        id
        title
    }
""";
  }
  return queries;
}

Future<Map<String, Map<String, int>>> fetchEnums(
  final List<String> tables,
  final List<String> tablesToOrderByOrderColumn,
) async {
  final String query = """
query FetchEnums{
   ${tablesToQuerys(tables, tablesToOrderByOrderColumn)}
}
""";
  return (await getClient().query(
    QueryOptions<Map<String, Map<String, int>>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> result) =>
          <String, Map<String, int>>{
        for (final String table in tables)
          table: <String, int>{
            for (final dynamic entry in (result[table] as List<dynamic>))
              entry["title"] as String: entry["id"] as int
          }
      },
    ),
  ))
      .mapQueryResult();
}
