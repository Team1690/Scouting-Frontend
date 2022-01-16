import "dart:convert";
import "dart:io";

import "package:args/args.dart";
import "package:dotenv/dotenv.dart";
import "package:graphql/client.dart";
import "package:http/http.dart" as http;

void main(final List<String> args) async {
  final ArgParser arg = ArgParser()
    ..addFlag(
      "print",
      abbr: "p",
      help: "Print tba results and dont send to hasura",
      negatable: false,
    )
    ..addFlag(
      "help",
      abbr: "h",
      help: "Print out usage instructions",
      negatable: false,
    )
    ..addOption(
      "event",
      abbr: "e",
      help:
          "Name the event code you want to get teams from.\nYou can get the event code from the url of the event on tba website",
      valueHelp: "2021cc",
    );

  final ArgResults results = arg.parse(args);
  load(".env");

  if (results.wasParsed("help")) {
    print(arg.usage);
    exit(0);
  }

  final http.Response response = await fetchTeamsFromTba(
    results["event"] as String? ??
        (throw ArgumentError("You need to add an event code add -h for help")),
  );

  if (results.wasParsed("print")) {
    print(response.body);
    exit(0);
  }
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
mutation MyMutation(\$teams: [team_insert_input!]!) {
  insert_team(objects: \$teams) {
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
  final HttpLink link = HttpLink(
    "https://orbitdb.hasura.app/v1/graphql",
    defaultHeaders: <String, String>{
      "x-hasura-admin-secret": env["HASURA_ADMIN_SECRET"]!
    },
  );
  return GraphQLClient(link: link, cache: GraphQLCache());
}
