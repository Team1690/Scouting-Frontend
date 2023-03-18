import "package:scouting_frontend/models/average_or_null.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_widget.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

Stream<List<PickListTeam>> fetchPicklist() {
  final GraphQLClient client = getClient();
  const String query = """
 subscription My {
  team {
    colors_index
    first_picklist_index
    id
    name
    number
    second_picklist_index
    taken
    _2023_pit{
      drivetrain{
        title
      }
    }
      faults{
      message
  }
    technical_matches_aggregate(where: {ignored: {_eq: false}}) {
      aggregate {
        avg {
          auto_cones_low
          auto_cones_mid
          auto_cones_top
          auto_cubes_low
          auto_cubes_mid
          auto_cubes_top
          tele_cones_low
          tele_cones_mid
          tele_cones_top
          tele_cubes_low
          tele_cubes_mid
          tele_cubes_top
          auto_cones_delivered
          auto_cubes_delivered
          tele_cones_delivered
          tele_cubes_delivered
          balanced_with
        }
      }
      nodes {
         auto_balance{
          title
          auto_points
        }
        endgame_balance{
          title
          endgame_points
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
      (pickListTeams["team"] as List<dynamic>).map((final dynamic team) {
    final dynamic avg = team["technical_matches_aggregate"]["aggregate"]["avg"];
    final bool nullValidator = avg["auto_cones_top"] == null;
    final double avgAutoDelivered = nullValidator
        ? double.nan
        : (avg["auto_cones_delivered"] as double) +
            (avg["auto_cubes_delivered"] as double);
    final double avgDelivered = nullValidator
        ? double.nan
        : (avgAutoDelivered +
            (avg["tele_cones_delivered"] as double) +
            (avg["tele_cubes_delivered"] as double));
    final double avgGamepiecePoints = nullValidator
        ? double.nan
        : getPoints(
            parseMatch(
              avg,
            ),
          );
    final double avgBalancePartners = (avg["balanced_with"] as double?)
            .mapNullable((final double p0) => p0 + 1) ??
        0;
    final List<int> autoBalance =
        (team["technical_matches_aggregate"]["nodes"] as List<dynamic>)
            .where(
              (final dynamic node) =>
                  node["robot_match_status"]["title"] != "Didn't come to field"
                      ? node["auto_balance"]["title"] != "No attempt"
                      : false,
            )
            .map<int>(
              (final dynamic node) =>
                  node["auto_balance"]["auto_points"] as int,
            )
            .toList();
    final int amountOfMatches =
        (team["technical_matches_aggregate"]["nodes"] as List<dynamic>).length;
    final double autoBalanceAvg = autoBalance.averageOrNull ?? double.nan;

    final List<String> faultMessages = (team["faults"] as List<dynamic>)
        .map((final dynamic fault) => fault["message"] as String)
        .toList();
    final List<RobotMatchStatus> robotMatchStatuses =
        (team["technical_matches_aggregate"]["nodes"] as List<dynamic>)
            .map(
              (final dynamic node) => titleToEnum(
                node["robot_match_status"]["title"] as String,
              ),
            )
            .toList();
    return PickListTeam(
      avgBalancePartners: avgBalancePartners,
      drivetrain: team["_2023_pit"]?["drivetrain"]["title"] as String?,
      matchesBalanced:
          (team["technical_matches_aggregate"]["nodes"] as List<dynamic>)
              .where(
                (final dynamic node) => node["robot_match_status"]["title"] !=
                        "Didn't come to field"
                    ? node["auto_balance"]["title"] != "No attempt" &&
                        node["auto_balance"]["title"] != "Failed"
                    : false,
              )
              .length,
      avgDelivered: avgDelivered,
      avgGamepieces: nullValidator
          ? double.nan
          : getPieces(
                parseMatch(
                  avg,
                ),
              ) -
              avgDelivered,
      autoGamepieceAvg: nullValidator
          ? double.nan
          : getPieces(
                parseByMode(
                  MatchMode.auto,
                  avg,
                ),
              ) -
              avgAutoDelivered,
      amountOfMatches: amountOfMatches,
      team: LightTeam.fromJson(team),
      firstListIndex: team["first_picklist_index"] as int,
      secondListIndex: team["second_picklist_index"] as int,
      taken: team["taken"] as bool,
      maxBalanceTitle:
          ((team["technical_matches_aggregate"]["nodes"] as List<dynamic>)
                  .reduceSafe(
                (final dynamic maxNode, final dynamic newNode) =>
                    (maxNode["auto_balance"]["auto_points"] as int) >
                            (newNode["auto_balance"]["auto_points"] as int)
                        ? maxNode
                        : newNode,
              )?["auto_balance"]?["title"] as String?) ??
              "No data",
      avgGamepiecePoints: avgGamepiecePoints,
      avgAutoBalancePoints: autoBalanceAvg,
      faultMessages: faultMessages.isEmpty ? null : faultMessages,
      robotMatchStatusToAmount: <RobotMatchStatus, int>{
        for (final RobotMatchStatus status in RobotMatchStatus.values)
          status: robotMatchStatuses
              .where(
                (final RobotMatchStatus robotMatchStatus) =>
                    robotMatchStatus == status,
              )
              .length
      },
    );
  }).toList();
  return teams;
}
