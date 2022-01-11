import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";

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
  _TeamsSearchBoxState createState() => _TeamsSearchBoxState();
}

class _TeamsSearchBoxState extends State<TeamsSearchBox> {
  bool isValueEmpty = false;
  bool isValueInList = true;

  List<LightTeam> updateSussestions(final String inputNumber) {
    final List<LightTeam> _suggestions = List.castFrom(widget.teams);
    final String _inputNumber = inputNumber;
    _suggestions.removeWhere((final LightTeam team) {
      return team.number.toString().contains(_inputNumber);
    });

    return _suggestions;
  }

  @override
  Widget build(final BuildContext context) {
    return TypeAheadField<LightTeam>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: widget.typeAheadController,
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
      suggestionsCallback: (final String pattern) => widget.teams,
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
        widget.onChange(
          widget.teams[widget.teams.indexWhere(
            (final LightTeam team) => team.number == suggestion.number,
          )],
        );
      },
    );
  }
}

Future<List<LightTeam>> fetchTeams() async {
  final GraphQLClient client = getClient();
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

  return result.mapQueryResult(
        (final Map<String, dynamic>? data) => data.mapNullable(
          (final Map<String, dynamic> teams) => (teams["team"] as List<dynamic>)
              .map(
                (final dynamic e) => LightTeam(
                  e["id"] as int,
                  e["number"] as int,
                  e["name"] as String,
                ),
              )
              .toList(),
        ),
      ) ??
      <LightTeam>[];
}
