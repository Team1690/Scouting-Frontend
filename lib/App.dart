import 'package:ScoutingFrontend/TabSwitcher.dart';
import 'package:ScoutingFrontend/UserInput.dart';
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
      home: Scaffold(
        appBar: TabSwitcher(),
        body: UserInput(),
      ),
    );
  }
}
