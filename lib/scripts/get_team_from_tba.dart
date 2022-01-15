import "dart:convert";

import "package:dotenv/dotenv.dart";
import "package:graphql/client.dart";
import "package:http/http.dart" as http;

void main(final List<String> args) async {
  load(".env");
  final http.Response response = await fetchTeamsFromTba(args[0]);
  final dynamic teams = jsonDecode(response.body);
  sendTeams(teams as List<dynamic>, getClient());
}

Future<http.Response> fetchTeamsFromTba(final String event) {
  return http.get(
    Uri.parse("https://thebluealliance.com/api/v3/event/$event/teams"),
    headers: <String, String>{"X-TBA-Auth-Key": env["TBA_API_KEY"]!},
  );
}

const String mutation = """
mutation MyMutation(\$teams: [team_test_insert_input!]!) {
  insert_team_test(objects: \$teams) {
    affected_rows
  }
}
""";

Future<void> sendTeams(
  final List<dynamic> teams,
  final GraphQLClient client,
) async {
  client.mutate(
    MutationOptions(
      document: gql(mutation),
      variables: <String, dynamic>{
        "teams": teams
            .map(
              (final dynamic e) => <String, dynamic>{
                "name": e["nickname"],
                "number": e["team_number"],
              },
            )
            .toList()
      },
    ),
  );
}

GraphQLClient getClient() {
  final Map<String, String> headers = <String, String>{};
  headers["x-hasura-admin-secret"] = env["HASURA_ADMIN_SECRET"]!;
  final HttpLink link = HttpLink(
    "https://orbitdb.hasura.app/v1/graphql",
    defaultHeaders: headers,
  );
  return GraphQLClient(link: link, cache: GraphQLCache());
}
