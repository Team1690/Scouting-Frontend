import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_widget.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

Stream<QueryResult> fetchPicklist() {
  final GraphQLClient client = getClient();
  final String query = """
 subscription My {
  team {
    colors_index
    first_picklist_index
    id
    name
    number
    second_picklist_index
    taken
      broken_robots{
    message
  }
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
        robot_match_status{
          title
        }
      }
    }
  }
}

    """;
  final Stream<QueryResult> result =
      client.subscribe(SubscriptionOptions(document: gql(query)));

  return result;
}

List<PickListTeam> parse(
  final QueryResult event,
) =>
    event.mapQueryResult(
      (final Map<String, dynamic>? data) =>
          data.mapNullable((final Map<String, dynamic> pickListTeams) {
            final List<PickListTeam> teams =
                (pickListTeams["team"] as List<dynamic>).map((final dynamic e) {
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
              final int amountOfMatches =
                  (e["matches_aggregate"]["nodes"] as List<dynamic>).length;
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
              final List<String> faultMessages =
                  (e["broken_robots"] as List<dynamic>)
                      .map((final dynamic e) => e["message"] as String)
                      .toList();
              final List<RobotMatchStatus> robotMatchStatuses =
                  (e["matches_aggregate"]["nodes"] as List<dynamic>)
                      .map(
                        (final dynamic e) => titleToEnum(
                          e["robot_match_status"]["title"] as String,
                        ),
                      )
                      .toList();
              return PickListTeam(
                  amountOfMatches: amountOfMatches,
                  colorsIndex: e["colors_index"] as int,
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
                  faultMessage:
                      faultMessages.isEmpty ? null : faultMessages.first,
                  robotMatchStatusToAmount: <RobotMatchStatus, int>{
                    for (final RobotMatchStatus i in RobotMatchStatus.values)
                      i: robotMatchStatuses
                          .where(
                              (final RobotMatchStatus element) => element == i)
                          .length
                  });
            }).toList();
            return teams;
          }) ??
          <PickListTeam>[],
    );
