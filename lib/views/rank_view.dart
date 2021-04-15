import 'package:scouting_frontend/net/get_teams_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scouting_frontend/views/widgets/rank_table.dart';

// class Rank extends StatefulWidget{
//   @override
//   _RankState createState() => _RankState();
// }
class Rank extends StatefulWidget {
  @override
  _RankState createState() => _RankState();
}

class _RankState extends State<Rank> {
  Future<http.Response> futureTeams;
  List teams;

  @override
  void initState() {
    super.initState();
    futureTeams = GetTeamsApi().fetchData();
  }

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder(
        future: futureTeams,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                // vertical: 20,
              ),
              child: RankingTable(
                teams: GetTeamsApi.teamsList,
                // numItems: numItems,
                // teamNumber: teamNumber,
                // shotsInTarget: shotsInTarget,
                // successfulClimbs: successfulClimbs,
                // shotsInTargetPrecentage: shotsInTargetPrecentage,
                // successfulClimbsPrecentage: successfulClimbsPrecentage,
              ),
            );
          }
          if (snapshot.hasError) {
            // 503 - Service Unavailable
            return Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Opps5',
                  style: TextStyle(fontSize: 100),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'status code - ${snapshot.data.statusCode}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 20,
                ),
                Image.network(
                  'https://lh3.googleusercontent.com/pw/ACtC-3cSLdYL7W8v0ZQGWY3veprH4al6C3vbj51oqX7wsfDmyIn1ySwEbg16WbKPRF-Uje06p-uBWOSynTwNnqtuFQx0OfmaoAhaKPwmlsaQOKRxB50g0lIRD5gCBPB0tV7ByY-ScjVgjQ_swedZsCDyBvKb8Q=w516-h915-no',
                  height: 450,
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
