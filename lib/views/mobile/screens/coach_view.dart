import "package:flutter/material.dart";
import "package:graphql/client.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";

class CoachView extends StatefulWidget {
  @override
  _CoachViewState createState() => _CoachViewState();
}

class _CoachViewState extends State<CoachView> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      drawer: SideNavBar(),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Coach"),
      ),
      body: FutureBuilder<CoachData>(
        future: fetchMatch(),
        builder: (
          final BuildContext context,
          final AsyncSnapshot<CoachData> snapshot,
        ) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return snapshot.data.mapNullable(
                (final CoachData data) => Column(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Column(
                                  children: List<Widget>.generate(
                                    3,
                                    (final int index) => Expanded(
                                      flex: 2,
                                      child: teamData(data.blueAlliance[index]),
                                    ),
                                  )..insert(0, Spacer()),
                                ),
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Column(
                                  children: List<Widget>.generate(
                                    3,
                                    (final int index) => Expanded(
                                      flex: 2,
                                      child: teamData(data.redAlliance[index]),
                                    ),
                                  )..insert(0, Spacer()),
                                ),
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Spacer()
                  ],
                ),
              ) ??
              (throw Exception("No data"));
        },
      ),
    );
  }
}

const String query = """
query MyQuery {
  orbit_matches(order_by: {match_number: asc}, where: {happend: {_eq: false}}) {
    blue_0_team {
      id
      name
      number
    }
    blue_1_team {
      id
      name
      number
    }
    blue_2_team {
      id
      name
      number
    }
    red_0_team {
      id
      name
      number
    }
    red_1_team {
      id
      name
      number
    }
    red_2_team {
      id
      name
      number
    }
  }
}

""";
Future<CoachData> fetchMatch() async {
  final GraphQLClient client = getClient();
  final QueryResult result =
      await client.query(QueryOptions(document: gql(query)));
  return result.mapQueryResult(
    (final Map<String, dynamic>? data) =>
        data.mapNullable((final Map<String, dynamic> data) {
          print(data);
          final dynamic match = (data["orbit_matches"] as List<dynamic>).first;
          final List<LightTeam> blueAlliance = <LightTeam>[
            LightTeam(
              match["blue_0_team"]["id"] as int,
              match["blue_0_team"]["number"] as int,
              match["blue_0_team"]["name"] as String,
            ),
            LightTeam(
              match["blue_1_team"]["id"] as int,
              match["blue_1_team"]["number"] as int,
              match["blue_1_team"]["name"] as String,
            ),
            LightTeam(
              match["blue_2_team"]["id"] as int,
              match["blue_2_team"]["number"] as int,
              match["blue_2_team"]["name"] as String,
            )
          ];
          final List<LightTeam> redAlliance = <LightTeam>[
            LightTeam(
              match["red_0_team"]["id"] as int,
              match["red_0_team"]["number"] as int,
              match["red_0_team"]["name"] as String,
            ),
            LightTeam(
              match["red_1_team"]["id"] as int,
              match["red_1_team"]["number"] as int,
              match["red_1_team"]["name"] as String,
            ),
            LightTeam(
              match["red_2_team"]["id"] as int,
              match["red_2_team"]["number"] as int,
              match["red_2_team"]["name"] as String,
            )
          ];
          return CoachData(blueAlliance, redAlliance);
        }) ??
        (throw Exception("No data :(")),
  );
}

class CoachData {
  const CoachData(this.blueAlliance, this.redAlliance);
  final List<LightTeam> blueAlliance;
  final List<LightTeam> redAlliance;
}

Widget teamData(final LightTeam team) {
  return Text(team.number.toString());
}
