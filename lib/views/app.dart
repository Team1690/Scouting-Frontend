import 'package:scouting_frontend/views/widgets/main_app_bar.dart';
import 'package:scouting_frontend/views/input_view.dart';
import 'package:scouting_frontend/pc_views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;

class App extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    var platform = Theme.of(context).platform;

    bool pc;

    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      pc = false;
    } else if (platform == TargetPlatform.windows) {
      pc = true;
    }

    if (pc) {
      return MaterialApp(title: 'Orbit Scouting', home: PcHomeView());
    } else {
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
}
