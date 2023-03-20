import "dart:math";

import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";

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
      text: "${widget.initialTeam?.number} ${widget.initialTeam?.name}",
    );
  }

  @override
  Widget build(final BuildContext context) => SizedBox(
        width: 100,
        height: double.infinity,
        child: AlertDialog(
          title: const Text("Check Balances"),
          content: Column(
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
              FloatingActionButton(
                onPressed: () {
                  if (!(firstTeam == null ||
                      secondTeam == null ||
                      thirdTeam == null)) {
                    setState(() {
                      isVisible = true;
                    });
                  }
                },
              ),
              isVisible
                  ? BalanceCheckResults(firstTeam!, secondTeam!, thirdTeam!)
                  : const Text("Please press the button after inputing teams"),
            ],
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
          () => <String, dynamic>{
            "first_team": fetchPit(firstTeam, context),
            "second_team": fetchPit(secondTeam, context),
            "third_team": fetchPit(thirdTeam, context),
          },
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
                final int firstTeamWidthInMid = min(
                  (teams["first_team"]["width"] as int),
                  (teams["first_team"]["length"] as int),
                );
                final int secondTeamWidthInMid = min(
                  (teams["second_team"]["width"] as int),
                  (teams["second_team"]["length"] as int),
                );
                final int thirdTeamWidthInMid = min(
                  (teams["third_team"]["width"] as int),
                  (teams["third_team"]["length"] as int),
                );
                final double firstTeamWidthInSide = firstTeamWidthInMid -
                    (firstTeamWidthInMid -
                            (teams["first_team"]["space_between_wheels"]
                                as int)) /
                        2;
                final double secondTeamWidthInSide = secondTeamWidthInMid -
                    (secondTeamWidthInMid -
                            (teams["second_team"]["space_between_wheels"]
                                as int)) /
                        2;
                final double thirdTeamWidthInSide = thirdTeamWidthInMid -
                    (thirdTeamWidthInMid -
                            (teams["third_team"]["space_between_wheels"]
                                as int)) /
                        2;
                return SizedBox(
                  child: AlertDialog(
                    content: Column(
                      children: <Widget>[
                        Text(
                          "First Team: ${firstTeam.number} ${firstTeam.name}",
                        ),
                        Text(
                          "Second Team: ${secondTeam.number} ${secondTeam.name}",
                        ),
                        Text(
                          "Third Team: ${thirdTeam.number} ${thirdTeam.name}",
                        ),
                        Text(
                          "Can Balance With ${firstTeam.number} In The Middle: ${(secondTeamWidthInSide + thirdTeamWidthInSide + firstTeamWidthInMid) < 180 ? "Yes" : "No"}",
                        ),
                        Text(
                          "Can Balance With ${secondTeam.number} In The Middle: ${(firstTeamWidthInSide + thirdTeamWidthInSide + secondTeamWidthInMid) < 180 ? "Yes" : "No"}",
                        ),
                        Text(
                          "Can Balance With ${thirdTeam.number} In The Middle: ${(secondTeamWidthInSide + firstTeamWidthInSide + thirdTeamWidthInMid) < 180 ? "Yes" : "No"}",
                        )
                      ],
                    ),
                  ),
                );
              }) ??
              const Text("No data available");
        },
      );
}

Future<Map<String, dynamic>?> fetchPit(
  final LightTeam teamForQuery,
  final BuildContext context,
) async {
  final GraphQLClient client = getClient();

  final QueryResult<Map<String, dynamic>?> result = await client.query(
    QueryOptions<Map<String, dynamic>?>(
      parserFn: (final Map<String, dynamic> team) {
        //couldn't use map nullable because team["team_by_pk"] is dynamic
        final Map<String, dynamic> teamByPk = team["team_by_pk"] != null
            ? team["team_by_pk"] as Map<String, dynamic>
            : throw Exception("that team doesnt exist");
        final Map<String, dynamic>? pit =
            (teamByPk["_2023_pit"] as Map<String, dynamic>?);
        return pit.mapNullable(
          (final Map<String, dynamic> pitTable) => <String, dynamic>{
            "weight": pitTable["weight"],
            "width": pitTable["width"],
            "spaceBetweenWheels": pitTable["space_between_wheels"],
            "length": pitTable["length"],
            "driveMotorAmount": pitTable["drive_motor_amount"],
            "driveWheelType": pitTable["drive_wheel_type"],
          },
        );
      },
      document: gql(pitTeamsQuery),
      variables: <String, dynamic>{
        "id": teamForQuery.id,
      },
    ),
  );
  return result.mapQueryResult();
}

const String pitTeamsQuery = """
query TeamInfo(\$id: Int!) {
  team_by_pk(id: \$id) {
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
