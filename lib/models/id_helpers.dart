import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";

final String tableFragment = """{
    id
    title
  }
  """;

String queryEnumTable(final String table) =>
    """$table(order_by: {id:asc}) $tableFragment""";
String queryOrderedEnumTable(final String table) =>
    """$table(order_by: {order: asc}) $tableFragment""";

Future<Map<String, Map<String, int>>> fetchEnums(
  final List<String> enums,
  final List<String> orderedEnums,
) async {
  final List<String> queries = <String>[
    ...enums.map(queryEnumTable),
    ...orderedEnums.map(queryOrderedEnumTable),
  ];
  enums.addAll(orderedEnums);
  final String query = """
query FetchEnums {
    ${queries.join("\n")}
}
""";
  print(query);
  return (await getClient().query(
    QueryOptions<Map<String, Map<String, int>>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> result) =>
          <String, Map<String, int>>{
        for (final String table in enums)
          table: <String, int>{
            for (final dynamic entry in (result[table] as List<dynamic>))
              entry["title"] as String: entry["id"] as int
          }
      },
    ),
  ))
      .mapQueryResult();
}
