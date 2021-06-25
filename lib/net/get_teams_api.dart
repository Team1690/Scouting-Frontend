import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:scouting_frontend/models/team_model.dart';

class GetTeamsApi {
  GetTeamsApi();

  static List<Team> teamsList = [];
  int statusCode;

  Future<http.Response> fetchAnalytics() async {
    final url = Uri.parse(
        'https://scouting-system.herokuapp.com/graphql?query={getCurrentComp{teams{number,name,analytic{auto{bottomGoalTotal,bottomGoalSD,upperGoalTotal,upperGoalSD}teleop{upperGoalTotal,upperGoalSD,climbPrecentage}}}}}');
    //http rerquest
    var response = await http.get(url);
    // print('response is ${response.body}');
    statusCode = response.statusCode;

    if (statusCode == 200) {
      teamsList.clear();
      //converts respone to an array of teams. type: <Team>
      var jsonResponse =
          convert.jsonDecode(response.body)['data']['getCurrentComp']['teams'];
      assert(jsonResponse is List);
      for (var item in jsonResponse) {
        if (item['analytic'] != null) {
          teamsList.add(Team.fromJson(item));
        } else {
          print('Analytics were null');
        }
      }
      print(
          'Done fetching - ${teamsList[0].teamName} - ${teamsList[0].teamNumber}');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return response;
  }

  static Future<List<Team>> getTeamsSuggestion(String query) async {
    final url = Uri.parse(
        'https://scouting-system.herokuapp.com/graphql?query={getCurrentComp{teams{name,number}}}');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      List teams =
          convert.jsonDecode(response.body)['data']['getCurrentComp']['teams'];
      print(teams);
      return teams.map((json) => Team.fromJson(json)).where((user) {
        final number = user.teamNumber;
        return number.toString().contains(query);
      }).toList();
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}
