import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/common/dashboard_scaffold.dart";
import "package:scouting_frontend/views/pc/status/fetch_status.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/team_info_screen.dart";

class StatusScreen extends StatefulWidget {
  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  String title = "_2023_technical_match_v3";
  bool isPreScouting = false;
  @override
  Widget build(final BuildContext context) => DashboardScaffold(
        body: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: DashboardCard(
            titleWidgets: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ToggleButtons(
                  children: <Widget>[
                    const Text("Technic"),
                    const Text("Locations"),
                    const Text("Specific"),
                    const Text("Pre")
                  ]
                      .map(
                        (final Widget text) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: text,
                        ),
                      )
                      .toList(),
                  isSelected: <bool>[
                    title == "_2023_technical_match_v3",
                    title == "_2023_secondary_technical",
                    title == "_2023_specific",
                    isPreScouting
                  ],
                  onPressed: (final int pressedIndex) {
                    if (pressedIndex == 0) {
                      setState(() {
                        title = "_2023_technical_match_v3";
                      });
                    } else if (pressedIndex == 1) {
                      setState(() {
                        title = "_2023_secondary_technical";
                      });
                    } else if (pressedIndex == 2) {
                      setState(() {
                        title = "_2023_specific";
                      });
                    } else if (pressedIndex == 3) {
                      setState(() {
                        isPreScouting = !isPreScouting;
                      });
                    }
                  },
                ),
              ),
            ],
            title: "",
            body:
                isPreScouting ? PreScoutingStatus(title) : RegularStatus(title),
          ),
        ),
      );
}

class PreScoutingStatus extends StatelessWidget {
  const PreScoutingStatus(this.title);
  final String title;
  @override
  Widget build(final BuildContext context) =>
      StreamBuilder<List<StatusItem<LightTeam, String>>>(
        stream: fetchPreScoutingStatus(title),
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
                      (final LightTeam team) => !matches
                          .map(
                            (final StatusItem<LightTeam, String> statusItem) =>
                                statusItem.identifier,
                          )
                          .contains(team),
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
              getTitle: (final StatusItem<LightTeam, String> statusItem) =>
                  Text(
                "${statusItem.identifier.number} ${statusItem.identifier.name}",
              ),
              getValueBox: (
                final String scouter,
                final StatusItem<LightTeam, String> item,
              ) =>
                  Text(
                scouter,
              ),
              items: matches..addAll(teamsNotInData),
              validate: (final StatusItem<LightTeam, String> statusItem) =>
                  statusItem.values.length == 4,
            );
          },
          onWaiting: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
}

class RegularStatus extends StatelessWidget {
  const RegularStatus(this.title);

  final String title;

  @override
  Widget build(final BuildContext context) =>
      StreamBuilder<List<StatusItem<MatchIdentifier, StatusMatch>>>(
        stream: fetchStatus(title, context),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<List<StatusItem<MatchIdentifier, StatusMatch>>>
              snapshot,
        ) =>
            snapshot.mapSnapshot<Widget>(
          onError: (final Object? error) => Text(error.toString()),
          onNoData: () => throw Exception("No data"),
          onSuccess:
              (final List<StatusItem<MatchIdentifier, StatusMatch>> matches) =>
                  StatusList<MatchIdentifier, StatusMatch>(
            validateSpecificValue: (
              final StatusMatch scoutedMatch,
              final StatusItem<MatchIdentifier, StatusMatch> statusItem,
            ) =>
                scoutedMatch.scoutedTeam.alliancePos != -1 ? null : Colors.red,
            missingBuilder: (final StatusMatch scoutedMatch) =>
                Text(scoutedMatch.scoutedTeam.team.number.toString()),
            getTitle:
                (final StatusItem<MatchIdentifier, StatusMatch> statusItem) =>
                    Column(
              children: <Widget>[
                Text(
                  "${statusItem.identifier.isRematch ? "Re " : ""}${statusItem.identifier.type} ${statusItem.identifier.number}",
                ),
              ],
            ),
            getValueBox: (
              final StatusMatch scoutedMatch,
              final StatusItem<MatchIdentifier, StatusMatch> item,
            ) =>
                GestureDetector(
              onTap: (() => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<TeamInfoScreen>(
                      builder: (final BuildContext context) => TeamInfoScreen(
                        initalTeam: scoutedMatch.scoutedTeam.team,
                      ),
                    ),
                  )),
              child: Column(
                children: <Widget>[
                  TextByTeam(
                    match: scoutedMatch,
                    text: scoutedMatch.scoutedTeam.team.number.toString(),
                  ),
                  TextByTeam(
                    match: scoutedMatch,
                    text: scoutedMatch.scouter,
                  ),
                ],
              ),
            ),
            items: matches.reversed.toList()
              ..forEach(
                (final StatusItem<MatchIdentifier, StatusMatch> statusItem) =>
                    statusItem.values.sort(
                  (
                    final StatusMatch scoutedMatchA,
                    final StatusMatch scoutedMatchB,
                  ) =>
                      scoutedMatchA.scoutedTeam.allianceColor ==
                              scoutedMatchB.scoutedTeam.allianceColor
                          ? 0
                          : (scoutedMatchA.scoutedTeam.allianceColor ==
                                  Colors.red
                              ? 1
                              : -1),
                ),
              ),
            validate: always2(true),
          ),
          onWaiting: () => const Center(
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
        (final StatusItem<T, V> statusItemA, final StatusItem<T, V> _) =>
            validate(statusItemA) ? 1 : -1,
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
  Widget build(final BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.vertical,
        primary: false,
        child: Column(
          children: items
              .map(
                (final StatusItem<T, V> statusItem) => Card(
                  color: validate(statusItem) ? bgColor : Colors.red,
                  elevation: 2,
                  margin: const EdgeInsets.fromLTRB(
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
                          getTitle(statusItem),
                          ...statusItem.values
                              .map(
                                (
                                  final V identifier,
                                ) =>
                                    StatusBox(
                                  child: getValueBox(identifier, statusItem),
                                  backgroundColor: validateSpecificValue(
                                    identifier,
                                    statusItem,
                                  ),
                                ),
                              )
                              .toList(),
                          if (missingBuilder != null)
                            ...statusItem.missingValues.map(
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

class TextByTeam extends StatelessWidget {
  const TextByTeam({required this.match, required this.text});
  final StatusMatch match;
  final String text;
  @override
  Widget build(final BuildContext context) => Text(
        style: TextStyle(color: match.scoutedTeam.allianceColor),
        text,
      );
}

class StatusBox extends StatelessWidget {
  const StatusBox({required this.child, this.backgroundColor});
  final Widget child;
  final Color? backgroundColor;
  @override
  Widget build(final BuildContext context) => Container(
        width: 80,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(
          defaultPadding / 3,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: primaryWhite,
            width: 1,
          ),
          borderRadius: defaultBorderRadius / 2,
        ),
        child: child,
      );
}

class StatusLightTeam {
  const StatusLightTeam(
    this.allianceColor,
    this.team,
    this.alliancePos,
  );
  final LightTeam team;
  final Color allianceColor;
  final int alliancePos;
}

class StatusMatch {
  const StatusMatch({required this.scouter, required this.scoutedTeam});
  final StatusLightTeam scoutedTeam;
  final String scouter;
}
