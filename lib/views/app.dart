import 'package:scouting_frontend/net/get_teams_api.dart';
import 'package:scouting_frontend/views/mobile/main_app_bar.dart';
import 'package:scouting_frontend/views/mobile/screens/input_view.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:scouting_frontend/views/pc/team_info_screen.dart';
import 'package:scouting_frontend/views/pc/widgets/dashboard_scaffold.dart';

class App extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Orbit Scouting',
      home: isPC(context)
          ? FutureBuilder(
              future: GetTeamsApi.randomData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return TeamInfoScreen(data: snapshot.data);
                }
                return DashboardScaffold(
                    body: Center(child: CircularProgressIndicator()));
              },
            )
          : Scaffold(appBar: MainAppBar(), body: UserInput()),
      theme: darkModeTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
