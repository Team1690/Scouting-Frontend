import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/average_or_null.dart";
import "package:scouting_frontend/models/cycle_model.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/technical_match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class TeamList extends StatelessWidget {
  const TeamList();

  @override
  Widget build(final BuildContext context) => DashboardScaffold(
        body: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: StreamBuilder<List<_Team>>(
            stream: _fetchTeamList(context),
            builder: (
              final BuildContext context,
              final AsyncSnapshot<List<_Team>> snapshot,
            ) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              int? sortedColumn;
              bool isAscending = false;
              return snapshot.data.mapNullable(
                    (final List<_Team> data) => StatefulBuilder(
                      builder: (
                        final BuildContext context,
                        final void Function(void Function()) setState,
                      ) {
                        num reverseUnless<T extends num>(
                          final bool condition,
                          final T x,
                        ) =>
                            condition ? x : -x;

                        DataColumn column(
                          final String title,
                          final num Function(_Team) f, [
                          final String? toolTip,
                        ]) =>
                            DataColumn(
                              tooltip: toolTip,
                              label: Text(title),
                              numeric: true,
                              onSort: (final int index, final __) {
                                setState(() {
                                  isAscending =
                                      sortedColumn == index && !isAscending;
                                  sortedColumn = index;
                                  data.sort(
                                    (final _Team a, final _Team b) =>
                                        reverseUnless(
                                      isAscending,
                                      f(a).compareTo(f(b)),
                                    ).toInt(),
                                  );
                                });
                              },
                            );
                        return DashboardCard(
                          title: "Team list",
                          body: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            primary: false,
                            child: SingleChildScrollView(
                              primary: false,
                              child: DataTable(
                                sortColumnIndex: sortedColumn,
                                sortAscending: isAscending,
                                columns: <DataColumn>[
                                  const DataColumn(
                                    label: Text("Team number"),
                                    numeric: true,
                                  ),
                                  column(
                                    "Auto Gamepieces",
                                    (final _Team team) => team.autoGamepieceAvg,
                                  ),
                                  column(
                                    "Tele Gamepieces",
                                    (final _Team team) => team.teleGamepieceAvg,
                                  ),
                                  column(
                                    "Gamepiece sum",
                                    (final _Team team) => team.gamepieceAvg,
                                  ),
                                  column(
                                    "Cycles",
                                    (final _Team team) => team.avgCycles,
                                  ),
                                  column(
                                    "Cycle Time",
                                    (final _Team team) => team.avgCycleTime,
                                  ),
                                  column(
                                    "Placement Time",
                                    (final _Team team) => team.avgPlacementTime,
                                  ),
                                  column(
                                    "Feeder Time",
                                    (final _Team team) => team.avgFeederTime,
                                  ),
                                  column(
                                    "Auto balance points",
                                    (final _Team team) =>
                                        team.autoBalancePointsAvg,
                                    "Avg points / Matches Balanced / Matches played",
                                  ),
                                  column(
                                    "Endgame balance points",
                                    (final _Team team) =>
                                        team.endgameBalancePointsAvg,
                                    "Avg points / Matches Balanced / Matches played",
                                  ),
                                  column(
                                    "Auto balance percentage",
                                    (final _Team team) =>
                                        team.autoBalancePercentage,
                                  ),
                                  column(
                                    "Broken matches",
                                    (final _Team team) => team.brokenMatches,
                                  ),
                                ],
                                rows: <DataRow>[
                                  ...data.map(
                                    (final _Team team) => DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    15.0,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: team.team.color,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  team.team.number.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ...<double>[
                                          team.autoGamepieceAvg,
                                          team.teleGamepieceAvg,
                                          team.gamepieceAvg,
                                          team.avgCycles,
                                          team.avgCycleTime,
                                          team.avgPlacementTime,
                                          team.avgFeederTime,
                                        ].map(show),
                                        DataCell(
                                          Text(
                                            "${team.autoBalancePointsAvg.toStringAsFixed(1)} / ${team.matchesBalanced} / ${team.amountOfMatches}",
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            "${team.endgameBalancePointsAvg.toStringAsFixed(1)} / ${team.matchesBalanced} / ${team.amountOfMatches}",
                                          ),
                                        ),
                                        show(team.autoBalancePercentage, true),
                                        DataCell(
                                          Text(
                                            team.brokenMatches.toString(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ) ??
                  (throw Exception("No data"));
            },
          ),
        ),
      );
}

DataCell show(final double value, [final bool isPercent = false]) => DataCell(
      Text(
        value == double.nan
            ? "No data"
            : "${value.toStringAsFixed(2)}${isPercent ? "%" : ""}",
      ),
    );

class _Team {
  const _Team({
    required this.autoBalancePercentage,
    required this.autoGamepieceAvg,
    required this.teleGamepieceAvg,
    required this.gamepieceAvg,
    required this.team,
    required this.autoBalancePointsAvg,
    required this.endgameBalancePointsAvg,
    required this.brokenMatches,
    required this.amountOfMatches,
    required this.matchesBalanced,
    required this.avgCycles,
    required this.avgCycleTime,
    required this.avgPlacementTime,
    required this.avgFeederTime,
  });
  final double autoGamepieceAvg;
  final double teleGamepieceAvg;
  final double gamepieceAvg;
  final LightTeam team;
  final double autoBalancePointsAvg;
  final double endgameBalancePointsAvg;
  final double autoBalancePercentage;
  final int brokenMatches;
  final int amountOfMatches;
  final int matchesBalanced;
  final double avgCycles;
  final double avgCycleTime;
  final double avgPlacementTime;
  final double avgFeederTime;
}

Stream<List<_Team>> _fetchTeamList(final BuildContext context) => getClient()
    .subscribe(
      SubscriptionOptions<List<_Team>>(
        document: gql(query),
        parserFn: (final Map<String, dynamic> data) {
          final List<dynamic> teams = data["team"] as List<dynamic>;
          return teams.map<_Team>((final dynamic team) {
            final List<int> autoBalancePoints =
                (team["technical_matches_v3_aggregate"]["nodes"]
                        as List<dynamic>)
                    .where(
                      (final dynamic node) =>
                          node["auto_balance"] != null &&
                          node["auto_balance"]["title"] != "No Attempt",
                    )
                    .map(
                      (final dynamic node) =>
                          node["auto_balance"]["auto_points"] as int,
                    )
                    .toList();
            final List<int> endgameBalancePoints =
                (team["technical_matches_v3_aggregate"]["nodes"]
                        as List<dynamic>)
                    .where(
                      (final dynamic node) =>
                          node["endgame_balance"] != null &&
                          node["endgame_balance"]["title"] != "No Attempt",
                    )
                    .map(
                      (final dynamic node) =>
                          node["endgame_balance"]["endgame_points"] as int,
                    )
                    .toList();
            final List<RobotMatchStatus> robotMatchStatuses =
                (team["technical_matches_v3_aggregate"]["nodes"]
                        as List<dynamic>)
                    .map(
                      (final dynamic node) => titleToEnum(
                        node["robot_match_status"]["title"] as String,
                      ),
                    )
                    .toList();
            final List<String> autoBalance =
                (team["technical_matches_v3_aggregate"]["nodes"]
                        as List<dynamic>)
                    .where(
                      (final dynamic node) => node["auto_balance"] != null,
                    )
                    .map(
                      (final dynamic node) =>
                          node["auto_balance"]["title"] as String,
                    )
                    .where((final String title) => title != "No Attempt")
                    .toList();
            final double autoBalancePercentage = (autoBalance
                        .where(
                          (final String title) => title != "Failed",
                        )
                        .length /
                    autoBalance.length) *
                100;
            final dynamic avg =
                team["technical_matches_v3_aggregate"]["aggregate"]["avg"];
            final List<dynamic> matches =
                (team["technical_matches_v3"] as List<dynamic>);
            final List<dynamic> secondaries =
                team["secondary_technicals"] as List<dynamic>;
            final List<Cycle> cycles = getCycles(
              getEvents(matches, "_2023_technical_events"),
              getEvents(
                secondaries,
                "_2023_secondary_technical_events",
              ),
              context,
            );
            final double autoGamepieceAvg = avg["auto_cones_scored"] == null
                ? double.nan
                : getPieces(
                    parseByMode(
                      MatchMode.auto,
                      avg,
                    ),
                  );
            final double teleGamepieceAvg = avg["auto_cones_scored"] == null
                ? double.nan
                : getPieces(
                    parseByMode(
                      MatchMode.tele,
                      avg,
                    ),
                  );
            final double gamepieceSum = avg["auto_cones_scored"] == null
                ? double.nan
                : getPieces(parseMatch(avg));
            final double autoBalancePointAvg =
                autoBalancePoints.averageOrNull ?? double.nan;
            final double endgameBalancePointAvg =
                endgameBalancePoints.averageOrNull ?? double.nan;
            endgameBalancePoints.averageOrNull ?? double.nan;
            return _Team(
              amountOfMatches: (team["technical_matches_v3_aggregate"]["nodes"]
                      as List<dynamic>)
                  .length,
              matchesBalanced: (team["technical_matches_v3_aggregate"]["nodes"]
                      as List<dynamic>)
                  .where(
                    (final dynamic node) => node["auto_balance"] != null,
                  )
                  .map(
                    (final dynamic node) =>
                        node["auto_balance"]["title"] as String,
                  )
                  .where(
                    (final String title) =>
                        title != "No Attempt" && title != "Failed",
                  )
                  .length,
              autoBalancePercentage: autoBalancePercentage,
              brokenMatches: robotMatchStatuses
                  .where(
                    (final RobotMatchStatus robotMatchStatus) =>
                        robotMatchStatus != RobotMatchStatus.worked,
                  )
                  .length,
              autoGamepieceAvg: autoGamepieceAvg,
              teleGamepieceAvg: teleGamepieceAvg,
              gamepieceAvg: gamepieceSum,
              avgCycles: avg["auto_cones_scored"] == null
                  ? double.nan
                  : cycles.length /
                      (team["technical_matches_v3_aggregate"]["nodes"]
                              as List<dynamic>)
                          .length,
              avgCycleTime: avg["auto_cones_scored"] == null
                  ? double.nan
                  : (cycles
                              .map((final Cycle cycle) => cycle.getLength())
                              .toList()
                              .averageOrNull ??
                          double.nan) /
                      1000,
              avgPlacementTime: avg["auto_cones_scored"] == null
                  ? double.nan
                  : getPlacingTime(
                        getEvents(
                          secondaries,
                          "_2023_secondary_technical_events",
                        ),
                        getEvents(matches, "_2023_technical_events"),
                        context,
                      ) /
                      1000,
              avgFeederTime: avg["auto_cones_scored"] == null
                  ? double.nan
                  : getFeederTime(
                        getEvents(
                          secondaries,
                          "_2023_secondary_technical_events",
                        ),
                        context,
                      ) /
                      1000,
              team: LightTeam.fromJson(team),
              autoBalancePointsAvg: autoBalancePointAvg,
              endgameBalancePointsAvg: endgameBalancePointAvg,
            );
          }).toList();
        },
      ),
    )
    .map(
      (final QueryResult<List<_Team>> event) => event.mapQueryResult(),
    );

const String query = """
subscription MySubscription {
  team {
    id
    name
    number
    colors_index
    secondary_technicals {
      _2023_secondary_technical_events(order_by: {match_id: asc, timestamp: asc}) {
        event_type_id
        match_id
        timestamp
      }
      robot_match_status_id
      schedule_match_id
      scouter_name
      starting_position_id
      team_id
      id
    }
    technical_matches_v3(
      where: {ignored: {_eq: false}}
      order_by: [{match: {match_type: {order: asc}}}, {match: {match_number: asc}}, {is_rematch: asc}]
    ) {
      auto_cones_delivered
      auto_cones_failed
      auto_cones_scored
      auto_cubes_delivered
      auto_cubes_failed
      auto_cubes_scored
      tele_cones_delivered
      tele_cones_failed
      tele_cubes_delivered
      tele_cones_scored
      tele_cubes_failed
      tele_cubes_scored
      schedule_match_id
      scouter_name
      is_rematch
      match {
        match_type {
          title
        }
      }
      robot_match_status {
        title
      }
      auto_balance {
        title
        auto_points
      }
      endgame_balance {
        title
        endgame_points
      }
      match {
        match_number
      }
      _2023_technical_events(order_by: {match_id: asc, timestamp: asc}) {
        match_id
        timestamp
        event_type_id
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
      nodes {
        robot_match_status {
          title
        }
        auto_balance {
          title
          auto_points
          order
        }
        endgame_balance {
          title
          endgame_points
          order
        }
      }
    }
  }
}
""";
