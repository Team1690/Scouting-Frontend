import "package:flutter/material.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/matches_model.dart";

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
  Widget build(final BuildContext context) => TypeAheadFormField<ScheduleMatch>(
        validator: (final String? value) {
          if (value == "") {
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
              (final ScheduleMatch element) =>
                  element.matchNumber.toString().startsWith(pattern),
            )
            .toList(),
        itemBuilder:
            (final BuildContext context, final ScheduleMatch suggestion) =>
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
      );
}
