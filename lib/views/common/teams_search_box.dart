import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:scouting_frontend/models/team_model.dart";

class TeamsSearchBox extends StatelessWidget {
  TeamsSearchBox({
    required final this.teams,
    required final this.onChange,
    required final this.typeAheadController,
  });

  final List<LightTeam> teams;
  final void Function(LightTeam) onChange;
  final TextEditingController typeAheadController;
  @override
  Widget build(final BuildContext context) {
    return TypeAheadFormField<LightTeam>(
      validator: (final String? value) {
        if (value == "") {
          return "Please pick a team";
        }
        return null;
      },
      textFieldConfiguration: TextFieldConfiguration(
        onSubmitted: (final String number) {
          try {
            onChange(
              teams.firstWhere(
                (final LightTeam team) => team.number.toString() == number,
              ),
            );
          } on StateError catch (_) {
            //ignoed
          }
        },
        onTap: typeAheadController.clear,
        controller: typeAheadController,
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
      suggestionsCallback: (final String pattern) => teams.where(
        (final LightTeam element) {
          return element.number.toString().startsWith(pattern);
        },
      ),
      itemBuilder: (final BuildContext context, final LightTeam suggestion) =>
          ListTile(title: Text(suggestion.number.toString())),
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
      onSuggestionSelected: (final LightTeam suggestion) {
        typeAheadController.text = suggestion.number.toString();
        onChange(
          teams[teams.indexWhere(
            (final LightTeam team) => team.number == suggestion.number,
          )],
        );
      },
    );
  }
}