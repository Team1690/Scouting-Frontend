import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/common/no_team_selected.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class TeamsSearchBox extends StatefulWidget {
  TeamsSearchBox({
    required this.buildSuggestion,
    required this.teams,
    required this.buildWithTeam,
    required this.typeAheadController,
    this.dontValidate = false,
  });
  final String Function(LightTeam) buildSuggestion;
  final bool dontValidate;
  final List<LightTeam> teams;
  final Widget Function(BuildContext, LightTeam) buildWithTeam;
  final TextEditingController typeAheadController;

  @override
  State<TeamsSearchBox> createState() => _TeamsSearchBoxState();
}

class _TeamsSearchBoxState extends State<TeamsSearchBox> {
  LightTeam? team;
  @override
  Widget build(final BuildContext context) => Column(
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: TypeAheadFormField<LightTeam>(
              validator: (final String? selectedTeam) {
                if (widget.dontValidate) {
                  return null;
                }
                if (selectedTeam == "") {
                  return "Please pick a team";
                }
                return null;
              },
              textFieldConfiguration: TextFieldConfiguration(
                onSubmitted: (final String number) {
                  try {
                    final LightTeam team = widget.teams.firstWhere(
                      (final LightTeam team) =>
                          team.number.toString() == number,
                    );
                    widget.typeAheadController.text =
                        widget.buildSuggestion(team);
                  } on StateError catch (_) {
                    //ignored
                  }
                },
                onTap: widget.typeAheadController.clear,
                controller: widget.typeAheadController,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  hintText: "Search Team",
                ),
              ),
              suggestionsCallback: (final String pattern) => widget.teams.where(
                (final LightTeam team) {
                  return team.number.toString().startsWith(pattern);
                },
              ).toList()
                ..sort(
                  (final LightTeam firstTeam, final LightTeam secondTeam) =>
                      firstTeam.number.compareTo(secondTeam.number),
                ),
              itemBuilder: (final BuildContext context, final LightTeam team) =>
                  ListTile(title: Text(widget.buildSuggestion(team))),
              transitionBuilder: (
                final BuildContext context,
                final Widget suggestionsBox,
                final AnimationController? controller,
              ) {
                return FadeTransition(
                  child: suggestionsBox,
                  opacity: CurvedAnimation(
                    parent: controller!,
                    curve: Curves.fastOutSlowIn,
                  ),
                );
              },
              noItemsFoundBuilder: (final BuildContext context) => Container(
                height: 60,
                child: Center(
                  child: Text(
                    "No Teams Found",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              hideSuggestionsOnKeyboardHide: false,
              onSuggestionSelected: (final LightTeam team) {
                widget.typeAheadController.text = widget.buildSuggestion(team);
                this.team = team;
              },
            ),
          ),
          team.mapNullable(
                (final LightTeam team) => widget.buildWithTeam(context, team),
              ) ??
              NoTeamSelected()
        ],
      );
}
