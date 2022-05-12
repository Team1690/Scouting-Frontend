import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_widget.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

Stream<List<PickListTeam>> fetchPicklist() {
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
    pit{
      drivetrain{
        title
      }
    }
      faults{
      message
  }
    matches_aggregate(where: {ignored: {_eq: false}}) {
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
          title
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
  final Stream<QueryResult<List<PickListTeam>>> result = client.subscribe(
    SubscriptionOptions<List<PickListTeam>>(
      document: gql(query),
      parserFn: parse,
    ),
  );

  return result.map(
    (final QueryResult<List<PickListTeam>> event) => event.mapQueryResult(),
  );
}

List<PickListTeam> parse(final Map<String, dynamic> pickListTeams) {
  final List<PickListTeam> teams =
      (pickListTeams["team"] as List<dynamic>).map((final dynamic e) {
    final dynamic avg = e["matches_aggregate"]["aggregate"]["avg"];
    final double autoLower = (avg["auto_lower"] as double?) ?? double.nan;

    final double autoUpper = (avg["auto_upper"] as double?) ?? double.nan;
    final double teleLower = (avg["tele_lower"] as double?) ?? double.nan;
    final double teleUpper = (avg["tele_upper"] as double?) ?? double.nan;
    final double avgBallPoints =
        autoLower * 2 + autoUpper * 4 + teleLower + teleUpper * 2;
    final Iterable<int> climb =
        (e["matches_aggregate"]["nodes"] as List<dynamic>)
            .where(
              (final dynamic element) =>
                  element["climb"]["title"] != "No attempt",
            )
            .map<int>((final dynamic e) => e["climb"]["points"] as int);
    final int amountOfMatches =
        (e["matches_aggregate"]["nodes"] as List<dynamic>).length;
    final double climbAvg = (climb.reduceSafe(
              (final int value, final int element) => value + element,
            ) ??
            0) /
        climb.length;

    final List<String> faultMessages = (e["faults"] as List<dynamic>)
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
      drivetrain: e["pit"]?["drivetrain"]["title"] as String?,
      matchesClimbed: (e["matches_aggregate"]["nodes"] as List<dynamic>)
          .where(
            (final dynamic element) =>
                element["climb"]["title"] != "No attempt" &&
                element["climb"]["title"] != "Failed",
          )
          .length,
      avgBalls: (avg["tele_upper"] as double? ?? double.nan) +
          (avg["tele_lower"] as double? ?? double.nan) +
          (avg["auto_upper"] as double? ?? double.nan) +
          (avg["auto_lower"] as double? ?? double.nan),
      autoBallAvg: (avg["auto_upper"] as double? ?? double.nan) +
          (avg["auto_lower"] as double? ?? double.nan),
      amountOfMatches: amountOfMatches,
      team: LightTeam.fromJson(e),
      firstListIndex: e["first_picklist_index"] as int,
      secondListIndex: e["second_picklist_index"] as int,
      taken: e["taken"] as bool,
      autoLower: avg["auto_lower"] as double? ?? double.nan,
      autoUpper: avg["auto_upper"] as double? ?? double.nan,
      autoMissed: avg["auto_missed"] as double? ?? double.nan,
      teleLower: avg["tele_lower"] as double? ?? double.nan,
      teleUpper: avg["tele_upper"] as double? ?? double.nan,
      teleMissed: avg["tele_missed"] as double? ?? double.nan,
      maxClimbTitle:
          ((e["matches_aggregate"]["nodes"] as List<dynamic>).reduceSafe(
                (final dynamic value, final dynamic element) =>
                    (value["climb"]["points"] as int) >
                            (element["climb"]["points"] as int)
                        ? value
                        : element,
              )?["climb"]?["title"] as String?) ??
              "No data",
      avgBallPoints: avgBallPoints,
      avgClimbPoints: climbAvg,
      faultMessages: faultMessages.isEmpty ? null : faultMessages,
      robotMatchStatusToAmount: <RobotMatchStatus, int>{
        for (final RobotMatchStatus i in RobotMatchStatus.values)
          i: robotMatchStatuses
              .where(
                (final RobotMatchStatus element) => element == i,
              )
              .length
      },
    );
  }).toList();
  return teams;
}
