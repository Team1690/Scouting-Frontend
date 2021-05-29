import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/get_teams_api.dart';

class TeamsDropdown extends StatelessWidget {
  TeamsDropdown({
    Key key,
    @required this.onChange,
  }) : super(key: key);

  Function(int) onChange;

  final TextEditingController _typeAheadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _typeAheadController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            hintText: 'Search Team',
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
          _typeAheadController.text = suggestion.teamNumber.toString();
          onChange(suggestion.teamNumber);

          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text('Selected user: ${user.teamNumber}'),
            ));
        });
  }
}
