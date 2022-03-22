import "dart:convert";
import "dart:io";

import "package:args/args.dart";
import "package:dotenv/dotenv.dart";
import "package:graphql/client.dart";
import "package:http/http.dart" as http;

Future<Map<String, int>> fetchEnum(
  final String table,
) async {
  final String query = """
query {
   
    $table(order_by: {id: asc}) {
        id
        title
    }
}
""";
  return (await getClient().query(QueryOptions(document: gql(query))))
      .mapQueryResult(
    (final Map<String, dynamic>? data) =>
        data.mapNullable(
          (final Map<String, dynamic> result) => <String, int>{
            for (final dynamic entry in (result[table] as List<dynamic>))
              entry["title"] as String: entry["id"] as int
          },
        ) ??
        (throw Exception("Query $table returned null")),
  );
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
      allowed: const <String>["qm", "qf", "sf", "f"],
    );

  final ArgResults results = arg.parse(args);
  load("dev.env");

  if (results.wasParsed("help")) {
    print(arg.usage);
    exit(0);
  }
  final Map<String, int> matchTypes = (await fetchEnum("match_type"));

  final List<LightTeam> teams = await fetchTeams();

  final http.Response response = await fetchTeamMatches(
    (results["event"] as String?) ??
        (throw ArgumentError(
          "You need to add an event code add -h for help",
        )),
  );

  int tbaMatchTypeToId(final String tbaType) {
    switch (tbaType) {
      case "qm":
        return matchTypes["Quals"]!;
      case "qf":
        return matchTypes["Quarter finals"]!;
      case "sf":
        return matchTypes["Semi finals"]!;
      case "f":
        return matchTypes["Finals"]!;
    }
    throw Exception("Not a match type");
  }

  final String matchType = (results["match-type"] as String?) ??
      (throw ArgumentError(
        "You need to add a match type add -h for help",
      ));
  print(
    await sendMatches(
      parseResponse(
        response,
        results["event"] as String,
        matchType,
      ),
      getClient(),
      teams,
      tbaMatchTypeToId(matchType),
    ),
  );
}

const String mutation = r"""
mutation MyMutation($matches: [orbit_matches_insert_input!]!) {
  insert_orbit_matches(objects: $matches, on_conflict: {constraint: orbit_matches_match_type_id_match_number_key, update_columns: happened}) {
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

Future<QueryResult> sendMatches(
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
        "blue_$i": teams
            .where(
              (final LightTeam element) => element.number == e.blueAlliance[i],
            )
            .first
            .id,
      for (int i = 0; i < 3; i++)
        "red_$i": teams
            .where(
              (final LightTeam element) => element.number == e.redAlliance[i],
            )
            .first
            .id,
    },
  );

  return client.mutate(
    MutationOptions(
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

Future<http.Response> fetchTeamMatches(final String event) {
  return http.get(
    Uri.parse(
      "https://www.thebluealliance.com/api/v3/team/frc1690/event/$event/matches/simple",
    ),
    headers: <String, String>{"X-TBA-Auth-Key": env["TBA_API_KEY"]!},
  );
}

//I had to copy these from existing files because if you import a file that has flutter imports to a dart file the file doesn't run
class LightTeam {
  const LightTeam(this.id, this.number, this.name);
  final int id;
  final int number;
  final String name;
}

Future<List<LightTeam>> fetchTeams() async {
  final GraphQLClient client = getClient();
  final String query = """
query FetchTeams {
  team {
    id
    number
    name
  }
}
  """;

  final QueryResult result =
      await client.query(QueryOptions(document: gql(query)));

  return result.mapQueryResult(
        (final Map<String, dynamic>? data) => data.mapNullable(
          (final Map<String, dynamic> teams) => (teams["team"] as List<dynamic>)
              .map(
                (final dynamic e) => LightTeam(
                  e["id"] as int,
                  e["number"] as int,
                  e["name"] as String,
                ),
              )
              .toList(),
        ),
      ) ??
      (throw Exception("No teams queried"));
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

extension MapQueryResult on QueryResult {
  T mapQueryResult<T>(final T Function(Map<String, dynamic>?) f) =>
      hasException ? throw exception! : f(data);
}

T Function() always<T>(final T result) => () => result;

extension MapNullable<A> on A? {
  B fold<B>(final B Function() onEmpty, final B Function(A) onSome) =>
      this == null ? onEmpty() : onSome(this as A);

  B? mapNullable<B>(final B Function(A) f) => fold(always(null), f);
}
