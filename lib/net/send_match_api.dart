import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:scouting_frontend/models/match_model.dart';

import 'hasura_helper.dart';

class SendMatchApi {
  Match match;

  SendMatchApi();
  static int statusCode;

  static void sendData(Match match) async {
    String mutation =
        """mutation MyMutation (\$auto_balls: Int, \$climb_id: Int, \$defended_by: Int, \$initiation_line: Boolean, \$number: Int, \$match_type_id: Int, \$team_id: Int, \$teleop_inner: Int, \$teleop_outer: Int){
  insert_match(objects: {auto_balls: \$auto_balls, climb_id: \$climb_id, defended_by: \$defended_by, initiation_line: \$initiation_line, number: \$number, match_type_id: \$match_type_id, team_id: \$team_id, teleop_inner: \$teleop_inner, teleop_outer: \$teleop_outer}) {
    returning {
      auto_balls
      climb_id
      defended_by
      initiation_line
      match_type_id
      number
      team_id
      teleop_inner
      teleop_outer
    }
  }
}
""";
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

    return Map.fromIterable(result.data['team'],
        key: (e) => e["number"], value: (e) => e["id"]);
  }
}
//Instance of '_Future<Map<int, int>>'
//yeyy 200
//getIds
//{1690: 1, 254: 3, 1324: 2}
