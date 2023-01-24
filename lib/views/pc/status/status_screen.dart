import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/pc/status/fetch_status.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_screen.dart";

class StatusScreen extends StatefulWidget {
  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

const double padding = 20;

class _StatusScreenState extends State<StatusScreen> {
  bool isSpecific = false;
  bool isPreScouting = false;
  @override
  Widget build(final BuildContext context) {
    return DashboardScaffold(
      body: Padding(
        padding: const EdgeInsets.all(padding),
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
                        missingValues: <String>[],
                      ),
                    )
                    .toList();

            return StatusList<LightTeam, String>(
              validateSpecificValue: (final _, final __) => null,
              pushUnvalidatedToTheTop: true,
              getTitle: (final StatusItem<LightTeam, String> e) =>
                  Text("${e.identifier.number} ${e.identifier.name}"),
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
        stream: fetchStatus(isSpecific, context),
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
            validateSpecificValue: (
              final Match match,
              final StatusItem<MatchIdentifier, Match> statusItem,
            ) =>
                match.scoutedTeam.alliancePos != -1 ? null : Colors.red,
            missingBuilder: (final Match p0) =>
                Text(p0.scoutedTeam.team.number.toString()),
            getTitle: (final StatusItem<MatchIdentifier, Match> e) => Column(
              children: <Widget>[
                Text(
                  "${e.identifier.isRematch ? "Re " : ""}${e.identifier.type} ${e.identifier.number}",
                ),
                if (!isSpecific)
                  Row(
                    children: <Widget>[
                      Text(
                        style: TextStyle(color: Colors.blue),
                        "${e.values.where((final Match element) => element.scoutedTeam.allianceColor == Colors.blue).map((final Match e) => e.scoutedTeam.points).fold<int>(0, (final int previousValue, final int element) => previousValue + element)}",
                      ),
                      Text(" - "),
                      Text(
                        style: TextStyle(color: Colors.red),
                        "${e.values.where((final Match element) => element.scoutedTeam.allianceColor == Colors.red).map((final Match e) => e.scoutedTeam.points).fold<int>(0, (final int previousValue, final int element) => previousValue + element)}",
                      )
                    ],
                  )
              ],
            ),
            getValueBox: (
              final Match match,
              final StatusItem<MatchIdentifier, Match> item,
            ) =>
                GestureDetector(
              onTap: (() => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<TeamInfoScreen>(
                      builder: (final BuildContext context) => TeamInfoScreen(
                        initalTeam: match.scoutedTeam.team,
                      ),
                    ),
                  )),
              child: Column(
                children: <Widget>[
                  TextByTeam(
                    match: match,
                    text: match.scoutedTeam.team.number.toString(),
                  ),
                  TextByTeam(
                    match: match,
                    text: match.scouter,
                  ),
                  if (!isSpecific)
                    TextByTeam(
                      match: match,
                      text: match.scoutedTeam.points.toString(),
                    ),
                ],
              ),
            ),
            items: matches.reversed.toList()
              ..forEach(
                (final StatusItem<MatchIdentifier, Match> e) => e.values.sort(
                  (final Match a, final Match b) =>
                      a.scoutedTeam.allianceColor == b.scoutedTeam.allianceColor
                          ? 0
                          : (a.scoutedTeam.allianceColor == Colors.red
                              ? 1
                              : -1),
                ),
              ),
            validate: always2(true),
          ),
          onWaiting: () => Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
}

class StatusItem<T, V> {
  const StatusItem({
    required this.identifier,
    required this.values,
    required this.missingValues,
  });
  final T identifier;
  final List<V> missingValues;
  final List<V> values;
}

class StatusList<T, V> extends StatelessWidget {
  StatusList({
    required this.items,
    required this.getTitle,
    required this.validate,
    required this.getValueBox,
    required this.validateSpecificValue,
    this.missingBuilder,
    this.pushUnvalidatedToTheTop = false,
  }) {
    if (pushUnvalidatedToTheTop) {
      items.sort(
        (final StatusItem<T, V> a, final StatusItem<T, V> b) =>
            !validate(a) ? -1 : 1,
      );
    }
  }
  final Widget Function(V)? missingBuilder;
  final List<StatusItem<T, V>> items;
  final bool Function(StatusItem<T, V>) validate;
  final Widget Function(StatusItem<T, V>) getTitle;
  final Widget Function(V, StatusItem<T, V>) getValueBox;
  final MaterialColor? Function(V, StatusItem<T, V>) validateSpecificValue;
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
                color: validate(e) ? Color(0xFF212332) : Colors.red,
                elevation: 2,
                margin: EdgeInsets.fromLTRB(
                  5,
                  0,
                  5,
                  padding,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    padding,
                    padding / 4,
                    padding,
                    padding / 4,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      padding / 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        getTitle(e),
                        ...e.values
                            .map(
                              (
                                final V match,
                              ) =>
                                  StatusBox(
                                child: getValueBox(match, e),
                                backgroundColor:
                                    validateSpecificValue(match, e),
                              ),
                            )
                            .toList(),
                        if (missingBuilder != null)
                          ...e.missingValues.map(
                            (final V match) => StatusBox(
                              child: missingBuilder!(match),
                              backgroundColor: Colors.red,
                            ),
                          )
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

class TextByTeam extends StatelessWidget {
  const TextByTeam({required this.match, required this.text});
  final Match match;
  final String text;
  @override
  Widget build(final BuildContext context) {
    return Text(
      style: TextStyle(color: match.scoutedTeam.allianceColor),
      text,
    );
  }
}

class StatusBox extends StatelessWidget {
  const StatusBox({required this.child, this.backgroundColor});
  final Widget child;
  final Color? backgroundColor;
  @override
  Widget build(final BuildContext context) {
    return Container(
      width: 80,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(
        padding / 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: child,
    );
  }
}

class StatusLightTeam {
  const StatusLightTeam(
    this.points,
    this.allianceColor,
    this.team,
    this.alliancePos,
  );
  final LightTeam team;
  final int points;
  final Color allianceColor;
  final int alliancePos;
}

class Match {
  const Match({required this.scouter, required this.scoutedTeam});
  final StatusLightTeam scoutedTeam;
  final String scouter;
}
