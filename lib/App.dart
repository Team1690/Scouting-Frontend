import 'package:scouting_frontend/Rank.dart';
import 'package:scouting_frontend/TabSwitcher.dart';
import 'package:scouting_frontend/UserInput.dart';
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
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: TabSwitcher(),
          body: TabBarView(
            children: [
              UserInput(),
              Rank(),
            ],
          ),
        ),
      ),
    );
  }
}
