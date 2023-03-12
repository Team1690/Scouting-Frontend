import "package:flutter/material.dart";
import "package:scouting_frontend/models/average_or_null.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/cycle_model.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/technical_match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_widget.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

Stream<List<PickListTeam>> fetchPicklist(final BuildContext context) {
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
    technical_matches_v3(where: {ignored: {_eq: false}}, order_by: {match: {id: asc, match_number: asc}, is_rematch: asc}) {
        auto_balance {
          title
          auto_points
        }
        auto_cones_delivered
        auto_cones_failed
        auto_cones_scored
        auto_cubes_delivered
        auto_cubes_failed
        auto_cubes_scored
        endgame_balance {
          title
          endgame_points
        }
        robot_match_status {
          title
        }
        schedule_match_id
        _2023_technical_events(order_by: {match_id: asc, timestamp: asc}) {
          event_type_id
          timestamp
        }
      }
      secondary_technicals(where: {ignored: {_eq: false}}, order_by: {match: {id: asc, match_number: asc}, is_rematch: asc}) {
        _2023_secondary_technical_events(order_by: {match_id: asc, timestamp: asc}) {
          event_type_id
          timestamp
        }
        schedule_match_id
        robot_match_status {
          title
        }
      }
    technical_matches_v3_aggregate(where: {ignored: {_eq: false}}) {
      aggregate {
        avg {
          auto_cones_delivered
          auto_cones_failed
          auto_cones_scored
          auto_cubes_delivered
          auto_cubes_failed
          auto_cubes_scored
          tele_cones_delivered
          tele_cones_failed
          tele_cones_scored
          tele_cubes_delivered
          tele_cubes_failed
          tele_cubes_scored
        }

      }
      nodes{
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
      parserFn: (final Map<String, dynamic> pickListTeams) {
        final List<PickListTeam> teams =
            (pickListTeams["team"] as List<dynamic>).map((final dynamic team) {
          final dynamic avg =
              team["technical_matches_v3_aggregate"]["aggregate"]["avg"];
          final bool nullValidator = avg["auto_cones_delivered"] == null;
          final List<Cycle> cycles = getCycles(
            getEvents(
              team["technical_matches_v3"] as List<dynamic>,
              "_2023_technical_events",
            ),
            getEvents(
              team["secondary_technicals"] as List<dynamic>,
              "_2023_secondary_technical_events",
            ),
            context,
          );
          final double avgCycles = nullValidator
              ? double.nan
              : cycles.length /
                  (team["technical_matches_v3_aggregate"]["nodes"]
                          as List<dynamic>)
                      .length;
          final double avgCycleTime = cycles
                  .map((final Cycle e) => e.getLength() / 1000)
                  .toList()
                  .averageOrNull ??
              double.nan;
          final double avgPlacementTime = getPlacingTime(
            getEvents(
              team["secondary_technicals"] as List<dynamic>,
              "_2023_secondary_technical_events",
            ),
            getEvents(
              team["technical_matches_v3"] as List<dynamic>,
              "_2023_technical_events",
            ),
            context,
          );
          final double avgFeederTime = getFeederTime(
            getEvents(
              team["secondary_technicals"] as List<dynamic>,
              "_2023_secondary_technical_events",
            ),
            context,
          );
          final List<int> autoBalance =
              (team["technical_matches_v3_aggregate"]["nodes"] as List<dynamic>)
                  .where(
                    (final dynamic node) =>
                        node["auto_balance"] != null &&
                        node["auto_balance"]["title"] != "No Attempt",
                  )
                  .map<int>(
                    (final dynamic node) =>
                        node["auto_balance"]["auto_points"] as int,
                  )
                  .toList();
          final int amountOfMatches =
              (team["technical_matches_v3_aggregate"]["nodes"] as List<dynamic>)
                  .length;
          final double autoBalanceAvg = autoBalance.averageOrNull ?? double.nan;

          final List<String> faultMessages = (team["faults"] as List<dynamic>)
              .map((final dynamic fault) => fault["message"] as String)
              .toList();
          final List<RobotMatchStatus> robotMatchStatuses =
              (team["technical_matches_v3_aggregate"]["nodes"] as List<dynamic>)
                  .map(
                    (final dynamic node) => titleToEnum(
                      node["robot_match_status"]["title"] as String,
                    ),
                  )
                  .toList();
          return PickListTeam(
            drivetrain: team["_2023_pit"]?["drivetrain"]["title"] as String?,
            matchesBalanced: (team["technical_matches_v3_aggregate"]["nodes"]
                    as List<dynamic>)
                .where(
                  (final dynamic node) =>
                      node["auto_balance"] != null &&
                      node["auto_balance"]["title"] != "No Attempt" &&
                      node["auto_balance"]["title"] != "Failed",
                )
                .length,
            avgGamepieces: nullValidator
                ? double.nan
                : getPieces(
                    parseMatch(
                      avg,
                    ),
                  ),
            amountOfMatches: amountOfMatches,
            team: LightTeam.fromJson(team),
            firstListIndex: team["first_picklist_index"] as int,
            secondListIndex: team["second_picklist_index"] as int,
            taken: team["taken"] as bool,
            maxBalanceTitle: ((team["technical_matches_v3_aggregate"]["nodes"]
                        as List<dynamic>)
                    .where((final dynamic node) => node["auto_balance"] != null)
                    .reduceSafe(
                      (final dynamic maxNode, final dynamic newNode) =>
                          (maxNode["auto_balance"]["auto_points"] as int) >
                                  (newNode["auto_balance"]["auto_points"]
                                      as int)
                              ? maxNode
                              : newNode,
                    )?["auto_balance"]?["title"] as String?) ??
                "No data",
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
            avgCycles: avgCycles,
            avgCycleTime: avgCycleTime,
            avgFeederTime: avgFeederTime / 1000,
            avgPlacementTime: avgPlacementTime / 1000,
          );
        }).toList();
        return teams;
      },
    ),
  );

  return result.map(
    (final QueryResult<List<PickListTeam>> event) => event.mapQueryResult(),
  );
}
