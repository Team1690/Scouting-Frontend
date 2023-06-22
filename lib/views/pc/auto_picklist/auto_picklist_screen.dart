import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/counter.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/selector.dart";
import "package:scouting_frontend/views/pc/auto_picklist/auto_picklist_widget.dart";
import "package:scouting_frontend/views/pc/auto_picklist/value_sliders.dart";
import "package:scouting_frontend/views/pc/picklist/fetch_picklist.dart";
import "package:scouting_frontend/views/pc/picklist/pick_list_widget.dart";

class AutoPickListScreen extends StatefulWidget {
  const AutoPickListScreen({super.key});

  @override
  State<AutoPickListScreen> createState() => _AutoPickListScreenState();
}

class _AutoPickListScreenState extends State<AutoPickListScreen> {
  bool hasValues = false;

  double gamepiecesSumValue = 0.5;
  double gamepiecesPointsValue = 0.5;
  double autoBalancePointsValue = 0.5;

  bool filterTaken = false;
  Picklists? saveAs;

  List<AutoPickListTeam> localList = <AutoPickListTeam>[];

  @override
  Widget build(final BuildContext context) => DashboardScaffold(
        body: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ValueSliders(
                  onButtonPress: (
                    final double slider0,
                    final double slider1,
                    final double slider2,
                  ) =>
                      setState(() {
                    hasValues = true;
                    gamepiecesPointsValue = slider0;
                    gamepiecesSumValue = slider1;
                    autoBalancePointsValue = slider2;
                  }),
                ),
                const SizedBox(
                  height: 10,
                ),
                SectionDivider(label: "Actions"),
                const SizedBox(
                  height: 10,
                ),
                Selector<String>(
                  options: Picklists.values
                      .map((final Picklists e) => e.title)
                      .toList(),
                  placeholder: "Save as:",
                  value: saveAs == null ? null : saveAs!.title,
                  makeItem: (final String picklist) => picklist,
                  onChange: (final String newTitle) => setState(() {
                    saveAs = Picklists.values.firstWhere(
                      (final Picklists picklists) =>
                          picklists.title == newTitle,
                    );
                  }),
                  validate: (final String unused) => null,
                ),
                RoundedIconButton(
                  color: Colors.green,
                  onPress: () => save(
                      saveAs,
                      List<PickListTeam>.from(localList.map(
                          (final AutoPickListTeam autoTeam) =>
                              autoTeam.picklistTeam)),
                      context),
                  icon: Icons.save_as,
                  onLongPress: () {},
                ),
                const SizedBox(
                  height: 10,
                ),
                ToggleButtons(
                  children: const <Text>[Text("Filter Taken")],
                  isSelected: <bool>[filterTaken],
                  onPressed: (final int unused) => setState(() {
                    filterTaken = !filterTaken;
                  }),
                ),
                hasValues
                    ? Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: StreamBuilder<List<PickListTeam>>(
                          stream: fetchPicklist(),
                          builder: (
                            final BuildContext context,
                            final AsyncSnapshot<List<PickListTeam>> snapshot,
                          ) {
                            if (snapshot.hasError) {
                              return Text(snapshot.error.toString());
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.data == null) {
                              return const Center(
                                child: Text("No Teams"),
                              );
                            }
                            final List<AutoPickListTeam> teamsList = snapshot
                                .data!
                                .map(
                                  (final PickListTeam e) => AutoPickListTeam(
                                    gamepiecePointsValue: (e
                                                .avgGamepiecePoints.isNaN
                                            ? 0
                                            : e.avgGamepiecePoints) /
                                        (snapshot.data!
                                            .map(
                                              (final PickListTeam e) =>
                                                  (e.avgGamepiecePoints.isNaN
                                                      ? 0
                                                      : e.avgGamepiecePoints),
                                            )
                                            .max),
                                    gamepieceSumValue: (e.avgGamepieces.isNaN
                                            ? 0
                                            : e.avgGamepieces) /
                                        (snapshot.data!
                                            .map(
                                              (final PickListTeam e) =>
                                                  (e.avgGamepieces.isNaN
                                                      ? 0
                                                      : e.avgGamepieces),
                                            )
                                            .max),
                                    autoBalancePointsValue: (e
                                                .avgAutoBalancePoints.isNaN
                                            ? 0
                                            : e.avgAutoBalancePoints) /
                                        (snapshot.data!
                                            .map(
                                              (final PickListTeam e) =>
                                                  (e.avgAutoBalancePoints.isNaN
                                                      ? 0
                                                      : e.avgAutoBalancePoints),
                                            )
                                            .max),
                                    picklistTeam: e,
                                  ),
                                )
                                .toList();
                            teamsList.sort(
                              (
                                final AutoPickListTeam a,
                                final AutoPickListTeam b,
                              ) =>
                                  (b.autoBalancePointsValue *
                                              autoBalancePointsValue +
                                          b.gamepiecePointsValue *
                                              gamepiecesPointsValue +
                                          b.gamepieceSumValue *
                                              gamepiecesSumValue)
                                      .compareTo(
                                a.autoBalancePointsValue *
                                        autoBalancePointsValue +
                                    a.gamepiecePointsValue *
                                        gamepiecesPointsValue +
                                    a.gamepieceSumValue * gamepiecesSumValue,
                              ),
                            );
                            localList = teamsList
                                .where((final AutoPickListTeam element) =>
                                    element.picklistTeam.taken)
                                .toList();
                            if (filterTaken) {
                              teamsList.removeWhere(
                                (final AutoPickListTeam element) =>
                                    element.picklistTeam.taken,
                              );
                            }
                            localList.insertAll(0, teamsList);
                            return AutoPickList(uiList: localList);
                          },
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      );
}

enum Picklists {
  first("First"),
  second("Second"),
  third("Third");

