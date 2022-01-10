import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/pc/pick_list_screen.dart';
import 'package:scouting_frontend/views/pc/widgets/pick_list_widget.dart';

class PickListFuture extends StatefulWidget {
  PickListFuture(
      {Key? key,
      required this.screen,
      final void Function(List<PickListTeam>)? onReorder})
      : super(key: key) {
    this.onReorder = onReorder ?? ignore;
  }

  final CurrentPickList screen;
  late final void Function(List<PickListTeam> list) onReorder;
  @override
  _PickListFutureState createState() => _PickListFutureState();
}

class _PickListFutureState extends State<PickListFuture> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PickListTeam>>(
        future: fetchTeams(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null) {
            return Center(
              child: Text('No Teams'),
            );
          }
          widget.onReorder(snapshot.data!);
          return PickList(
            onReorder: widget.onReorder,
            uiList: snapshot.data!,
            screen: widget.screen,
          );
        });
  }

  Future<List<PickListTeam>> fetchTeams() async {
    final client = getClient();
    final String query = """
    query MyQuery {
  team {
    taken
    second_picklist_index
    first_picklist_index
    id
    name
    number
  }
}

    """;
    final result = await client.query(QueryOptions(document: gql(query)));

    result.mapQueryResult((data) => data.mapNullable((pickListTeams) =>
        (pickListTeams['team'] as List<dynamic>)
            .map((dynamic e) => PickListTeam(
                e['id'] as int,
                e['number'] as int,
                e['name'] as String,
                e['first_picklist_index'] as int,
                e['second_picklist_index'] as int,
                e['taken'] as bool))
            .toList()));

    if (result.hasException) {
      throw Exception('Grapgql error ${result.exception}');
    }
    if (result.data == null) {
      return [];
    }
    List<PickListTeam> teams = (result.data!["team"] as List<dynamic>)
        .map<PickListTeam>((final dynamic e) => PickListTeam(
            e['id'] as int,
            e['number'] as int,
            e['name'] as String,
            e['first_picklist_index'] as int,
            e['second_picklist_index'] as int,
            e['taken'] as bool))
        .toList();

    teams.sort((left, right) =>
        widget.screen.getIndex(left).compareTo(widget.screen.getIndex(right)));
    return teams;
  }
}
