import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/pick_list_screen.dart";
import "package:scouting_frontend/views/pc/widgets/pick_list_widget.dart";
import "package:scouting_frontend/models/map_nullable.dart";

class PickListFuture extends StatefulWidget {
  PickListFuture({required this.screen, required this.onReorder});

  final CurrentPickList screen;
  final void Function(List<PickListTeam> list) onReorder;
  @override
  _PickListFutureState createState() => _PickListFutureState();
}

class _PickListFutureState extends State<PickListFuture> {
  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<List<PickListTeam>>(
      future: fetchTeams(),
      builder: (
        final BuildContext context,
        final AsyncSnapshot<List<PickListTeam>> snapshot,
      ) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == null) {
          return Center(
            child: Text("No Teams"),
          );
        }
        widget.onReorder(snapshot.data!);
        return PickList(
          onReorder: widget.onReorder,
          uiList: snapshot.data!,
          screen: widget.screen,
        );
      },
    );
  }

  Future<List<PickListTeam>> fetchTeams() async {
    final GraphQLClient client = getClient();
    final String query = """
 query MyQuery {
  team {
    first_picklist_index
    id
    name
    number
    second_picklist_index
    taken
    matches_aggregate {
      aggregate {
        avg {
          auto_lower
          auto_missed
          auto_upper
          tele_lower
          tele_missed
          tele_upper
        }
      }
      nodes {
        climb {
          points
        }
      }
    }
  }
}

    """;
    final QueryResult result =
        await client.query(QueryOptions(document: gql(query)));

    final List<PickListTeam> teams = result.mapQueryResult(
      (final Map<String, dynamic>? data) =>
          data.mapNullable((final Map<String, dynamic> pickListTeams) {
            return (pickListTeams["team"] as List<dynamic>)
                .map((final dynamic e) {
              final dynamic avg = e["matches_aggregate"]["aggregate"]["avg"];
              final double autoLower =
                  (avg["auto_lower"] as double?) ?? double.nan;

              final double autoUpper =
                  (avg["auto_upper"] as double?) ?? double.nan;
              final double teleLower =
                  (avg["tele_lower"] as double?) ?? double.nan;
              final double teleUpper =
                  (avg["tele_upper"] as double?) ?? double.nan;
              final double avgBallPoints =
                  autoLower * 2 + autoUpper * 4 + teleLower + teleUpper * 2;
              final Iterable<int> climb = (e["matches_aggregate"]["nodes"]
                      as List<dynamic>)
                  .map<int>((final dynamic e) => e["climb"]["points"] as int);

              final double climbAvg = climb.isEmpty
                  ? double.nan
                  : climb.length == 1
                      ? climb.first.toDouble()
                      : climb.reduce(
                            (final int value, final int element) =>
                                value + element,
                          ) /
                          climb.length;

              final double autoAim =
                  (((avg["auto_upper"] as double? ?? double.nan) +
                              (avg["auto_lower"] as double? ?? double.nan)) /
                          ((avg["auto_upper"] as double? ?? double.nan) +
                              (avg["auto_missed"] as double? ?? double.nan) +
                              (avg["auto_lower"] as double? ?? double.nan))) *
                      100;
              final double teleAim =
                  (((avg["tele_upper"] as double? ?? double.nan) +
                              (avg["tele_lower"] as double? ?? double.nan)) /
                          ((avg["tele_upper"] as double? ?? double.nan) +
                              (avg["tele_missed"] as double? ?? double.nan) +
                              (avg["tele_lower"] as double? ?? double.nan))) *
                      100;

              return PickListTeam(
                id: e["id"] as int,
                number: e["number"] as int,
                name: e["name"] as String,
                firstListIndex: e["first_picklist_index"] as int,
                secondListIndex: e["second_picklist_index"] as int,
                taken: e["taken"] as bool,
                autoAim: autoAim,
                teleAim: teleAim,
                avgBallPoints: avgBallPoints,
                avgClimbPoints: climbAvg,
              );
            }).toList();
          }) ??
          <PickListTeam>[],
    );

    teams.sort(
      (final PickListTeam left, final PickListTeam right) =>
          widget.screen.getIndex(left).compareTo(widget.screen.getIndex(right)),
    );
    return teams;
  }
}