  const Picklists(this.title);
  final String title;
}

void save(
  final Picklists? picklist,
  final List<PickListTeam> teams, [
  final BuildContext? context,
]) async {
  if (teams.isNotEmpty && picklist != null) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 5),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Saving", style: TextStyle(color: Colors.white))
            ],
          ),
          backgroundColor: Colors.blue,
        ),
      );
    }
    final GraphQLClient client = getClient();
    const String query = """
  mutation UpdatePicklist(\$objects: [team_insert_input!]!) {
  insert_team(objects: \$objects, on_conflict: {constraint: team_pkey, update_columns: [taken, first_picklist_index, second_picklist_index,third_picklist_index]}) {
    affected_rows
    returning {
      id
    }
  }
}

  """;

    final Map<String, dynamic> vars = <String, dynamic>{
      "objects": teams
          .map((final PickListTeam e) => PickListTeam(
                firstListIndex: picklist == Picklists.first
                    ? teams.indexOf(e)
                    : e.firstListIndex,
                secondListIndex: picklist == Picklists.second
                    ? teams.indexOf(e)
                    : e.secondListIndex,
                thirdListIndex: picklist == Picklists.third
                    ? teams.indexOf(e)
                    : e.thirdListIndex,
                amountOfMatches: e.amountOfMatches,
                autoGamepieceAvg: e.autoGamepieceAvg,
                avgAutoBalancePoints: e.avgAutoBalancePoints,
                avgBalancePartners: e.avgBalancePartners,
                avgDelivered: e.avgDelivered,
                avgGamepiecePoints: e.avgGamepiecePoints,
                avgGamepieces: e.avgGamepieces,
                drivetrain: e.drivetrain,
                faultMessages: e.faultMessages,
                matchesBalanced: e.matchesBalanced,
                maxBalanceTitle: e.maxBalanceTitle,
                robotMatchStatusToAmount: e.robotMatchStatusToAmount,
                taken: e.taken,
                team: e.team,
              ))
          .map(
            (final PickListTeam e) => <String, dynamic>{
              "id": e.team.id,
              "name": e.team.name,
              "number": e.team.number,
              "colors_index": e.team.colorsIndex,
              "first_picklist_index": e.firstListIndex,
              "second_picklist_index": e.secondListIndex,
              "third_picklist_index": e.thirdListIndex,
              "taken": e.taken
            },
          )
          .toList()
    };

    final QueryResult<void> result = await client
        .mutate(MutationOptions<void>(document: gql(query), variables: vars));
    if (context != null) {
      if (result.hasException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text("Error: ${result.exception}"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 2),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Saved",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
