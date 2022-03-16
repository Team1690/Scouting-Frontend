import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";

class IdTable {
  IdTable(final Map<String, int> nameToId)
      : this._inner(
          nameToId: Map<String, int>.unmodifiable(nameToId),
          idToName: Map<int, String>.unmodifiable(
            <int, String>{
              for (final MapEntry<String, int> e in nameToId.entries)
                e.value: e.key
            },
          ),
        );

  const IdTable._inner({required this.idToName, required this.nameToId});
  final Map<String, int> nameToId;
  final Map<int, String> idToName;
}

class IdProvider extends InheritedWidget {
  IdProvider({
    required final Widget child,
    required final Map<String, int> climbIds,
    required final Map<String, int> drivetrainIds,
    required final Map<String, int> drivemotorIds,
    required final Map<String, int> matchTypeIds,
    required final Map<String, int> robotMatchStatusIds,
    required final Map<String, int> faultStatus,
  }) : this._inner(
          child: child,
          climb: IdTable(climbIds),
          driveTrain: IdTable(drivetrainIds),
          drivemotor: IdTable(drivemotorIds),
          matchType: IdTable(matchTypeIds),
          robotMatchStatus: IdTable(robotMatchStatusIds),
          faultStatus: IdTable(faultStatus),
        );

  IdProvider._inner({
    required final Widget child,
    required this.climb,
    required this.driveTrain,
    required this.drivemotor,
    required this.matchType,
    required this.robotMatchStatus,
    required this.faultStatus,
  }) : super(child: child);
  final IdTable robotMatchStatus;
  final IdTable matchType;
  final IdTable climb;
  final IdTable driveTrain;
  final IdTable drivemotor;
  final IdTable faultStatus;
  @override
  bool updateShouldNotify(final IdProvider oldWidget) =>
      climb != oldWidget.climb ||
      driveTrain != oldWidget.driveTrain ||
      drivemotor != oldWidget.drivemotor;
  static IdProvider of(final BuildContext context) {
    final IdProvider? result =
        context.dependOnInheritedWidgetOfExactType<IdProvider>();
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
          numberToTeam: Map<int, LightTeam>.unmodifiable(
            <int, LightTeam>{for (final LightTeam e in teams) e.number: e},
          ),
        );
  const TeamProvider._inner({
    required final Widget child,
    required final this.numberToTeam,
  }) : super(child: child);
  final Map<int, LightTeam> numberToTeam;
  List<LightTeam> get teams => numberToTeam.values.toList();
  @override
  bool updateShouldNotify(final TeamProvider oldWidget) =>
      numberToTeam != oldWidget.numberToTeam || teams != oldWidget.teams;

  static TeamProvider of(final BuildContext context) {
    final TeamProvider? result =
        context.dependOnInheritedWidgetOfExactType<TeamProvider>();
    assert(result != null, "No Teams found in context");
    return result!;
  }
}
