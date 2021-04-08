import 'dart:math';
import 'package:scouting_frontend/TeamCard.dart';
import 'package:flutter/material.dart';
import 'TeamData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

// TODO: add failed http request screen

class Rank extends StatefulWidget {
  @override
  _RankState createState() => _RankState();
}

class _RankState extends State<Rank> {
  List<TeamData> teamsList = [];
  var url = Uri.parse(
      'https://scouting-system.herokuapp.com/graphql?query={teams{name}}');

  void fetchData() async {
    //http rerquest
    var response = await http.get(url);
    if (response.statusCode == 200) {
      //converts respone to an array of teams <TeamData>
      var jsonResponse = convert.jsonDecode(response.body);
      var foramatedJson = jsonResponse['data']['teams'];
      assert(foramatedJson is List);
      for (var item in foramatedJson) {
        teamsList.add(TeamData.fromJson(item));
      }

      print('Done fetching  - ${teamsList[0].teamName}');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  static const int numItems = 10;
  int selectedIndex = -1;

  //Demo data for card
  List<int> teamNumber =
      List<int>.generate(numItems, (index) => Random().nextInt(5000));
  List<int> shotsInTarget =
      List<int>.generate(numItems, (index) => Random().nextInt(100));
  List<int> successfulClimbs =
      List<int>.generate(numItems, (index) => Random().nextInt(100));
  List<double> shotsInTargetPrecentage =
      List<double>.generate(numItems, (index) => Random().nextDouble());
  List<double> successfulClimbsPrecentage =
      List<double>.generate(numItems, (index) => Random().nextDouble());

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder(
        future: http.get(url),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.statusCode == 503) {
              // 503 - Service Unavailable
              return Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Opps',
                    style: TextStyle(fontSize: 100),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Image.network(
                    'https://lh3.googleusercontent.com/pw/ACtC-3cSLdYL7W8v0ZQGWY3veprH4al6C3vbj51oqX7wsfDmyIn1ySwEbg16WbKPRF-Uje06p-uBWOSynTwNnqtuFQx0OfmaoAhaKPwmlsaQOKRxB50g0lIRD5gCBPB0tV7ByY-ScjVgjQ_swedZsCDyBvKb8Q=w516-h915-no',
                    height: 500,
                  ),
                ],
              );
            }
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                // vertical: 20,
              ),
              child: DataTable(
                sortColumnIndex: 1,
                sortAscending: true,
                columnSpacing: 10,
                showCheckboxColumn: false,
                columns: [
                  DataColumn(label: Text('Rank')),
                  DataColumn(label: Text('Team Number'), numeric: false),
                  DataColumn(label: Text('Shots in target')),
                  DataColumn(label: Text('climbs')),
                ],
                rows: List<DataRow>.generate(
                  numItems,
                  (index) => DataRow(
                    cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(Text(teamNumber[index].toString())),
                      DataCell(Text(shotsInTarget[index].toString())),
                      DataCell(Text(successfulClimbs[index].toString())),
                    ],
                    selected: index == selectedIndex,
                    onSelectChanged: (value) {
                      setState(() {
                        selectedIndex = index;
                      });
                      showDialog(
                        context: context,
                        builder: (context) => TeamCard(
                          selectedTeam: teamsList[index],

                          //TODO: remove this
                          teamNumber: teamNumber[index],
                          shostInTarget: shotsInTarget[index],
                          successfulClimbs: successfulClimbs[index],
                          shotsInTargetPrecent: shotsInTargetPrecentage[index],
                          successfulClimbsPrecent:
                              successfulClimbsPrecentage[index],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
