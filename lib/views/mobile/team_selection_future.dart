import "package:flutter/material.dart";
import 'package:graphql/client.dart';
import "package:scouting_frontend/models/id_helpers.dart";
import "package:scouting_frontend/models/team_model.dart";
import 'package:scouting_frontend/net/hasura_helper.dart';
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/widgets/teams_search_box.dart";

class TeamSelectionFuture extends StatefulWidget {
  TeamSelectionFuture({
    this.onChange = ignore,
    required this.controller,
  });
  final TextEditingController controller;
  final void Function(LightTeam) onChange;
  @override
  State<TeamSelectionFuture> createState() => _TeamSelectionFutureState();
}

class _TeamSelectionFutureState extends State<TeamSelectionFuture> {
  @override
  Widget build(final BuildContext context) {
    return Builder(
      builder: (
        final BuildContext context,
      ) {
        if (TeamHelper._teams.isEmpty) {
          return Text("No teams available :(");
        } else {
          return TeamsSearchBox(
            typeAheadController: widget.controller,
            teams: TeamHelper._teams,
            onChange: (final LightTeam LightTeam) {
              setState(() {
                widget.onChange(LightTeam);
              });
            },
          );
        }
      },
    );
  }
}

class TeamHelper {
  static List<LightTeam> _teams = <LightTeam>[];

  static Future<void> fetchTeams() async {
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

    _teams = result.mapQueryResult(
          (final Map<String, dynamic>? data) => data.mapNullable(
            (final Map<String, dynamic> teams) =>
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
        ) ??
        <LightTeam>[];
  }
}
