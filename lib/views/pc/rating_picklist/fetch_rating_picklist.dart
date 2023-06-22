import "package:orbit_standard_library/orbit_standard_library.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/rating_picklist/rating_pick_list_widget.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

Stream<List<RatingPickListTeam>> fetchRatingPicklist() {
  final GraphQLClient client = getClient();
  const String query = """
subscription My {
  team {
    colors_index
    defense_picklist_index
    drive_picklist_index
    feeder_picklist_index
    ground_picklist_index
    id
    name
    number
    taken
    _2023_pit{
      drivetrain{
        title
      }
    }
      faults{
      message
  }
    _2023_specifics_aggregate {
   	aggregate{
      avg{
        ground_rating
        defense_rating
 					feeder_rating
        drive_rating
      }
    }
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
  final Stream<QueryResult<List<RatingPickListTeam>>> result = client.subscribe(
    SubscriptionOptions<List<RatingPickListTeam>>(
      document: gql(query),
      parserFn: parse,
    ),
  );

  return result.map(
    (final QueryResult<List<RatingPickListTeam>> event) =>
        event.mapQueryResult(),
  );
}

List<RatingPickListTeam> parse(final Map<String, dynamic> pickListTeams) {
  final List<RatingPickListTeam> teams =
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
        1;
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
              (final dynamic node) => robotMatchStatusTitleToEnum(
                node["robot_match_status"]["title"] as String,
              ),
            )
            .toList();
    return RatingPickListTeam(
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
      defenseListIndex: team["defense_picklist_index"] as int,
      driveListIndex: team["drive_picklist_index"] as int,
      feederListIndex: team["feeder_picklist_index"] as int,
      groundListIndex: team["ground_picklist_index"] as int,
      taken: team["taken"] as bool,
      defenseRating: (team["_2023_specifics_aggregate"]["aggregate"]["avg"]
              ["defense_rating"] as double?) ??
          0,
      driveRating: (team["_2023_specifics_aggregate"]["aggregate"]["avg"]
              ["drive_rating"] as double?) ??
          0,
      feederRating: (team["_2023_specifics_aggregate"]["aggregate"]["avg"]
              ["feeder_rating"] as double?) ??
          0,
      groundRating: (team["_2023_specifics_aggregate"]["aggregate"]["avg"]
              ["ground_rating"] as double?) ??
          0,
      maxBalanceTitle:
          ((team["technical_matches_aggregate"]["nodes"] as List<dynamic>).fold(
        "No data",
        (final dynamic maxNode, final dynamic newNode) =>
            (maxNode["auto_balance"]["auto_points"] as int) >
                    (newNode["auto_balance"]["auto_points"] as int)
                ? maxNode
                : newNode,
      )["auto_balance"]["title"] as String),
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
