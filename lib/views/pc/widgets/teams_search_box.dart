import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';

class TeamsSearchBox extends StatefulWidget {
  TeamsSearchBox({
    required final this.teams,
    required final this.onChange,
    required final this.typeAheadController,
    // @required final this.typeAheadController,
  });

  final List<LightTeam> teams;
  final void Function(LightTeam) onChange;
  final TextEditingController typeAheadController;
  // final TextEditingController typeAheadController;

  @override
  TeamsSearchBoxState createState() => TeamsSearchBoxState();
}

class TeamsSearchBoxState extends State<TeamsSearchBox> {
  bool isValueEmpty = false;
  bool isValueInList = true;

  List<LightTeam> updateSussestions(String inputNumber) {
    List<LightTeam> _suggestions = List.castFrom(widget.teams);
    String _inputNumber = inputNumber;
    _suggestions.removeWhere((team) {
      return team.number.toString().contains(_inputNumber);
    });

    return _suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: widget.typeAheadController,
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
                parent: controller!, curve: Curves.fastOutSlowIn),
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
          widget.typeAheadController.text = suggestion.number.toString();
          widget.onChange(widget.teams[widget.teams
              .indexWhere((team) => team.number == suggestion.number)]);
        });
  }
}

Future<List<LightTeam>?> fetchTeams() async {
  final client = getClient();
  final String query = """
query FetchTeams {
  team {
    id
    number
    name
  }
}
  """;

  final QueryResult result =
      await client.query(QueryOptions(document: gql(query)));
  if (result.hasException) {
    throw result.exception!;
  } else if (result.data == null) {
    return null;
  }
  return (result.data!['team'] as List<dynamic>)
      .map((dynamic e) =>
          LightTeam(e['id'] as int, e['number'] as int, e['name'] as String))
      .toList();
}
