import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/mobile/Selector.dart';
import 'package:scouting_frontend/views/mobile/counter.dart';
import 'package:scouting_frontend/views/mobile/section_divider.dart';
import 'package:scouting_frontend/views/mobile/switcher.dart';
import 'package:scouting_frontend/views/mobile/teams_dropdown.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';

class PitView extends StatefulWidget {
  @override
  State<PitView> createState() => _PitViewState();
}

class _PitViewState extends State<PitView> {
  LightTeam team;
  String driveTrainValue = 'Choose a DriveTrain';
  String driveMotorValue = 'Choose a Drive Motor';
  String wheelType = '';
  int motorAmount = 2;
  int selectedShifterIndex = -1;
  double driveTrainReliability = 1;
  double electronicsReliability = 1;
  double robotReliability = 1;

  Future<List<LightTeam>> fetchTeams() async {
    final client = getClient();
    final String query =
        """
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
                        setState(() {
                          team = LightTeam;
                        });
                      },
                    ),
                  );
                }
              }),
          SectionDivider(label: 'Drive Train'),
          Container(
            padding: const EdgeInsets.fromLTRB(
              30,
              defaultPadding,
              30,
              defaultPadding,
            ),
            child: Selector(
              'Choose a DriveTrain',
              [
                'Westcoast',
                'Kit Chassis',
                'Custom Tank',
                'Swerve',
                'Mecanum/H',
                'Other',
              ],
              onChanged: (newValue) => {driveTrainValue = newValue},
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
                30, defaultPadding, 30, defaultPadding),
            child: Selector(
              'Choose a Drive Motor',
              [
                'Falcon',
                'Neo',
                'CIM',
                'Mini CIM',
                'Other',
              ],
              onChanged: (newValue) => {driveMotorValue = newValue},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: defaultPadding, bottom: defaultPadding),
            child: Counter(
              label: 'Drive Motors',
              icon: Icons.adjust,
              count: motorAmount,
              upperLimit: 10,
              lowerLimit: 2,
              stepValue: 2,
              longPressedValue: 4,
              onChange: (newVal) {
                motorAmount = newVal;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: defaultPadding, bottom: defaultPadding),
            child: Switcher(
              labels: [
                'Regular shifter',
                'Purchesed shifter',
                'No shifter',
              ],
              colors: [
                Colors.white,
                Colors.white,
                Colors.white,
              ],
              selected: selectedShifterIndex,
              onChange: (final int index) => setState(() {
                selectedShifterIndex =
                    index == selectedShifterIndex ? -1 : index;
                print(selectedShifterIndex);
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: defaultPadding,
              bottom: defaultPadding,
            ),
            child: TextField(
              onChanged: (value) => wheelType = value,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.fromLTRB(10, defaultPadding, 10, defaultPadding),
                hintText: 'Drive Wheel type',
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: defaultPadding, bottom: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Drive Train Reliablity:'),
                Slider(
                  min: 1,
                  max: 5,
                  divisions: 5,
                  value: driveTrainReliability,
                  label: driveTrainReliability.round().toString(),
                  onChanged: (newVal) =>
                      setState(() => driveTrainReliability = newVal),
                )
              ],
            ),
          ),
          SectionDivider(label: 'General Robot'),
          Padding(
            padding: const EdgeInsets.only(
                top: defaultPadding, bottom: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Electronics Reliablity:'),
                Slider(
                  min: 1,
                  max: 5,
                  divisions: 5,
                  value: electronicsReliability,
                  label: electronicsReliability.round().toString(),
                  onChanged: (newVal) =>
                      setState(() => electronicsReliability = newVal),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: defaultPadding, bottom: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Robot Reliablity:'),
                Slider(
                  min: 1,
                  max: 10,
                  divisions: 10,
                  value: robotReliability,
                  label: robotReliability.round().toString(),
                  onChanged: (newVal) =>
                      setState(() => robotReliability = newVal),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

/*
shifter selector:
Container(
            padding: const EdgeInsets.fromLTRB(
                50, defaultPadding, 50, defaultPadding),
            child: Selector("Choose a Shifter", [
              'None',
              'Purchased',
              'Regular',
            ]),
          )


  child: AdvancedSwitch(
    controller: AdvancedSwitchController(),
    activeColor: primaryColor,
    inactiveColor: primaryColor,
    activeChild: Text('Tank'),
    inactiveChild: Text('Swerve'),
    height: 25,
    width: 100,
    enabled: true,
  ),

drive motor text field
Container(
            padding: const EdgeInsets.fromLTRB(
              50,
              defaultPadding,
              50,
              defaultPadding,
            ),
            child: TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(
                      10, defaultPadding, 10, defaultPadding),
                  hintText: 'Drive Motor Amount',
                  hintStyle: TextStyle(fontSize: 14),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ]),
          )          
*/