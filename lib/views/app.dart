import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/main_app_bar.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/screens/input_view.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/views/pc/team_info_screen.dart";

class App extends StatelessWidget {
  App({
    required this.teams,
    required this.climdIds,
    required this.driveMotorIds,
    required this.drivetrainIds,
  });
  final List<LightTeam> teams;
  final Map<String, int> climdIds;
  final Map<String, int> drivetrainIds;
  final Map<String, int> driveMotorIds;
  @override
  Widget build(final BuildContext context) {
    return Ids(
      climbIds: climdIds,
      driveMotorIds: driveMotorIds,
      driveTrains: drivetrainIds,
      child: Teams(
        teams: teams,
        child: MaterialApp(
          title: "Orbit Scouting",
          home: isPC(context)
              ? TeamInfoScreen()
              : Scaffold(
                  appBar: MainAppBar(),
                  body: UserInput(),
                  drawer: SideNavBar(),
                ),
          theme: darkModeTheme,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class Ids extends InheritedWidget {
  const Ids({
    required final Widget child,
    required this.climbIds,
    required this.driveMotorIds,
    required this.driveTrains,
  }) : super(child: child);
  final Map<String, int> climbIds;
  final Map<String, int> driveMotorIds;
  final Map<String, int> driveTrains;
  @override
  bool updateShouldNotify(covariant final Ids oldWidget) =>
      oldWidget.climbIds != climbIds ||
      oldWidget.driveMotorIds != driveMotorIds ||
      oldWidget.driveTrains != driveTrains;

  static Ids of(final BuildContext context) {
    final Ids? result = context.dependOnInheritedWidgetOfExactType<Ids>();
    assert(result != null, "No Teams found in context");
    return result!;
  }
}

class Teams extends InheritedWidget {
  const Teams({required this.teams, required final Widget child})
      : super(child: child);
  final List<LightTeam> teams;

  @override
  bool updateShouldNotify(covariant final Teams oldWidget) =>
      teams != oldWidget.teams;

  static Teams of(final BuildContext context) {
    final Teams? result = context.dependOnInheritedWidgetOfExactType<Teams>();
    assert(result != null, "No Teams found in context");
    return result!;
  }
}
