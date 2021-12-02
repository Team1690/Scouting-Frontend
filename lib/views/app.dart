import 'package:scouting_frontend/views/mobile/main_app_bar.dart';
import 'package:scouting_frontend/views/mobile/SideNavBar.dart';
import 'package:scouting_frontend/views/mobile/screens/input_view.dart';
import 'package:scouting_frontend/views/constants.dart';

import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/pc/team_info_screen.dart';
import 'package:scouting_frontend/views/mobile/SideNavBar.dart';

class App extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Orbit Scouting',
      home: isPC(context)
          ? TeamInfoScreen(data: GetTeamsApi.randomData())
          : Scaffold(appBar: MainAppBar(), body: UserInput(), drawer: SideNavBar(),),
      theme: darkModeTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
