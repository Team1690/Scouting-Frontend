import 'package:scouting_frontend/net/get_teams_api.dart';
import 'package:scouting_frontend/views/mobile/main_app_bar.dart';
import 'package:scouting_frontend/views/mobile/drawer.dart';
import 'package:scouting_frontend/views/mobile/screens/input_view.dart';
import 'package:scouting_frontend/views/constants.dart';

import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/pc/team_info_screen.dart';
import 'package:scouting_frontend/views/pc/widgets/drawer_1.dart';
import 'package:scouting_frontend/views/mobile/drawer.dart';

class App extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Orbit Scouting',
      home: /*isPC(context)
          ? TeamInfoScreen(data: GetTeamsApi.randomData())
          :*/ Scaffold(appBar: MainAppBar(), body: UserInput(), drawer: Drawer1(),),
      theme: darkModeTheme,
      debugShowCheckedModeBanner: false,
    );
    
  }
}
