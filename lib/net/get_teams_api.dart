import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:scouting_frontend/models/team_model.dart';

class GetTeamsApi {
  GetTeamsApi();
  final url = Uri.parse(
      'https://scouting-system.herokuapp.com/graphql?query={teams{number,name}}');

  static List<Team> teamsList = [];
  int statusCode;

  Future<http.Response> fetchData() async {
    //http rerquest
    var response = await http.get(url);
    statusCode = response.statusCode;

    if (statusCode == 200) {
      teamsList.clear();
      //converts respone to an array of teams. type: <Team>
      var jsonResponse = convert.jsonDecode(response.body)['data']['teams'];
      assert(jsonResponse is List);
      for (var item in jsonResponse) teamsList.add(Team.fromJson(item));
      print(
          'Done fetching - ${teamsList[0].teamName} - ${teamsList[0].teamNumber}');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    print(statusCode);
    return response;
  }

  static Future<List<Team>> getTeamsSuggestion(String query) async {
    final url = Uri.parse(
        'https://scouting-system.herokuapp.com/graphql?query={teams{number,name}}');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      List teams = convert.jsonDecode(response.body)['data']['teams'];
      return teams.map((json) => Team.fromJson(json)).where((user) {
        final number = user.teamNumber;
        return number.toString().contains(query);
      }).toList();
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}
