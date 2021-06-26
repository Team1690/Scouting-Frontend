import 'package:http/http.dart' as http;
import 'package:scouting_frontend/models/match_model.dart';

class SendMatchApi {
  Match match;

  SendMatchApi();
  static int statusCode;

  static Future<http.Response> sendData(Match match) async {
    final url = Uri.parse('http://scouting-system.herokuapp.com/graphql');
    var jsonMatchData = match.toJson();
    var postRequest =
        '{\"query\": \"mutation{createMatch(match: $jsonMatchData){statusCode, error}}\"}';

// {"query": "mutation{createMatch(match: {number: 0, team: 0}){_id}}"}
    //http rerquest
    var response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: postRequest);
    statusCode = response.statusCode;

    if (response.statusCode == 200) {
      print('yeyy ${response.statusCode}');
    } else {
      print('oops');
      print(response.body);
    }

    return response;
  }
}
