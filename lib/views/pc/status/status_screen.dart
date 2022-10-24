import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/pc/status/fetch_status.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class StatusScreen extends StatefulWidget {
  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool isSpecific = false;
  bool isPreScouting = false;
  @override
  Widget build(final BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: DashboardCard(
          titleWidgets: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: ToggleButtons(
                children:
                    <Widget>[Text("Technic"), Text("Specific"), Text("Pre")]
                        .map(
                          (final Widget e) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: e,
                          ),
                        )
                        .toList(),
                isSelected: <bool>[!isSpecific, isSpecific, isPreScouting],
                onPressed: (final int i) {
                  if (i == 0) {
                    setState(() {
                      isSpecific = false;
                    });
                  } else if (i == 1) {
                    setState(() {
                      isSpecific = true;
                    });
                  } else if (i == 2) {
                    setState(() {
                      isPreScouting = !isPreScouting;
                    });
                  }
                },
              ),
            ),
          ],
          title: "",
          body: isPreScouting
              ? PreScoutingStatus(isSpecific)
              : RegularStatus(isSpecific),
        ),
      ),
    );
  }
}

class PreScoutingStatus extends StatelessWidget {
  const PreScoutingStatus(this.isSpecific);
  final bool isSpecific;

  @override
  Widget build(final BuildContext context) =>
      StreamBuilder<List<StatusItem<LightTeam, String>>>(
        stream: fetchPreScoutingStatus(isSpecific),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<StatusItem<LightTeam, String>>> snapshot,
        ) =>
            snapshot.mapSnapshot<Widget>(
          onError: (final Object? error) => Text(error.toString()),
          onNoData: () => throw Exception("No data"),
          onSuccess: (final List<StatusItem<LightTeam, String>> matches) {
            final List<StatusItem<LightTeam, String>> teamsNotInData =
                TeamProvider.of(context)
                    .teams
                    .where(
                      (final LightTeam element) => !matches
                          .map(
                            (final StatusItem<LightTeam, String> e) =>
                                e.identifier,
                          )
                          .contains(element),
                    )
                    .map(
                      (final LightTeam e) => StatusItem<LightTeam, String>(
                        identifier: e,
                        values: <String>[],
                      ),
                    )
                    .toList();

            return StatusList<LightTeam, String>(
              pushUnvalidatedToTheTop: true,
              getTitle: (final StatusItem<LightTeam, String> e) =>
                  "${e.identifier.number} ${e.identifier.name}",
              getValueBox: (
                final String scouter,
                final StatusItem<LightTeam, String> item,
              ) =>
                  Text(
                scouter,
              ),
              items: matches..addAll(teamsNotInData),
              validate: (final StatusItem<LightTeam, String> e) =>
                  e.values.length == 4,
            );
          },
          onWaiting: () => Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
}

class RegularStatus extends StatelessWidget {
  const RegularStatus(this.isSpecific);

  final bool isSpecific;

  @override
  Widget build(final BuildContext context) =>
      StreamBuilder<List<StatusItem<MatchIdentifier, Match>>>(
        stream: fetchStatus(isSpecific),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<StatusItem<MatchIdentifier, Match>>>
              snapshot,
        ) =>
            snapshot.mapSnapshot<Widget>(
          onError: (final Object? error) => Text(error.toString()),
          onNoData: () => throw Exception("No data"),
          onSuccess: (final List<StatusItem<MatchIdentifier, Match>> matches) =>
              StatusList<MatchIdentifier, Match>(
            getTitle: (final StatusItem<MatchIdentifier, Match> e) =>
                "${e.identifier.isRematch ? "Re " : ""}${e.identifier.type} ${e.identifier.number}",
            getValueBox: (
              final Match match,
              final StatusItem<MatchIdentifier, Match> item,
            ) =>
                Column(
              children: <Widget>[
                Text(
                  match.team.number.toString(),
                ),
                Text(match.scouter)
              ],
            ),
            items: matches.reversed.toList(),
            validate: (final StatusItem<MatchIdentifier, Match> e) =>
                e.values.length == 6,
          ),
          onWaiting: () => Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
}

class StatusItem<T, V> {
  const StatusItem({required this.identifier, required this.values});
  final T identifier;
  final List<V> values;
}

class StatusList<T, V> extends StatelessWidget {
  StatusList({
    required this.items,
    required this.getTitle,
    required this.validate,
    required this.getValueBox,
    this.pushUnvalidatedToTheTop = false,
  }) {
    if (pushUnvalidatedToTheTop) {
      items.sort(
        (final StatusItem<T, V> a, final StatusItem<T, V> b) =>
            !validate(a) ? -1 : 1,
      );
    }
  }
  final List<StatusItem<T, V>> items;
  final bool Function(StatusItem<T, V>) validate;
  final String Function(StatusItem<T, V>) getTitle;
  final Widget Function(V, StatusItem<T, V>) getValueBox;
  final bool pushUnvalidatedToTheTop;

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      primary: false,
      child: Column(
        children: items
            .map(
              (final StatusItem<T, V> e) => Card(
                color: validate(e) ? bgColor : Colors.red,
                elevation: 2,
                margin: EdgeInsets.fromLTRB(
                  5,
                  0,
                  5,
                  defaultPadding,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    defaultPadding,
                    defaultPadding / 4,
                    defaultPadding,
                    defaultPadding / 4,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      defaultPadding / 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(getTitle(e)),
                        ...e.values
                            .map(
                              (
                                final V match,
                              ) =>
                                  Container(
                                width: 80,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(
                                  defaultPadding / 3,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: primaryWhite,
                                    width: 1,
                                  ),
                                  borderRadius: defaultBorderRadius / 2,
                                ),
                                child: getValueBox(match, e),
                              ),
                            )
                            .toList()
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class Match {
  const Match({required this.scouter, required this.team});
  final LightTeam team;
  final String scouter;
}
