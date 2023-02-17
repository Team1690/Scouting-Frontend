import "package:flutter/material.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";
import "package:scouting_frontend/models/matches_provider.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/teams_search_box.dart";

class TeamAndMatchSelection extends StatefulWidget {
  const TeamAndMatchSelection({
    required this.buildWithoutTeam,
    required this.buildWithTeam,
    required this.onChange,
  });
  final Widget Function(
    BuildContext context,
    LightTeam team,
    Widget searchBox,
    void Function() resetSearchbox,
  ) buildWithTeam;
  final Widget Function(
    Widget searchBox,
    void Function() resetTeam,
  ) buildWithoutTeam;
  final void Function(
    ScheduleMatch,
    LightTeam?,
  ) onChange;
  @override
  State<TeamAndMatchSelection> createState() => TeamAndMatchSelectionState();
}

class TeamAndMatchSelectionState extends State<TeamAndMatchSelection> {
  final TextEditingController matchController = TextEditingController();
  final TextEditingController teamNumberController = TextEditingController();
  ScheduleMatch? scheduleMatch;
  List<LightTeam> teams = <LightTeam>[];
  LightTeam? team;
  late final Map<String, int> provider =
      IdProvider.of(context).matchType.nameToId;
  bool isUnofficial(final ScheduleMatch match) => <int>[
        provider["Practice"]!,
        provider["Pre scouting"]!,
      ].contains(match.matchTypeId);

  @override
  Widget build(final BuildContext context) {
    return TeamsSearchBox(
      buildWithoutTeam: (
        final Widget searchBox,
        final void Function() resetSearchbox,
      ) =>
          widget.buildWithoutTeam(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (MatchesProvider.of(context).matches.isEmpty)
              Text("No matches found :(")
            else
              MatchSearchBox(
                typeAheadController: matchController,
                matches: MatchesProvider.of(context).matches,
                onChange: (final ScheduleMatch selectedMatch) {
                  setState(() {
                    scheduleMatch = selectedMatch;
                    teams = isUnofficial(selectedMatch)
                        ? TeamProvider.of(context).teams
                        : <LightTeam>[
                            ...selectedMatch.blueAlliance,
                            ...selectedMatch.redAlliance
                          ];
                    teamNumberController.clear();
                    team = null;
                    resetSearchbox();
                    widget.onChange(selectedMatch, null);
                  });
                },
              ),
            if (scheduleMatch != null) searchBox
          ],
        ),
        () {
          setState(() {
            matchController.clear();
            resetSearchbox();
            teamNumberController.clear();
          });
        },
      ),
      buildWithTeam: (
        final BuildContext context,
        final LightTeam team,
        final Widget searchBox,
        final void Function() resetSearchbox,
      ) =>
          widget.buildWithTeam(
        context,
        team,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (MatchesProvider.of(context).matches.isEmpty)
              Text("No matches found :(")
            else
              MatchSearchBox(
                typeAheadController: matchController,
                matches: MatchesProvider.of(context).matches,
                onChange: (final ScheduleMatch selectedMatch) {
                  setState(() {
                    scheduleMatch = selectedMatch;
                    teams = isUnofficial(selectedMatch)
                        ? TeamProvider.of(context).teams
                        : <LightTeam>[
                            ...selectedMatch.blueAlliance,
                            ...selectedMatch.redAlliance
                          ];
                    teamNumberController.clear();
                    widget.onChange(selectedMatch, null);
                  });
                },
              ),
            if (scheduleMatch != null) searchBox
          ],
        ),
        () {
          setState(() {
            matchController.clear();
            teamNumberController.clear();
            resetSearchbox();
          });
        },
      ),
      buildSuggestion: (final LightTeam currentTeam) =>
          isUnofficial(scheduleMatch!)
              ? "${currentTeam.number} ${currentTeam.name}"
              : scheduleMatch!.getTeamStation(currentTeam) ?? "",
      teams: teams,
      onSelected: (final LightTeam team) {
        if (mounted) {
          setState(() {
            widget.onChange(scheduleMatch!, team);
          });
        }
      },
      onOutsideChange: (final LightTeam? lightTeam) {
        setState(() {
          team = null;
          teamNumberController.clear();
        });
      },
    );
  }
}

class MatchSearchBox extends StatelessWidget {
  MatchSearchBox({
    required this.matches,
    required this.onChange,
    required this.typeAheadController,
  });
  final List<ScheduleMatch> matches;
  final void Function(ScheduleMatch) onChange;
  final TextEditingController typeAheadController;
  @override
  Widget build(final BuildContext context) => Container(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: TypeAheadFormField<ScheduleMatch>(
            validator: (final String? selectedMatch) {
              if (selectedMatch == "") {
                return "Please pick a match";
              }
              return null;
            },
            textFieldConfiguration: TextFieldConfiguration(
              onSubmitted: (final String number) {
                try {
                  final ScheduleMatch match = matches.firstWhere(
                    (final ScheduleMatch match) =>
                        match.matchNumber.toString() == number,
                  );
                  onChange(match);
                  typeAheadController.text =
                      "${match.matchTypeId} ${match.matchNumber}";
                } on StateError catch (_) {
                  //ignoed
                }
              },
              onTap: typeAheadController.clear,
              controller: typeAheadController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                hintText: "Search Match",
              ),
            ),
            suggestionsCallback: (final String pattern) => matches
                .where(
                  (final ScheduleMatch match) =>
                      match.matchNumber.toString().startsWith(pattern),
                )
                .toList(),
            itemBuilder: (
              final BuildContext context,
              final ScheduleMatch suggestion,
            ) =>
                ListTile(
              title: Text(
                "${IdProvider.of(context).matchType.idToName[suggestion.matchTypeId]} ${suggestion.matchNumber}",
              ),
            ),
            transitionBuilder: (
              final BuildContext context,
              final Widget suggestionsBox,
              final AnimationController? controller,
            ) =>
                FadeTransition(
              child: suggestionsBox,
              opacity: CurvedAnimation(
                parent: controller!,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            noItemsFoundBuilder: (final BuildContext context) => Container(
              height: 60,
              child: Center(
                child: Text(
                  "No Matches Found",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            hideSuggestionsOnKeyboardHide: false,
            onSuggestionSelected: (final ScheduleMatch suggestion) {
              typeAheadController.text =
                  "${IdProvider.of(context).matchType.idToName[suggestion.matchTypeId]} ${suggestion.matchNumber}";

              onChange(
                matches[matches.indexWhere(
                  (final ScheduleMatch match) =>
                      match.matchNumber == suggestion.matchNumber,
                )],
              );
            },
          ),
        ),
      );
}
