import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:scouting_frontend/models/match_model.dart';

import 'hasura_helper.dart';

class SendMatchApi {
  Match match;

  SendMatchApi();
  static int statusCode;

  static Future<http.Response> sendData(Match match) async {
    final url = Uri.parse('https://scouting-system.herokuapp.com/graphql');
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

  static Future<Map<int, int>> getIDs() async {
    print("getIds");
    final client = getClient();
    String query = """query MyQuery {
  team {
		number
    id
  }
}
""";
    final QueryResult result =
        await client.query(QueryOptions(document: gql(query)));
    if (result.hasException) {
      print(result.exception.toString());
    } //TODO: avoid dynamic

    print(Map.fromIterable(result.data['team'],
        key: (e) => e["number"], value: (e) => e["id"]));
    ;

    return Map.fromIterable(result.data['team'],
        key: (e) => e["number"], value: (e) => e["id"]);
  }
}
//Instance of '_Future<Map<int, int>>'
//yeyy 200
