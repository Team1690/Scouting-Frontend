import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:scouting_frontend/views/globals.dart' as globals;

class PickList extends StatefulWidget {


  @override
  _PickListState createState() => _PickListState();
}

class _PickListState extends State<PickList> {
  Future<List<String>> fetchTeams() async {
    final client = getClient();
    final String query = """
query FetchTeams {
  team {
    number
  }
}
  """;

    final QueryResult result =
        await client.query(QueryOptions(document: gql(query)));
    if (result.hasException) {
      print(result.exception.toString());
    } //TODO: avoid dynamic
    return (result.data['team'] as List<dynamic>)
        .map((e) => e['number'].toString())
        .toList();
    //.entries.map((e) => LightTeam(e['id']);
  }


  void reorderData(final int oldindex, int newindex) {
    print("reordering..." + oldindex.toString() + newindex.toString() + globals.pickList.toString());
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final String item = globals.pickList.removeAt(oldindex);
      globals.pickList.insert(newindex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(future: fetchTeams(), builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error has happened in the future! ' +
                          snapshot.error.toString());
                    } else if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (snapshot.data.length < 1) {
                        return Text('invalid data :(');
                      }
                      if(globals.pickList == null){
                        globals.pickList = snapshot.data;
                      }
                      return ReorderableListView(children: globals.pickList.map((e) => Card(
              color: bgColor,
              key: ValueKey(e),
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                    0, defaultPadding / 4, 0, defaultPadding / 4),
                child: ListTile(
                  title: Text(e),
                  leading: AdvancedSwitch(
                    controller: AdvancedSwitchController(),
                    activeColor: Colors.red,
                    inactiveColor: primaryColor,
                    activeChild: Text('Taken'),
                    inactiveChild: Text('Available'),
                    height: 25,
                    width: 100,
                    enabled: true,
                  ),
                ),
              ),
        )).toList(), onReorder: reorderData, );
                    }
              },
    ));
  }
}
