import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/get_teams_api.dart';

class TeamsSearchBox extends StatefulWidget {
  TeamsSearchBox({
    final Key key,
    @required final this.teams,
    @required final this.onChange,
    @required final this.typeAheadController,
  }) : super(key: key);

  final List<Team> teams;
  final Function(Team) onChange;
  final TextEditingController typeAheadController;

  @override
  _TeamsSearchBoxState createState() => _TeamsSearchBoxState();
}

class _TeamsSearchBoxState extends State<TeamsSearchBox> {
  bool isValueEmpty = false;
  bool isValueInList = true;
  List<Team> _suggestions = [];

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          onChanged: (final String value) => setState(() {
            isValueEmpty = value.isEmpty;

            isValueInList = _suggestions
                .map<String>((team) => team.teamNumber.toString())
                .contains(value);

            if (!isValueEmpty && isValueInList)
              widget.onChange(widget.teams[widget.teams
                  .indexWhere((team) => team.teamNumber == int.parse(value))]);
          }),
          controller: widget.typeAheadController,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            hintText: 'Search Team',
            errorText: isValueEmpty
                ? 'Value can\'t be empty'
                : !isValueInList
                    ? 'Not a valid team'
                    : null,
          ),
        ),
        suggestionsCallback: (value) {
          final List<Team> suggestions = widget.teams;

          setState(() => this._suggestions = suggestions);

          return suggestions;
        },
        itemBuilder: (context, Team suggestion) =>
            ListTile(title: Text(suggestion.teamNumber.toString())),
        noItemsFoundBuilder: (context) => Container(
              height: 100,
              child: Center(
                child: Text(
                  'No Teams Found',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
        onSuggestionSelected: (final Team suggestion) {
          widget.typeAheadController.text = suggestion.teamNumber.toString();
          widget.onChange(widget.teams[widget.teams
              .indexWhere((team) => team.teamNumber == suggestion.teamNumber)]);

          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text('Selected team: ${suggestion.teamNumber}'),
            ));

          setState(() {
            isValueEmpty = false;
            isValueInList = true;
          });
        });
  }
}
