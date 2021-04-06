import 'package:ScoutingFrontend/Rank.dart';
import 'package:ScoutingFrontend/TabSwitcher.dart';
import 'package:ScoutingFrontend/TeamData.dart';
import 'package:ScoutingFrontend/UserInput.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class App extends StatelessWidget {
  List<TeamData> globalTeamsList = [];

  void fetchData() async {
    //http rerquest
    var url = Uri.parse(
        'https://scouting-system.herokuapp.com/graphql?query={teams{name}}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      //converts respone to an array of teams <TeamData>
      var jsonResponse = convert.jsonDecode(response.body);
      var foramatedJson = jsonResponse['data']['teams'];
      assert(foramatedJson is List);
      for (var item in foramatedJson) {
        globalTeamsList.add(TeamData.fromJson(item));
      }

      print(globalTeamsList[5].teamName);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(final BuildContext context) {
    fetchData();
    return MaterialApp(
      title: 'Orbit Scouting',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: TabSwitcher(),
          body: TabBarView(
            children: [
              UserInput(),
              Rank(),
            ],
          ),
        ),
      ),
    );
  }
}
