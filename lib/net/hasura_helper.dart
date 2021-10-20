import 'package:graphql/client.dart';

class HasuraHelper {
  GraphQLClient getClient() {
    Map<String, String> headers = new Map<String, String>();
    headers["x-hasura-admin-secret"] =
        "j0eAGMVfVfeYlyUnlTfYVQc64typ3OTfNbJrpQWXrqKp0qQnon7TpNzvabMC1Pi0";
    final link = HttpLink("https://orbitdb.hasura.app/v1/graphql",
        defaultHeaders: headers);
    return GraphQLClient(link: link, cache: GraphQLCache());
  }
}
