import 'package:scouting_frontend/views/widgets/main_app_bar.dart';
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
      home: Scaffold(
        appBar: MainAppBar(),
        body: UserInput(),
      ),
    );
  }
}
