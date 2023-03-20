import "dart:math";

import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/counter.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";

class BalanceCheck extends StatefulWidget {
  const BalanceCheck([
    this.initialTeam,
  ]);
  final LightTeam? initialTeam;

  @override
  State<BalanceCheck> createState() => _ChangeMatchState();
}

class _ChangeMatchState extends State<BalanceCheck> {
  List<TextEditingController> teamControllers =
      List<TextEditingController>.generate(
    3,
    (final int i) => TextEditingController(),
  );
  final GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController numberController = TextEditingController();

  LightTeam? firstTeam;
  LightTeam? secondTeam;
  LightTeam? thirdTeam;
  bool isVisible = false;
  @override
  void initState() {
    super.initState();
    firstTeam = widget.initialTeam;

    teamControllers[0] = TextEditingController(
      text: widget.initialTeam.mapNullable(
            (final LightTeam team) => "${team.number} ${team.name}",
          ) ??
          "",
    );
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        drawer: SideNavBar(),
        appBar: AppBar(
          centerTitle: true,
          elevation: 5,
          title: const Text(
            "Orbit Scouting",
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                SectionDivider(label: "Teams"),
                TeamSelectionFuture(
                  onChange: (final LightTeam team) => firstTeam = team,
                  controller: teamControllers[0],
                ),
                TeamSelectionFuture(
                  onChange: (final LightTeam team) => secondTeam = team,
                  controller: teamControllers[1],
                ),
                TeamSelectionFuture(
                  onChange: (final LightTeam team) => thirdTeam = team,
                  controller: teamControllers[2],
                ),
                SizedBox(
                  height: 50,
                  width: 150,
                  child: RoundedIconButton(
                    icon: Icons.calculate,
                    onLongPress: () {
                      if (!(firstTeam == null ||
                          secondTeam == null ||
                          thirdTeam == null)) {
                        setState(() {
                          isVisible = true;
                        });
                      }
                    },
                    onPress: () {
                      if (!(firstTeam == null ||
                          secondTeam == null ||
                          thirdTeam == null)) {
                        setState(() {
                          isVisible = true;
                        });
                      }
                    },
                  ),
                ),
                isVisible
                    ? BalanceCheckResults(firstTeam!, secondTeam!, thirdTeam!)
                    : const Text(
                        "Please press the button after inputing teams",
                      ),
              ]
                  .expand(
                    (final Widget element) => <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      element,
                    ],
                  )
                  .toList(),
            ),
          ),
        ),
      );
}

