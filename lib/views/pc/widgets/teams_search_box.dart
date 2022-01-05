import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';

class TeamsSearchBox extends StatefulWidget {
  TeamsSearchBox({
    final Key key,
    @required final this.teams,
    @required final this.onChange,
    @required final this.typeAheadController,
    // @required final this.typeAheadController,
  }) : super(key: key);

  final List<LightTeam> teams;
  final Function(LightTeam) onChange;
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
          widget.typeAheadController.text = suggestion.number.toString();
          widget.onChange(widget.teams[widget.teams
              .indexWhere((team) => team.number == suggestion.number)]);
        });
  }
}

Future<List<LightTeam>> fetchTeams() async {
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
    print(result.exception.toString());
  } //TODO: avoid dynamic
  return (result.data['team'] as List<dynamic>)
      .map((dynamic e) =>
          LightTeam(e['id'] as int, e['number'] as int, e['name'] as String))
      .toList();
}

Widget teamSearch(void Function(LightTeam) callback) {
  return Expanded(
      flex: 1,
      child: FutureBuilder(
          future: fetchTeams(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                  'Error has happened in the future! ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return Stack(alignment: AlignmentDirectional.center, children: [
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    hintText: 'Search Team',
                    enabled: false,
                  ),
                ),
                Center(
                  child: CircularProgressIndicator(),
                ),
              ]);
            } else {
              return TeamsSearchBox(
                teams: snapshot.data as List<LightTeam>,
                onChange: callback,
              );
            }
          }));
}
