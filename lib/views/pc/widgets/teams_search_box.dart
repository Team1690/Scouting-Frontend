import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:scouting_frontend/models/team_model.dart';

class TeamsSearchBox extends StatefulWidget {
  TeamsSearchBox({
    final Key key,
    @required final this.teams,
    @required final this.onChange,
    // @required final this.typeAheadController,
  }) : super(key: key);

  final List<LightTeam> teams;
  final Function(LightTeam) onChange;
  // final TextEditingController typeAheadController;

  @override
  _TeamsSearchBoxState createState() => _TeamsSearchBoxState();
}

class _TeamsSearchBoxState extends State<TeamsSearchBox> {
  bool isValueEmpty = false;
  bool isValueInList = true;
  final TextEditingController _typeAheadController = TextEditingController();

  List<LightTeam> updateSussestions(inputNumber) {
    List<LightTeam> _suggestions = List.castFrom(widget.teams);
    String _inputNumber = inputNumber;
    // print(inputNumber);
    for (LightTeam team in _suggestions) {
      print(inputNumber.toString());
    }
    _suggestions.removeWhere((team) {
      // print(team.number.toString() + ' ' + _inputNumber);
      return team.number.toString().contains(_inputNumber);
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
        itemBuilder: (context, LightTeam suggestion) =>
            ListTile(title: Text(suggestion.number.toString())),
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
        onSuggestionSelected: (final LightTeam suggestion) {
          _typeAheadController.text = suggestion.number.toString();
          widget.onChange(widget.teams[widget.teams
              .indexWhere((team) => team.number == suggestion.number)]);
        });
  }
}
