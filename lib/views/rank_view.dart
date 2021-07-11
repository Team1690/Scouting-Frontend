import 'package:scouting_frontend/net/get_teams_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scouting_frontend/views/scatter.dart';
import 'package:scouting_frontend/views/widgets/rank_table.dart';
import 'package:scouting_frontend/views/widgets/response_code_screens.dart';
import 'package:scouting_frontend/views/widgets/section_divider.dart';

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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Scatter(teams: GetTeamsApi.teamsList),
                    SectionDivider(label: 'Team Specific'),
                    RankingTable(
                      teams: GetTeamsApi.teamsList,
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }
}
