import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class TeamView extends StatelessWidget {
  const TeamView();

  @override
  Widget build(final BuildContext context) => DashboardScaffold(
        body: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: StreamBuilder<List<_Team>>(
            stream: fetchTeamView(),
            builder: (
              final BuildContext context,
              final AsyncSnapshot<List<_Team>> snapshot,
            ) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              int? sortedColumn;
              return snapshot.data.mapNullable(
                    (final List<_Team> data) => StatefulBuilder(
                      builder: (
                        final BuildContext context,
                        final void Function(void Function()) setState,
                      ) {
                        DataColumn column(
                          final String title,
                          final int Function(_Team, _Team) compare,
                        ) =>
                            DataColumn(
                              label: Text(title),
                              numeric: true,
                              onSort: (final int index, final __) {
                                setState(() {
                                  sortedColumn = index;
                                  data.sort(
                                    compare,
                                  );
                                });
                              },
                            );
                        return DashboardCard(
                          title: "Team view",
                          body: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            primary: false,
                            child: SingleChildScrollView(
                              primary: false,
                              child: DataTable(
                                sortColumnIndex: sortedColumn,
                                sortAscending: false,
                                columns: <DataColumn>[
                                  DataColumn(
                                    label: Text("Team number"),
                                    numeric: true,
                                  ),
                                  column(
                                    "Tele upper",
                                    (
                                      final _Team a,
                                      final _Team b,
                                    ) =>
                                        b.teleUpperAvg
                                            .compareTo(a.teleUpperAvg),
                                  ),
                                  column(
                                    "Auto upper",
                                    (
                                      final _Team a,
                                      final _Team b,
                                    ) =>
                                        b.autoUpperAvg
                                            .compareTo(a.autoUpperAvg),
                                  ),
                                  column(
                                    "Ball sum",
                                    (
                                      final _Team a,
                                      final _Team b,
                                    ) =>
                                        b.ballAvg.compareTo(a.ballAvg),
                                  ),
                                  column(
                                    "Ball points",
                                    (
                                      final _Team a,
                                      final _Team b,
                                    ) =>
                                        b.ballPointAvg
                                            .compareTo(a.ballPointAvg),
                                  ),
                                  column(
                                    "Climb points",
                                    (
                                      final _Team a,
                                      final _Team b,
                                    ) =>
                                        b.climbPointAvg
                                            .compareTo(a.climbPointAvg),
                                  ),
                                  column(
                                    "Climb percent",
                                    (
                                      final _Team a,
                                      final _Team b,
                                    ) =>
                                        b.climbPercent
                                            .compareTo(a.climbPercent),
                                  ),
                                  column(
                                    "Broken matches",
                                    (
                                      final _Team a,
                                      final _Team b,
                                    ) =>
                                        b.brokenMatches
                                            .compareTo(a.brokenMatches),
                                  ),
                                ],
                                rows: <DataRow>[
                                  ...data.map(
                                    (final _Team e) => DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                          Text(
                                            e.team.number.toString(),
                                            style:
                                                TextStyle(color: e.team.color),
                                          ),
                                        ),
                                        ...<double>[
                                          e.teleUpperAvg,
                                          e.autoUpperAvg,
                                          e.ballAvg,
                                          e.ballPointAvg,
                                          e.climbPointAvg,
                                        ].map(show),
                                        show(e.climbPercent, true),
                                        DataCell(
                                          Text(
                                            e.brokenMatches.toString(),
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
        value == -1
            ? "No data"
            : "${value.toStringAsFixed(1)}${isPercent ? "%" : ""}",
      ),
    );

class _Team {
  const _Team({
    required this.climbPercent,
    required this.autoUpperAvg,
    required this.ballAvg,
    required this.teleUpperAvg,
    required this.team,
    required this.climbPointAvg,
    required this.ballPointAvg,
    required this.brokenMatches,
  });
  final double teleUpperAvg;
  final double autoUpperAvg;
  final double ballAvg;
  final LightTeam team;
  final double ballPointAvg;
  final double climbPointAvg;
  final double climbPercent;
  final int brokenMatches;
}

Stream<List<_Team>> fetchTeamView() {
  return getClient().subscribe(SubscriptionOptions(document: gql(query))).map(
        (final QueryResult event) => event.mapQueryResult<List<_Team>>(
          (final Map<String, dynamic>? p0) =>
              p0.mapNullable<List<_Team>>((final Map<String, dynamic> data) {
                final List<dynamic> teams = data["team"] as List<dynamic>;
                return teams.map<_Team>((final dynamic e) {
                  final dynamic avg =
                      e["matches_aggregate"]["aggregate"]["avg"];
                  final List<int> climbPoints =
                      (e["matches_aggregate"]["nodes"] as List<dynamic>)
                          .map((final dynamic e) => e["climb"]["points"] as int)
                          .toList();
                  final List<RobotMatchStatus> robotMatchStatuses =
                      (e["matches_aggregate"]["nodes"] as List<dynamic>)
                          .map(
                            (final dynamic e) => titleToEnum(
                              e["robot_match_status"]["title"] as String,
                            ),
                          )
                          .toList();
                  final double teleUpper =
                      (avg["tele_upper"] as double?) ?? double.nan;
                  final double autoLower =
                      (avg["auto_lower"] as double?) ?? double.nan;
                  final double autoUpper =
                      (avg["auto_upper"] as double?) ?? double.nan;
                  final double teleLower =
                      (avg["tele_lower"] as double?) ?? double.nan;
                  final List<String> climb = (e["matches_aggregate"]["nodes"]
                          as List<dynamic>)
                      .map((final dynamic e) => e["climb"]["title"] as String)
                      .where((final String element) => element != "No attempt")
                      .toList();
                  final double climbPercent = (climb
                              .where(
                                (final String element) => element != "Failed",
                              )
                              .length /
                          climb.length) *
                      100;
                  final double ballPointAvg =
                      autoUpper * 4 + teleUpper * 2 + autoLower * 2 + teleLower;
                  final double ballSum =
                      autoUpper + teleUpper + autoLower + teleLower;
                  final double climbPointAvg = climbPoints.isEmpty
                      ? 0
                      : climbPoints.length == 1
                          ? climbPoints.single.toDouble()
                          : climbPoints.reduce(
                                (final int value, final int element) =>
                                    value + element,
                              ) /
                              climbPoints.length;
                  return _Team(
                    climbPercent: climbPercent.isNaN ? -1 : climbPercent,
                    brokenMatches: robotMatchStatuses
                        .where(
                          (final RobotMatchStatus element) =>
                              element != RobotMatchStatus.worked,
                        )
                        .length,
                    autoUpperAvg: avg["auto_upper"] as double? ?? -1,
                    ballAvg: ballSum.isNaN ? -1 : ballSum,
                    ballPointAvg: ballPointAvg.isNaN ? -1 : ballPointAvg,
                    teleUpperAvg: avg["tele_upper"] as double? ?? -1,
                    team: LightTeam.fromJson(e),
                    climbPointAvg: climbPointAvg.isNaN ? -1 : climbPointAvg,
                  );
                }).toList();
              }) ??
              (throw Exception("No data")),
        ),
      );
}

const String query = """

subscription MySubscription {
  team {
    id
    name
    number
    colors_index
    matches_aggregate {
      aggregate {
        avg {
          auto_lower
          auto_upper
          tele_upper
          tele_lower
        }
      }
      nodes {
        climb {
          title
          points
        }
        robot_match_status {
          title
        }
      }
    }
  }
}

""";