import 'package:scouting_frontend/net/get_teams_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scouting_frontend/views/widgets/rank_table.dart';
import 'package:scouting_frontend/views/widgets/response_code_screens.dart';

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
    futureTeams = GetTeamsApi().fetchAnalytics();
  }

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder(
        future: futureTeams,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none)
            return Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return ResponseCodeScreens(statusCode: GetTeamsApi.statusCode);

          if (snapshot.hasData) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                // vertical: 20,
              ),
              child: RankingTable(
                teams: GetTeamsApi.teamsList,
              ),
            );
          }

          // if (snapshot.hasError)
          //   return ResponseCodeScreens(statusCode: snapshot.error);
          // if (snapshot.hasData) {
          //   if (snapshot.data == null) {
          //     // 503 - Service Unavailable
          //     return ResponseCodeScreens(statusCode: snapshot.error);
          //   }
          //   return Container(
          //     margin: const EdgeInsets.symmetric(
          //       horizontal: 20,
          //       // vertical: 20,
          //     ),
          //     child: RankingTable(
          //       teams: GetTeamsApi.teamsList,
          //     ),
          //   );
          // } else {
          //   return Center(child: CircularProgressIndicator());
          // }
        });
  }
}
