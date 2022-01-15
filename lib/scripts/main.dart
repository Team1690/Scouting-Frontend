import "dart:convert";

import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:graphql/client.dart";
import "package:http/http.dart" as http;

void main() async {
  sendTeams();
}

Future<http.Response> fetchTeamsFromTba() {
  return http.get(
    Uri.parse("https://thebluealliance.com/api/v3/event/2021cc/teams"),
    headers: <String, String>{"X-TBA-Auth-Key": dotenv.env["TBA_API_KEY"]!},
  );
}

const String mutation = """
mutation MyMutation(\$teams: [team_test_insert_input!]!) {
  insert_team_test(objects: \$teams) {
    affected_rows
  }
}

""";

Future<void> sendTeams() async {
  int index = 0;
  final List<dynamic> allData =
      jsonDecode((await fetchTeamsFromTba()).body) as List<dynamic>;
  final List<Team> teamsData = allData.map((final dynamic e) {
    final Team team = Team(
      name: e["nickname"] as String,
      firstPicklistIndex: index,
      number: e["team_number"] as int,
      secondPicklistIndex: index,
      taken: false,
    );
    index++;
    return team;
  }).toList();

  final GraphQLClient client = getClient();

  client.mutate(
    MutationOptions(
      document: gql(mutation),
      variables: <String, dynamic>{
        "teams": teamsData
            .map(
              (final Team e) => <String, dynamic>{
                "name": e.name,
                "number": e.number,
                "first_picklist_index": e.firstPicklistIndex,
                "second_picklist_index": e.secondPicklistIndex,
                "taken": e.taken
              },
            )
            .toList()
      },
    ),
  );
}

class Team {
  const Team({
    required this.name,
    required this.firstPicklistIndex,
    required this.number,
    required this.secondPicklistIndex,
    required this.taken,
  });
  final int number;
  final String name;
  final int firstPicklistIndex;
  final int secondPicklistIndex;
  final bool taken;
}

GraphQLClient getClient() {
  final Map<String, String> headers = <String, String>{};
  headers["x-hasura-admin-secret"] = dotenv.env["HASURA_ADMIN_SECRET"]!;
  final HttpLink link = HttpLink(
    "https://orbitdb.hasura.app/v1/graphql",
    defaultHeaders: headers,
  );
  return GraphQLClient(link: link, cache: GraphQLCache());
}
