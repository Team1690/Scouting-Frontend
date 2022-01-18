import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";

class ClimbProvider extends InheritedWidget {
  ClimbProvider({
    required final Widget child,
    required final Map<String, int> climbIds,
  }) : this._inner(
          child: child,
          nameToId: Map<String, int>.unmodifiable(
            climbIds,
          ),
          idToName: Map<int, String>.unmodifiable(<int, String>{
            for (final MapEntry<String, int> entry in climbIds.entries)
              entry.value: entry.key
          }),
        );
  const ClimbProvider._inner({
    required final Widget child,
    required this.nameToId,
    required this.idToName,
  }) : super(child: child);
  final Map<String, int> nameToId;
  final Map<int, String> idToName;

  @override
  bool updateShouldNotify(final ClimbProvider oldWidget) =>
      idToName != oldWidget.idToName || nameToId != oldWidget.nameToId;

  static ClimbProvider of(final BuildContext context) {
    final ClimbProvider? result =
        context.dependOnInheritedWidgetOfExactType<ClimbProvider>();
    assert(result != null, "No Teams found in context");
    return result!;
  }
}

class DrivetrainProvider extends InheritedWidget {
  DrivetrainProvider({
    required final Widget child,
    required final Map<String, int> drivetrainIds,
  }) : this._inner(
          child: child,
          nameToId: Map<String, int>.unmodifiable(
            drivetrainIds,
          ),
          idToName: Map<int, String>.unmodifiable(<int, String>{
            for (final MapEntry<String, int> entry in drivetrainIds.entries)
              entry.value: entry.key
          }),
        );
  const DrivetrainProvider._inner({
    required final Widget child,
    required this.nameToId,
    required this.idToName,
  }) : super(child: child);
  final Map<String, int> nameToId;
  final Map<int, String> idToName;

  @override
  bool updateShouldNotify(final DrivetrainProvider oldWidget) =>
      idToName != oldWidget.idToName || nameToId != oldWidget.nameToId;

  static DrivetrainProvider of(final BuildContext context) {
    final DrivetrainProvider? result =
        context.dependOnInheritedWidgetOfExactType<DrivetrainProvider>();
    assert(result != null, "No Teams found in context");
    return result!;
  }
}

class DriveMotorProvider extends InheritedWidget {
  DriveMotorProvider({
    required final Widget child,
    required final Map<String, int> driveMotorIds,
  }) : this._inner(
          child: child,
          nameToId: Map<String, int>.unmodifiable(driveMotorIds),
          idToName: Map<int, String>.unmodifiable(<int, String>{
            for (final MapEntry<String, int> entry in driveMotorIds.entries)
              entry.value: entry.key
          }),
        );
  const DriveMotorProvider._inner({
    required final Widget child,
    required this.nameToId,
    required this.idToName,
  }) : super(child: child);
  final Map<String, int> nameToId;
  final Map<int, String> idToName;

  @override
  bool updateShouldNotify(final DriveMotorProvider oldWidget) =>
      idToName != oldWidget.idToName || nameToId != oldWidget.nameToId;

  static DriveMotorProvider of(final BuildContext context) {
    final DriveMotorProvider? result =
        context.dependOnInheritedWidgetOfExactType<DriveMotorProvider>();
    assert(result != null, "No Teams found in context");
    return result!;
  }
}

class TeamProvider extends InheritedWidget {
  TeamProvider({
    required final Widget child,
    required final List<LightTeam> teams,
  }) : this._inner(
          child: child,
          teams: teams,
          teamToId: <LightTeam, int>{for (final LightTeam e in teams) e: e.id},
        );
  const TeamProvider._inner({
    required final Widget child,
    required final this.teams,
    required final this.teamToId,
  }) : super(child: child);
  final List<LightTeam> teams;
  final Map<LightTeam, int> teamToId;

  @override
  bool updateShouldNotify(final TeamProvider oldWidget) =>
      teamToId != oldWidget.teamToId || teams != oldWidget.teams;

  static TeamProvider of(final BuildContext context) {
    final TeamProvider? result =
        context.dependOnInheritedWidgetOfExactType<TeamProvider>();
    assert(result != null, "No Teams found in context");
    return result!;
  }
}
