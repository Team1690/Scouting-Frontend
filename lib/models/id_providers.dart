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
  }) : this._inner(
          child: child,
          climb: IdTable(climbIds),
          driveTrain: IdTable(drivetrainIds),
          drivemotor: IdTable(drivemotorIds),
        );
  IdProvider._inner({
    required final Widget child,
    required this.climb,
    required this.driveTrain,
    required this.drivemotor,
  }) : super(child: child);

  final IdTable climb;
  final IdTable driveTrain;
  final IdTable drivemotor;
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
          teams: teams,
          teamToId: <int, LightTeam>{for (final LightTeam e in teams) e.id: e},
        );
  const TeamProvider._inner({
    required final Widget child,
    required final this.teams,
    required final this.teamToId,
  }) : super(child: child);
  final List<LightTeam> teams;
  final Map<int, LightTeam> teamToId;

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
