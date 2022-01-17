import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";

class TeamsDropdown extends StatefulWidget {
  TeamsDropdown({
    required final this.typeAheadController,
    this.onChange = ignore,
  });

  final void Function(int) onChange;
  final TextEditingController typeAheadController;

  @override
  _TeamsDropdownState createState() => _TeamsDropdownState();
}

class _TeamsDropdownState extends State<TeamsDropdown> {
  bool isValueEmpty = false;
  bool isValueInList = true;
  final List<LightTeam> _suggestions = <LightTeam>[];

  @override
  Widget build(final BuildContext context) {
    return TypeAheadField<LightTeam>(
      textFieldConfiguration: TextFieldConfiguration(
        onChanged: (final String value) => setState(() {
          isValueEmpty = value.isEmpty;

          isValueInList = _suggestions
              .map<String>((final LightTeam team) => team.number.toString())
              .contains(value);

          if (!isValueEmpty && isValueInList) widget.onChange(int.parse(value));
        }),
        controller: widget.typeAheadController,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          hintText: "Search Team",
          errorText: isValueEmpty
              ? "Value can't be empty"
              : !isValueInList
                  ? "Not a valid team"
                  : null,
        ),
      ),
      itemBuilder: (final BuildContext context, final LightTeam suggestion) =>
          ListTile(title: Text(suggestion.number.toString())),
      noItemsFoundBuilder: (final BuildContext context) => Container(
        height: 100,
        child: Center(
          child: Text(
            "No Teams Found",
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
      onSuggestionSelected: (final LightTeam suggestion) {
        widget.typeAheadController.text = suggestion.number.toString();
        widget.onChange(suggestion.number);

        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text("Selected team: ${suggestion.number}"),
            ),
          );

        setState(() {
          isValueEmpty = false;
          isValueInList = true;
        });
      },
      suggestionsCallback: (final String s) => <LightTeam>[],
    );
  }
}
