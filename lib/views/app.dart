import 'package:scouting_frontend/views/rank_view.dart';
import 'package:scouting_frontend/views/widgets/tab_switcher.dart';
import 'package:scouting_frontend/views/input_view.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Orbit Scouting',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home:
          // DefaultTabController(
          //   length: 2,
          //   child:
          Scaffold(
        appBar:
            // AppBar(Text)
            TabSwitcher(),
        body:
            // TabBarView(
            // children: [
            UserInput(),
        //   Rank(),
        // ],
        // ),
      ),
      // ),
    );
  }
}
