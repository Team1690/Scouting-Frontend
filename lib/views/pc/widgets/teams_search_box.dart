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
    // @required final this.typeAheadController,
  }) : super(key: key);

  final List<Team> teams;
  final Function(Team) onChange;
  // final TextEditingController typeAheadController;

  @override
  _TeamsSearchBoxState createState() => _TeamsSearchBoxState();
}

class _TeamsSearchBoxState extends State<TeamsSearchBox> {
  bool isValueEmpty = false;
  bool isValueInList = true;
  final TextEditingController _typeAheadController = TextEditingController();

  List<Team> updateSussestions(inputNumber) {
    List<Team> _suggestions = List.castFrom(widget.teams);
    String _inputNumber = inputNumber;
    // print(inputNumber);
    for (Team team in _suggestions) {
      print(inputNumber.toString());
    }
    _suggestions.removeWhere((team) {
      // print(team.teamNumber.toString() + ' ' + _inputNumber);
      return team.teamNumber.toString().contains(_inputNumber);
    });

    // print(_suggestions);
    return _suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _typeAheadController,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            hintText: 'Search Team',
          ),
        ),
        suggestionsCallback: (pattern) => widget.teams,
        itemBuilder: (context, Team suggestion) =>
            ListTile(title: Text(suggestion.teamNumber.toString())),
        transitionBuilder: (context, suggestionsBox, controller) {
          return FadeTransition(
            child: suggestionsBox,
            opacity: CurvedAnimation(
                parent: controller, curve: Curves.fastOutSlowIn),
          );
        },
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
          _typeAheadController.text = suggestion.teamNumber.toString();
          widget.onChange(widget.teams[widget.teams
              .indexWhere((team) => team.teamNumber == suggestion.teamNumber)]);
        });
  }
}
