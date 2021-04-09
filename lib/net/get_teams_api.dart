import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:scouting_frontend/models/team_model.dart';

class GetTeamsApi {
  GetTeamsApi();
  var url = Uri.parse(
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
    return response;
  }
}
