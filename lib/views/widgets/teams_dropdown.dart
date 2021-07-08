import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/get_teams_api.dart';

class TeamsDropdown extends StatefulWidget {
  TeamsDropdown({
    Key key,
    @required this.onChange,
    @required this.typeAheadController,
  }) : super(key: key);

  Function(int) onChange;
  TextEditingController typeAheadController;

  @override
  _TeamsDropdownState createState() => _TeamsDropdownState();
}

class _TeamsDropdownState extends State<TeamsDropdown> {
  // final TextEditingController _typeAheadController = TextEditingController();
  bool _validate = false;

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          onChanged: (value) => setState(() => _validate = value.isEmpty),
          controller: widget.typeAheadController,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            hintText: 'Search Team',
            errorText: _validate ? 'Value can\'t be empty' : null,
          ),
        ),
        suggestionsCallback: GetTeamsApi.getTeamsSuggestion,
        itemBuilder: (context, Team suggestion) {
          final user = suggestion;
          return ListTile(
            title: Text(user.teamNumber.toString()),
          );
        },
        noItemsFoundBuilder: (context) => Container(
              height: 100,
              child: Center(
                child: Text(
                  'No Users Found.',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
        onSuggestionSelected: (Team suggestion) {
          final user = suggestion;
          widget.typeAheadController.text = suggestion.teamNumber.toString();
          widget.onChange(suggestion.teamNumber);

          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text('Selected user: ${user.teamNumber}'),
            ));
        });
  }
}
