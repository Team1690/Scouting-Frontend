import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/helpers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class TeamList extends StatelessWidget {
  const TeamList();

  @override
  Widget build(final BuildContext context) => DashboardScaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
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
                return Center(
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
                                  DataColumn(
                                    label: Text("Team number"),
                                    numeric: true,
                                  ),
                                  column(
                                    "Tele upper",
                                    (final _Team a) => a.teleUpperAvg,
                                  ),
                                  column(
                                    "Auto upper",
                                    (final _Team a) => a.autoUpperAvg,
                                  ),
                                  column(
                                    "Ball sum",
                                    (final _Team a) => a.ballAvg,
                                  ),
                                  column(
                                    "Ball points",
                                    (final _Team a) => a.ballPointAvg,
                                  ),
                                  column(
                                    "Climb points",
                                    (final _Team a) => a.climbPointAvg,
                                    "Avg points / Matches Climbed / Matches played",
                                  ),
                                  column(
                                    "Max climb",
                                    (final _Team a) => a.maxClimb.order,
                                  ),
                                  column(
                                    "Climb percent",
                                    (final _Team a) => a.climbPercent,
                                  ),
                                  column(
                                    "Broken matches",
                                    (final _Team a) => a.brokenMatches,
                                  ),
                                ],
                                rows: <DataRow>[
                                  ...data.map(
                                    (final _Team e) => DataRow(
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
                                                      color: e.team.color,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  e.team.number.toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ...<double>[
                                          e.teleUpperAvg,
                                          e.autoUpperAvg,
                                          e.ballAvg,
                                          e.ballPointAvg,
                                        ].map(show),
                                        DataCell(
                                          Text(
                                            "${e.climbPointAvg.toStringAsFixed(1)} / ${e.matchesClimbed} / ${e.amountOfMatches}",
                                          ),
                                        ),
                                        DataCell(Text(e.maxClimb.title)),
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
            : "${value.toStringAsFixed(2)}${isPercent ? "%" : ""}",
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
    required this.amountOfMatches,
    required this.matchesClimbed,
    required this.maxClimb,
  });
  final MaxClimb maxClimb;
  final double teleUpperAvg;
  final double autoUpperAvg;
  final double ballAvg;
  final LightTeam team;
  final double ballPointAvg;
  final double climbPointAvg;
  final double climbPercent;
  final int brokenMatches;
  final int amountOfMatches;
  final int matchesClimbed;
}

Stream<List<_Team>> _fetchTeamList() {
  return getClient()
      .subscribe(
        SubscriptionOptions<List<_Team>>(
          document: gql(query),
          parserFn: (final Map<String, dynamic> data) {
            final List<dynamic> teams = data["team"] as List<dynamic>;
            return teams.map<_Team>((final dynamic e) {
              final dynamic avg = e["matches_aggregate"]["aggregate"]["avg"];
              final List<int> climbPoints =
                  (e["matches_aggregate"]["nodes"] as List<dynamic>)
                      .where(
                        (final dynamic element) =>
                            element["climb"]["title"] != "No attempt",
                      )
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
              final List<dynamic> climbs =
                  (e["matches_aggregate"]["nodes"] as List<dynamic>)
                      .map<dynamic>((final dynamic e) => e["climb"])
                      .toList();
              final dynamic maxClimb = climbs.reduceSafe(
                (final dynamic value, final dynamic element) =>
                    (value["points"] as int) > (element["points"] as int)
                        ? value
                        : element,
              );
              return _Team(
                amountOfMatches:
                    (e["matches_aggregate"]["nodes"] as List<dynamic>).length,
                matchesClimbed:
                    (e["matches_aggregate"]["nodes"] as List<dynamic>)
                        .map((final dynamic e) => e["climb"]["title"] as String)
                        .where(
                          (final String element) =>
                              element != "No attempt" && element != "Failed",
                        )
                        .length,
                maxClimb: MaxClimb(
                  order: maxClimb == null ? -1 : maxClimb["order"] as int,
                  title: maxClimb == null
                      ? "Never climbed"
                      : maxClimb["title"] as String,
                ),
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
          },
        ),
      )
      .map(
        (final QueryResult<List<_Team>> event) => event.mapQueryResult(),
      );
}

class MaxClimb {
  const MaxClimb({required this.order, required this.title});
  final int order;
  final String title;
}

const String query = """


subscription MySubscription {
  team {
    id
    name
    number
    colors_index
    matches_aggregate(where: {ignored: {_eq: false}}) {
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
          order
        }
        robot_match_status {
          title
        }
      }
    }
  }
}

""";
