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
  List<Team> _suggestions = <Team>[];

  @override
  Widget build(final BuildContext context) {
    return TypeAheadField<Team>(
      textFieldConfiguration: TextFieldConfiguration(
        onChanged: (final String value) => setState(() {
          isValueEmpty = value.isEmpty;

          isValueInList = _suggestions
              .map<String>((final Team team) => team.teamNumber.toString())
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
              ? "Value can\'t be empty"
              : !isValueInList
                  ? "Not a valid team"
                  : null,
        ),
      ),
      itemBuilder: (final BuildContext context, final Team suggestion) =>
          ListTile(title: Text(suggestion.teamNumber.toString())),
      noItemsFoundBuilder: (final BuildContext context) => Container(
        height: 100,
        child: Center(
          child: Text(
            "No Teams Found",
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
      onSuggestionSelected: (final Team suggestion) {
        widget.typeAheadController.text = suggestion.teamNumber.toString();
        widget.onChange(suggestion.teamNumber);

        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text("Selected team: ${suggestion.teamNumber}"),
            ),
          );

        setState(() {
          isValueEmpty = false;
          isValueInList = true;
        });
      },
      suggestionsCallback: (final String s) => <Team>[],
    );
  }
}
