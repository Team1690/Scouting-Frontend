import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";

String queryEnumTable(final String table) => """
    $table(order_by: {"id"}: asc}) {
      id
      title
    }
  """;

String queryOrderedEnumTable(final String table) => """
    $table(order_by: "order"}: asc}) {
      id
      title
    }
  """;

Future<Map<String, Map<String, int>>> fetchEnums(
  final Iterable<String> enums,
  final Iterable<String> orderedEnums,
) async {
  final List<String> queries = <String>[
    ...enums.map(queryEnumTable),
    ...orderedEnums.map(queryOrderedEnumTable),
  ];
  final String query = """
query FetchEnums {
    ${queries.join("\n")}
}
""";
  return (await getClient().query(
    QueryOptions<Map<String, Map<String, int>>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> result) =>
          <String, Map<String, int>>{
        for (final String table in <String>[...enums, ...orderedEnums])
          table: <String, int>{
            for (final dynamic entry in (result[table] as List<dynamic>))
              entry["title"] as String: entry["id"] as int
          }
      },
    ),
  ))
      .mapQueryResult();
}
