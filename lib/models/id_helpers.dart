import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";

const String tableFragment = """{
    id
    title
  }
  """;

Map<String, int> parseTable(final dynamic result, final String tableName) =>
    Map<String, int>.fromEntries(
      (result[tableName] as List<dynamic>).map(
        (final dynamic tableResponse) => MapEntry<String, int>(
          tableResponse["title"] as String,
          tableResponse["id"] as int,
        ),
      ),
    );

String queryEnumTable(final String table) => """$table $tableFragment""";
/*
in   
* IdProvider.of(context).matchType.idToName.keys.toList()
we use the fact that it is ordered in the selector to order them in the UI
BTW dart maps are ordered
*/
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
  final String query = """
query FetchEnums {
    ${queries.join("\n")}
}
""";

  return (await getClient().query(
    QueryOptions<Map<String, Map<String, int>>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> result) =>
          Map<String, Map<String, int>>.fromEntries(
        <String>[...enums, ...orderedEnums].map(
          (final String tableName) => MapEntry<String, Map<String, int>>(
            tableName,
            parseTable(result, tableName),
          ),
        ),
      ),
    ),
  ))
      .mapQueryResult();
}
