import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/constants.dart";
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
                            return AutoPickList(uiList: teamsList);
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