class BalanceCheckResults extends StatelessWidget {
  BalanceCheckResults(this.firstTeam, this.secondTeam, this.thirdTeam);
  final LightTeam firstTeam;
  final LightTeam secondTeam;
  final LightTeam thirdTeam;
  @override
  Widget build(final BuildContext context) =>
      FutureBuilder<Map<String, dynamic>>(
        future: Future<Map<String, dynamic>>(
          () => fetchPit(firstTeam, secondTeam, thirdTeam, context),
        ),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<Map<String, dynamic>> snapShot,
        ) {
          if (snapShot.hasError) {
            return Center(child: Text(snapShot.error.toString()));
          } else if (snapShot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return snapShot.data
                  .mapNullable<Widget>((final Map<String, dynamic> teams) {
                final Map<String, dynamic>? firstTeamTable =
                    teams["first_team"] as Map<String, dynamic>?;
                final Map<String, dynamic>? secondTeamTable =
                    teams["second_team"] as Map<String, dynamic>?;
                final Map<String, dynamic>? thirdTeamTable =
                    teams["third_team"] as Map<String, dynamic>?;
                final int firstTeamWidthInMid = min(
                  (firstTeamTable.mapNullable(
                        (final Map<String, dynamic> p0) => p0["width"] as int,
                      ) ??
                      0),
                  (firstTeamTable.mapNullable(
                        (final Map<String, dynamic> p0) => p0["length"] as int,
                      ) ??
                      0),
                );
                final int secondTeamWidthInMid = min(
                  (secondTeamTable.mapNullable(
                        (final Map<String, dynamic> p0) => p0["width"] as int,
                      ) ??
                      0),
                  (secondTeamTable.mapNullable(
                        (final Map<String, dynamic> p0) => p0["length"] as int,
                      ) ??
                      0),
                );
                final int thirdTeamWidthInMid = min(
                  (thirdTeamTable.mapNullable(
                        (final Map<String, dynamic> p0) => p0["width"] as int,
                      ) ??
                      0),
                  (thirdTeamTable.mapNullable(
                        (final Map<String, dynamic> p0) => p0["length"] as int,
                      ) ??
                      0),
                );
                final double firstTeamWidthInSide = firstTeamWidthInMid -
                    ((firstTeamWidthInMid -
                            (firstTeamTable.mapNullable(
                                  (final Map<String, dynamic> p0) =>
                                      p0["space_between_wheels"] as int,
                                ) ??
                                0)) /
                        2);
                final double secondTeamWidthInSide = secondTeamWidthInMid -
                    (secondTeamWidthInMid -
                        ((secondTeamTable.mapNullable(
                                  (final Map<String, dynamic> p0) =>
                                      p0["space_between_wheels"] as int,
                                ) ??
                                0)) /
                            2);
                final double thirdTeamWidthInSide = thirdTeamWidthInMid -
                    (thirdTeamWidthInMid -
                        ((thirdTeamTable.mapNullable(
                                  (final Map<String, dynamic> p0) =>
                                      p0["space_between_wheels"] as int,
                                ) ??
                                0)) /
                            2);
                return Column(
                  children: <Widget>[
                    Text(
                      "Can Balance With ${firstTeam.number} In The Middle: ${(secondTeamWidthInSide + thirdTeamWidthInSide + firstTeamWidthInMid) < 243 ? "Yes" : "No"}",
                    ),
                    Text(
                      "Total Width: ${secondTeamWidthInSide + thirdTeamWidthInSide + firstTeamWidthInMid}",
                    ),
                    Text(
                      "Can Balance With ${secondTeam.number} In The Middle: ${(firstTeamWidthInSide + thirdTeamWidthInSide + secondTeamWidthInMid) < 243 ? "Yes" : "No"}",
                    ),
                    Text(
                      "Total Width: ${firstTeamWidthInSide + thirdTeamWidthInSide + secondTeamWidthInMid}",
                    ),
                    Text(
                      "Can Balance With ${thirdTeam.number} In The Middle: ${(secondTeamWidthInSide + firstTeamWidthInSide + thirdTeamWidthInMid) < 243 ? "Yes" : "No"}",
                    ),
                    Text(
                      "Total Width: ${secondTeamWidthInSide + firstTeamWidthInSide + thirdTeamWidthInMid}",
                    )
                  ],
                );
              }) ??
              const Text("No data available");
        },
      );
}

Future<Map<String, dynamic>> fetchPit(
  final LightTeam firstTeam,
  final LightTeam secondTeam,
  final LightTeam thirdTeam,
  final BuildContext context,
) async {
  final GraphQLClient client = getClient();

  final QueryResult<Map<String, dynamic>> result = await client.query(
    QueryOptions<Map<String, dynamic>>(
      parserFn: (final Map<String, dynamic> team) {
        //checking if its length 3 is equivalent to all of the data isn't null
        final List<dynamic> listOfAllTeams =
            (team["team"] as List<dynamic>).length == 3
                ? team["team"] as List<dynamic>
                : throw Exception("Please input different teams");
        if (listOfAllTeams
            .map((final dynamic e) => e["_2023_pit"] == null)
            .contains(true)) {
          throw Exception("One of the teams does not have pit data");
        }
        final List<Map<String, dynamic>> teamsTables = listOfAllTeams
            .map((final dynamic e) => e["_2023_pit"] as Map<String, dynamic>)
            .toList();
        return <String, dynamic>{
          "first_team": getTeamsData(teamsTables[0]),
          "second_team": getTeamsData(teamsTables[1]),
          "third_team": getTeamsData(teamsTables[2]),
        };
      },
      document: gql(pitTeamsQuery),
      variables: <String, dynamic>{
        "ids": <int>[firstTeam.id, secondTeam.id, thirdTeam.id],
      },
    ),
  );
  return result.mapQueryResult();
}

const String pitTeamsQuery = """
query TeamInfo(\$ids: [Int!]) {
  team(where: {id: {_in: \$ids}}) {
    _2023_pit {
      weight
      width
      space_between_wheels
      length
      drive_motor_amount
      drive_wheel_type
    }
  }
}
""";

Map<String, dynamic> getTeamsData(final Map<String, dynamic> pitTable) =>
    <String, dynamic>{
      "weight": pitTable["weight"],
      "width": pitTable["width"],
      "space_between_wheels": pitTable["space_between_wheels"],
      "length": pitTable["length"],
      "driveMotorAmount": pitTable["drive_motor_amount"],
      "driveWheelType": pitTable["drive_wheel_type"],
    };
