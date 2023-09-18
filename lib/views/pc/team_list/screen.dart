import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/match_model.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:orbit_standard_library/orbit_standard_library.dart";

class TeamList extends StatelessWidget {
  const TeamList();

  @override
  Widget build(final BuildContext context) => DashboardScaffold(
        body: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: StreamBuilder<List<_Team>>(
            stream: _fetchTeamList(),
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
                                    "Gamepieces Scored",
                                    (final _Team team) => team.gamepieceAvg,
                                  ),
                                  column(
                                    "Gamepieces Delivered",
                                    (final _Team team) => team.deliveredAvg,
                                  ),
                                  column(
                                    "Gamepiece points",
                                    (final _Team team) =>
                                        team.gamepiecePointAvg,
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
                                          team.deliveredAvg,
                                          team.gamepiecePointAvg,
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
                                  ),
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
        value.isNaN
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
    required this.gamepiecePointAvg,
    required this.brokenMatches,
    required this.amountOfMatches,
    required this.matchesBalanced,
    required this.deliveredAvg,
  });
  final double autoGamepieceAvg;
  final double teleGamepieceAvg;
  final double gamepieceAvg;
  final double deliveredAvg;
  final LightTeam team;
  final double gamepiecePointAvg;
  final double autoBalancePointsAvg;
  final double endgameBalancePointsAvg;
  final double autoBalancePercentage;
  final int brokenMatches;
  final int amountOfMatches;
  final int matchesBalanced;
}

Stream<List<_Team>> _fetchTeamList() => getClient()
    .subscribe(
      SubscriptionOptions<List<_Team>>(
        document: gql(query),
        parserFn: (final Map<String, dynamic> data) {
          final List<dynamic> teams = data["team"] as List<dynamic>;
          return teams.map<_Team>((final dynamic team) {
            final List<int> autoBalancePoints =
                (team["technical_matches_aggregate"]["nodes"] as List<dynamic>)
                    .where(
                      (final dynamic node) =>
                          node["auto_balance"]["title"] != "No attempt",
                    )
                    .map(
                      (final dynamic node) =>
                          node["auto_balance"]["auto_points"] as int,
                    )
                    .toList();
            final List<int> endgameBalancePoints =
                (team["technical_matches_aggregate"]["nodes"] as List<dynamic>)
                    .where(
                      (final dynamic node) =>
                          node["endgame_balance"]["title"] != "No attempt",
                    )
                    .map(
                      (final dynamic node) =>
                          node["endgame_balance"]["endgame_points"] as int,
                    )
                    .toList();
            final List<RobotMatchStatus> robotMatchStatuses =
                (team["technical_matches_aggregate"]["nodes"] as List<dynamic>)
                    .map(
                      (final dynamic node) => robotMatchStatusTitleToEnum(
                        node["robot_match_status"]["title"] as String,
                      ),
                    )
                    .toList();
            final List<String> autoBalance =
                (team["technical_matches_aggregate"]["nodes"] as List<dynamic>)
                    .map(
                      (final dynamic node) =>
                          node["auto_balance"]["title"] as String,
                    )
                    .where((final String title) => title != "No attempt")
                    .toList();
            final double autoBalancePercentage = (autoBalance
                        .where(
                          (final String title) => title != "Failed",
                        )
                        .length /
                    autoBalance.length) *
                100;
            final dynamic avg =
                team["technical_matches_aggregate"]["aggregate"]["avg"];
            final double autoGamepieceDelivered = avg["auto_cones_top"] == null
                ? double.nan
                : (avg["auto_cones_delivered"] as double) +
                    (avg["auto_cubes_delivered"] as double);
            final double teleGamepieceDelivered = avg["auto_cones_top"] == null
                ? double.nan
                : (avg["tele_cones_delivered"] as double) +
                    (avg["tele_cubes_delivered"] as double);
            final double gamepiecePointsAvg = avg["auto_cones_top"] == null
                ? double.nan
                : getPoints(parseMatch(avg));
            final double autoGamepieceAvg = avg["auto_cones_top"] == null
                ? double.nan
                : getPieces(
                    parseByMode(
                      MatchMode.auto,
                      avg,
                    ),
                  );
            final double teleGamepieceAvg = avg["auto_cones_top"] == null
                ? double.nan
                : getPieces(
                    parseByMode(
                      MatchMode.tele,
                      avg,
                    ),
                  );
            final double gamepieceSum = avg["auto_cones_top"] == null
                ? double.nan
                : getPieces(parseMatch(avg));
            final double autoBalancePointAvg =
                autoBalancePoints.averageOrNull ?? double.nan;
            final double endgameBalancePointAvg =
                endgameBalancePoints.averageOrNull ?? double.nan;
            endgameBalancePoints.averageOrNull ?? double.nan;
            return _Team(
              amountOfMatches: (team["technical_matches_aggregate"]["nodes"]
                      as List<dynamic>)
                  .length,
              matchesBalanced: (team["technical_matches_aggregate"]["nodes"]
                      as List<dynamic>)
                  .map(
                    (final dynamic node) =>
                        node["auto_balance"]["title"] as String,
                  )
                  .where(
                    (final String title) =>
                        title != "No attempt" && title != "Failed",
                  )
                  .length,
              autoBalancePercentage: autoBalancePercentage,
              brokenMatches: robotMatchStatuses
                  .where(
                    (final RobotMatchStatus robotMatchStatus) =>
                        robotMatchStatus != RobotMatchStatus.worked,
                  )
                  .length,
              autoGamepieceAvg: autoGamepieceAvg - autoGamepieceDelivered,
              teleGamepieceAvg: teleGamepieceAvg,
              gamepieceAvg: gamepieceSum -
                  autoGamepieceDelivered -
                  teleGamepieceDelivered,
              deliveredAvg: autoGamepieceDelivered + teleGamepieceDelivered,
              gamepiecePointAvg: gamepiecePointsAvg,
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
          tele_cones_delivered
          auto_cubes_delivered
          tele_cubes_delivered
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
