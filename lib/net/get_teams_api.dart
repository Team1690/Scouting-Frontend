import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:scouting_frontend/models/team_model.dart';

class GetTeamsApi {
  GetTeamsApi();

  static List<Team> teamsList = [];
  static int statusCode;

  Future<http.Response> fetchAnalytics() async {
    int nullTeams = 0;
    final url = Uri.parse(
        'https://scouting-system.herokuapp.com/graphql?query={getCurrentComp{teams{number,name,analytics{matchesPlayed,auto{bottomAverage,upperAverage}teleop{averageShotsInTarget,shotsSD,climbPerMatches,climbPerAttempts}}}}}');
    //http rerquest

    var response = await http.get(url);
    statusCode = response.statusCode;

    if (statusCode == 200) {
      teamsList.clear();
      //converts respone to an array of teams. type: <Team>
      var jsonResponse =
          convert.jsonDecode(response.body)['data']['getCurrentComp']['teams'];
      assert(jsonResponse is List);
      for (var item in jsonResponse) {
        item['analytics'] != null
            ? teamsList.add(Team.fromJson(item))
            : nullTeams += 1;
      }
      //checks is no data is available
      nullTeams == jsonResponse.length ? statusCode = 204 : statusCode = 200;
      print(statusCode);
      print(
          'Done fetching - ${teamsList[0].teamName} - ${teamsList[0].teamNumber}');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return response;
  }

  static Future<List<Team>> getTeamsSuggestion(String query) async {
    final url = Uri.parse(
        'https://scouting-system.herokuapp.com/graphql?query={getCurrentComp{teams{number}}}');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      List teams =
          convert.jsonDecode(response.body)['data']['getCurrentComp']['teams'];
      return teams.map((json) => Team.fromJsonLite(json)).where((user) {
        final number = user.teamNumber;
        return number.toString().contains(query);
      }).toList();
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}
