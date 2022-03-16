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
          child: FutureBuilder<List<TeamViewTeam>>(
            future: fetchTeamView(),
            builder: (
              final BuildContext context,
              final AsyncSnapshot<List<TeamViewTeam>> snapshot,
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
                    (final List<TeamViewTeam> data) => StatefulBuilder(
                      builder: (
                        final BuildContext context,
                        final void Function(void Function()) setState,
                      ) {
                        DataColumn column(
                          final String title,
                          final int Function(TeamViewTeam, TeamViewTeam)
                              compare,
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
                                      final TeamViewTeam a,
                                      final TeamViewTeam b,
                                    ) =>
                                        b.teleUpperAvg
                                            .compareTo(a.teleUpperAvg),
                                  ),
                                  column(
                                    "Auto upper",
                                    (
                                      final TeamViewTeam a,
                                      final TeamViewTeam b,
                                    ) =>
                                        b.autoUpperAvg
                                            .compareTo(a.autoUpperAvg),
                                  ),
                                  column(
                                    "Ball sum",
                                    (
                                      final TeamViewTeam a,
                                      final TeamViewTeam b,
                                    ) =>
                                        b.ballAvg.compareTo(a.ballAvg),
                                  ),
                                  column(
                                    "Ball points",
                                    (
                                      final TeamViewTeam a,
                                      final TeamViewTeam b,
                                    ) =>
                                        b.ballPointAvg
                                            .compareTo(a.ballPointAvg),
                                  ),
                                  column(
                                    "Climb points",
                                    (
                                      final TeamViewTeam a,
                                      final TeamViewTeam b,
                                    ) =>
                                        b.climbPointAvg
                                            .compareTo(a.climbPointAvg),
                                  ),
                                  column(
                                    "Climb percent",
                                    (
                                      final TeamViewTeam a,
                                      final TeamViewTeam b,
                                    ) =>
                                        b.climbPercent
                                            .compareTo(a.climbPercent),
                                  ),
                                  column(
                                    "Broken matches",
                                    (
                                      final TeamViewTeam a,
                                      final TeamViewTeam b,
                                    ) =>
                                        b.brokenMatches
                                            .compareTo(a.brokenMatches),
                                  ),
                                ],
                                rows: <DataRow>[
                                  ...data.map(
                                    (final TeamViewTeam e) => DataRow(
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

class TeamViewTeam {
  const TeamViewTeam({
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

Future<List<TeamViewTeam>> fetchTeamView() async {
  final QueryResult event =
      await getClient().query(QueryOptions(document: gql(query)));
  return event.mapQueryResult<List<TeamViewTeam>>(
    (final Map<String, dynamic>? p0) =>
        p0.mapNullable<List<TeamViewTeam>>((final Map<String, dynamic> data) {
          final List<dynamic> teams = data["team"] as List<dynamic>;
          return teams.map<TeamViewTeam>((final dynamic e) {
            final dynamic avg = e["matches_aggregate"]["aggregate"]["avg"];
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
            final List<String> climb =
                (e["matches_aggregate"]["nodes"] as List<dynamic>)
                    .map((final dynamic e) => e["climb"]["title"] as String)
                    .where((final String element) => element != "No attempt")
                    .toList();
            final double climbPercent = (climb
                        .where((final String element) => element != "Failed")
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
            return TeamViewTeam(
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
  );
}

const String query = """

query MySubscription {
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
