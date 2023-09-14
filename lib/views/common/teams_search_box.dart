import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:scouting_frontend/models/team_model.dart";

class TeamsSearchBox extends StatelessWidget {
  TeamsSearchBox({
    required this.buildSuggestion,
    required this.teams,
    required this.onChange,
    required this.typeAheadController,
    this.dontValidate = false,
  });
  final String Function(LightTeam) buildSuggestion;
  final bool dontValidate;
  final List<LightTeam> teams;
  final void Function(LightTeam) onChange;
  final TextEditingController typeAheadController;
  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: TypeAheadFormField<LightTeam>(
          validator: (final String? selectedTeam) {
            if (dontValidate) {
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
                final LightTeam team = teams.firstWhere(
                  (final LightTeam team) => team.number.toString() == number,
                );
                onChange(team);
                typeAheadController.text = buildSuggestion(team);
              } on StateError catch (_) {
                //ignored
              }
            },
            onTap: typeAheadController.clear,
            controller: typeAheadController,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              hintText: "Search Team",
            ),
          ),
          suggestionsCallback: (final String pattern) => teams
              .where(
                (final LightTeam team) =>
                    team.number.toString().startsWith(pattern),
              )
              .toList()
            ..sort(
              (final LightTeam firstTeam, final LightTeam secondTeam) =>
                  firstTeam.number.compareTo(secondTeam.number),
            ),
          itemBuilder: (final BuildContext context, final LightTeam team) =>
              buildSuggestion(team).isNotEmpty
                  ? ListTile(title: Text(buildSuggestion(team)))
                  : Container(),
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
            child: const Center(
              child: Text(
                "No Teams Found",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          hideSuggestionsOnKeyboardHide: false,
          onSuggestionSelected: (final LightTeam team) {
            typeAheadController.text = buildSuggestion(team);
            onChange(
              team,
            );
          },
        ),
      );
}
