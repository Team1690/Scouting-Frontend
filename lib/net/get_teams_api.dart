import 'dart:async';
import 'dart:html';
import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:scouting_frontend/models/team_model.dart';
import 'package:graphql/client.dart';


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

  //TODO: create one functions
  static Future futureRandomData() async {
    // Completer completer = new Completer();
    Faker faker = new Faker();

    return Future.delayed(
        Duration(milliseconds: 0),
        (() => List<Team>.filled(
            10,
            Team(
                teamNumber: random.decimal().toInt(),
                teamName: faker.person.firstName(),
                msg: List.generate(
                    5, (index) => faker.randomGenerator.string(500))))));
  }

  static Future<List<Team>> randomData() async {
    // Completer completer = new Completer();
    Faker faker = new Faker();





    Map<String, String> headers = new Map<String, String>();
    headers["x-hasura-admin-secret"] = "j0eAGMVfVfeYlyUnlTfYVQc64typ3OTfNbJrpQWXrqKp0qQnon7TpNzvabMC1Pi0";
    final link = HttpLink("https://choice-lizard-77.hasura.app/v1/graphql", defaultHeaders: headers);
    final client = GraphQLClient(link: link);
    final String query = """
query MyQuery {
  matches(where: {team: {_eq: 1690}}){
    autoBalls
    climb
    initiationLine
    team
    teleopInner
    teleopOuter
  }
}
""";
  final QueryResult result = await client.query(QueryOptions(document: gql(query)));

  // client.query(...).then(x => x + 1).then
  // [1, 2, 3].map(x => x + 1).map(...)
  if(result.hasException){
    print(result.exception.toString());
  }

  final List<dynamic> repositories =
    result.data['matches'] as List<dynamic>;

  print(repositories); 






    return List<Team>.generate(
        10,
        (index) => Team(
            teamNumber: faker.randomGenerator.integer(9999),
            teamName: faker.person.firstName(),
            averageShots: faker.randomGenerator.integer(100),
            totalShotsSD: faker.randomGenerator.integer(100).toDouble(),
            msg: List.generate(5, (index) => faker.lorem.sentences(5).join()),
            spider: List<int>.generate(
                4, (index) => faker.randomGenerator.integer(100)),
            tables: List.generate(
                2, //number of tables
                (index) => List.generate(
                    10, //number of datapoints
                    (index) => [index, faker.randomGenerator.integer(10)]))));
  }
}
