import 'package:scouting_frontend/net/get_teams_api.dart';
import 'package:scouting_frontend/views/mobile/main_app_bar.dart';
import 'package:scouting_frontend/views/mobile/screens/input_view.dart';
import 'package:scouting_frontend/views/constants.dart';

import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/pc/team_info_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Orbit Scouting',
      home: isPC(context)
          // ? TeamInfoScreen(data: GetTeamsApi.randomData())
          ? FutureBuilder(
              future: GetTeamsApi.randomData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error has happened in the future!');
                } else {
                  return Center(
                    child: Icon(
                      Icons.verified,
                      color: bgColor,
                      size: 100,
                    ),
                  );
                  // return TeamInfoScreen(data: snapshot.data);
                }
              },
            )
          : Scaffold(appBar: MainAppBar(), body: UserInput()),
      theme: darkModeTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
