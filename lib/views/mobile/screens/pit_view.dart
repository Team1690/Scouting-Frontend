import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/mobile/Selector.dart';
import 'package:scouting_frontend/views/mobile/section_divider.dart';
import 'package:scouting_frontend/views/mobile/switcher.dart';
import 'package:scouting_frontend/views/mobile/teams_dropdown.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';

class PitView extends StatelessWidget {
  LightTeam team;

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
        .map((e) => LightTeam(e['id'], e['number'], e['name']))
        .toList();
    //.entries.map((e) => LightTeam(e['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Pit Scouting')),
        ),
        body: ListView(
          children: [
            FutureBuilder(
                future: fetchTeams(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error has happened in the future! ' +
                        snapshot.error.toString());
                  } else if (!snapshot.hasData) {
                    return Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
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

                    // const CircularProgressIndicator();
                  } else {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: TeamsSearchBox(
                        teams: snapshot.data as List<LightTeam>,
                        onChange: (LightTeam) {
                          team = LightTeam;
                        },
                      ),
                    );
                  }
                }),
            SectionDivider(label: 'Drive Train'),
            Container(
              padding: const EdgeInsets.fromLTRB(
                100,
                defaultPadding / 4,
                100,
                defaultPadding / 4,
              ),
              child: Selector('Choose a DriveTrain', [
                'Westcoast',
                'Kit Chassis',
                'Custom Tank',
                'Swerve',
                'Mecanum/H',
              ]),
              // child: AdvancedSwitch(
              //   controller: AdvancedSwitchController(),
              //   activeColor: primaryColor,
              //   inactiveColor: primaryColor,
              //   activeChild: Text('Tank'),
              //   inactiveChild: Text('Swerve'),
              //   height: 25,
              //   width: 100,
              //   enabled: true,
              // ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                  100, defaultPadding / 4, 100, defaultPadding / 4),
              child: Selector('Choose a Drive Motor', [
                'Falcon',
                'Neo',
                'CIM',
                'Mini CIM',
                'Other',
              ]),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                  100, defaultPadding / 4, 100, defaultPadding / 4),
              child: TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(
                        10, defaultPadding / 4, 10, defaultPadding / 4),
                    hintText: 'Drive Motor Amount',
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ]),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                  100, defaultPadding / 4, 100, defaultPadding / 4),
              child: Selector("Choose a Shifter", [
                'None',
                'Purchased',
                'Regular',
              ]),
            ),
          ],
        ));
  }
}
