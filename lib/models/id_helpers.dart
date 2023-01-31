import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";

Map<T, int> parseTable<T extends Enum>(
  final Map<String, dynamic> result,
  final String tableName,
  final T Function(String) titleToEnum,
) =>
    Map<T, int>.fromEntries(
      (result[tableName] as List<dynamic>).map(
        (final dynamic tableResponse) => MapEntry<T, int>(
          titleToEnum(tableResponse["title"] as String),
          tableResponse["id"] as int,
        ),
      ),
    );

/*
in   
* IdProvider.of(context).matchType.idToName.keys.toList()
we use the fact that it is ordered in the selector to order them in the UI
BTW dart maps are ordered
*/
String queryOrderedEnumTable(final String table) =>
    """$table(order_by: {order: asc}) {
    id
    title
  }""";

Future<Map<String, Map<String, dynamic>>> fetchEnums(
  final List<String> enums,
) async {
  final List<String> queries = enums.map(queryOrderedEnumTable).toList();
  final String query = """
query FetchEnums {
    ${queries.join("\n")}
}
""";

  return (await getClient().query(
    QueryOptions<Map<String, Map<String, dynamic>>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> result) =>
          Map<String, Map<String, dynamic>>.fromEntries(
        enums.map(
          (final String tableName) => MapEntry<String, Map<String, dynamic>>(
            tableName,
            result,
          ),
        ),
      ),
    ),
  ))
      .mapQueryResult();
}
