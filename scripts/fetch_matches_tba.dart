import "dart:convert";
import "dart:io";

import "package:args/args.dart";
import "package:dotenv/dotenv.dart";
import "package:graphql/client.dart";
import "package:http/http.dart" as http;

Future<Map<String, int>> fetchEnum(final String table, final DotEnv env) async {
  final String query = """
query FetchEnum{
    $table(order_by: {id: asc}) {
        id
        title
    }
}
""";
  return (await getClient(env).query(
    QueryOptions<Map<String, int>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> result) => <String, int>{
        for (final dynamic entry in (result[table] as List<dynamic>))
          entry["title"] as String: entry["id"] as int,
      },
    ),
  ))
      .mapQueryResult();
}

void main(final List<String> args) async {
  final ArgParser arg = ArgParser()
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
    )
    ..addOption(
      "match-type",
      abbr: "m",
      help: "The match type to fetch the matches for",
      valueHelp: "qm",
      allowed: const <String>["qm", "qf", "sf", "f", "rb", "ef"],
    );

  final ArgResults results = arg.parse(args);
  final DotEnv env = DotEnv()..load(<String>["dev.env"]);

  if (results.wasParsed("help")) {
    // ignore: avoid_print
    print(arg.usage);
    exit(0);
  }
  final Map<String, int> matchTypes = (await fetchEnum("match_type", env));

  final List<LightTeam> teams = await fetchTeams(env);
  final String event = (results["event"] as String?) ??
      (throw ArgumentError(
        "You need to add an event code add -h for help",
      ));
  final http.Response response = await fetchTeamMatches(event, env);

  int userTypeToId(final String tbaType) {
    switch (tbaType) {
      case "qm":
        return matchTypes["Quals"]!;
      case "qf":
        return matchTypes["Quarter finals"]!;
      case "sf":
        return matchTypes["Semi finals"]!;
      case "f":
        return matchTypes["Finals"]!;
      case "rb":
        return matchTypes["Round robin"]!;
      case "ef":
        return matchTypes["Einstein finals"]!;
    }
    throw Exception("Not a match type $tbaType");
  }

  final String matchType = (results["match-type"] as String?) ??
      (throw ArgumentError(
        "You need to add a match type add -h for help",
      ));
  String userTypeToTbaType(final String userType) {
    switch (userType) {
      case "rb":
        assert(
          event.contains("cmptx"),
          "Cant have round robin when its not a championship",
        );
        return "sf";
      case "ef":
        assert(
          event.contains("cmptx"),
          "Cant have einstein finals when its not a championship",
        );
        return "f";
      default:
        return userType;
    }
  }

  // ignore: avoid_print
  print(
    await sendMatches(
      parseResponse(
        response,
        results["event"] as String,
        userTypeToTbaType(matchType),
      ),
      getClient(env),
      teams,
      userTypeToId(matchType),
    ),
  );
}

const String mutation = r"""
mutation InsertMatches($matches: [matches_insert_input!]!) {
  insert_matches(objects: $matches, on_conflict: {constraint: matches_match_number_match_type_id_key, update_columns: happened}) {
    affected_rows
  }
}
""";

List<Match> parseResponse(
  final http.Response response,
  final String event,
  final String matchType,
) {
  final List<dynamic> matchesUnParsed =
      (jsonDecode(response.body) as List<dynamic>)
          .where(
            (final dynamic element) =>
                (element["key"] as String).startsWith("${event}_$matchType"),
          )
          .toList();

  matchesUnParsed.sort(
    (final dynamic a, final dynamic b) =>
        (a["match_number"] as int).compareTo((b["match_number"] as int)),
  );

  return matchesUnParsed
      .map(
        (final dynamic e) => Match(
          e["match_number"] as int,
          (e["alliances"]["blue"]["team_keys"] as List<dynamic>)
              .cast<String>()
              .map((final String e) => int.parse(e.substring(3)))
              .toList(),
          (e["alliances"]["red"]["team_keys"] as List<dynamic>)
              .cast<String>()
              .map((final String e) => int.parse(e.substring(3)))
              .toList(),
          (e["winning_alliance"] as String).isNotEmpty,
        ),
      )
      .toList();
}

Future<QueryResult<void>> sendMatches(
  final List<Match> matches,
  final GraphQLClient client,
  final List<LightTeam> teams,
  final int matchTypeId,
) {
  final Iterable<Map<String, dynamic>> vars = matches.map<Map<String, dynamic>>(
    (final Match e) => <String, dynamic>{
      "match_number": e.number,
      "match_type_id": matchTypeId,
      "happened": e.happened,
      for (int i = 0; i < 3; i++)
        "blue_${i}_id": teams
            .where(
              (final LightTeam element) => element.number == e.blueAlliance[i],
            )
            .first
            .id,
      for (int i = 0; i < 3; i++)
        "red_${i}_id": teams
            .where(
              (final LightTeam element) => element.number == e.redAlliance[i],
            )
            .first
            .id,
    },
  );

  return client.mutate(
    MutationOptions<void>(
      document: gql(mutation),
      variables: <String, dynamic>{"matches": vars.toList()},
    ),
  );
}

class Match {
  const Match(this.number, this.blueAlliance, this.redAlliance, this.happened);
  final int number;
  final bool happened;
  final List<int> redAlliance;
  final List<int> blueAlliance;
}

Future<http.Response> fetchTeamMatches(final String event, final DotEnv env) =>
    http.get(
      Uri.parse(
        "https://www.thebluealliance.com/api/v3/event/$event/matches/simple",
      ),
      headers: <String, String>{"X-TBA-Auth-Key": env["TBA_API_KEY"]!},
    );

//I had to copy these from existing files because if you import a file that has flutter imports to a dart file the file doesn't run
class LightTeam {
  const LightTeam(this.id, this.number, this.name);
  final int id;
  final int number;
  final String name;
}

Future<List<LightTeam>> fetchTeams(final DotEnv env) async {
  final GraphQLClient client = getClient(env);
  const String query = """
query FetchTeams {
  team {
    id
    number
    name
  }
}
  """;

  final QueryResult<List<LightTeam>> result = await client.query(
    QueryOptions<List<LightTeam>>(
      document: gql(query),
      parserFn: (final Map<String, dynamic> teams) =>
          (teams["team"] as List<dynamic>)
              .map(
                (final dynamic e) => LightTeam(
                  e["id"] as int,
                  e["number"] as int,
                  e["name"] as String,
                ),
              )
              .toList(),
    ),
  );

  return result.mapQueryResult();
}

GraphQLClient getClient(final DotEnv env) {
  final HttpLink link = HttpLink(
    "https://orbitdb2023.hasura.app/v1/graphql",
    defaultHeaders: <String, String>{
      "x-hasura-admin-secret": env["HASURA_ADMIN_SECRET"]!,
    },
  );
  return GraphQLClient(link: link, cache: GraphQLCache());
}

extension MapQueryResult<A> on QueryResult<A> {
  A mapQueryResult() => (hasException
      ? throw exception!
      : data == null
          ? (throw Exception("Data returned null"))
          : parsedData!);
}

T Function() always<T>(final T result) => () => result;

extension MapNullable<A> on A? {
  B fold<B>(final B Function() onEmpty, final B Function(A) onSome) =>
      this == null ? onEmpty() : onSome(this as A);

  B? mapNullable<B>(final B Function(A) f) => fold(always(null), f);
}
