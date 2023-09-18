import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";

class IdTable {
  IdTable(final Map<String, int> nameToId)
      : this._inner(
          nameToId: Map<String, int>.unmodifiable(nameToId),
          idToName: Map<int, String>.unmodifiable(
            <int, String>{
              for (final MapEntry<String, int> e in nameToId.entries)
                e.value: e.key,
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
    required final Map<String, int> balanceIds,
    required final Map<String, int> drivetrainIds,
    required final Map<String, int> drivemotorIds,
    required final Map<String, int> matchTypeIds,
    required final Map<String, int> robotMatchStatusIds,
    required final Map<String, int> faultStatus,
    required final Map<String, int> startingPositionIds,
    required final Map<String, int> defense,
  }) : this._inner(
          child: child,
          balance: IdTable(balanceIds),
          driveTrain: IdTable(drivetrainIds),
          drivemotor: IdTable(drivemotorIds),
          matchType: IdTable(matchTypeIds),
          robotMatchStatus: IdTable(robotMatchStatusIds),
          faultStatus: IdTable(faultStatus),
          startingPositionIds: IdTable(startingPositionIds),
          defense: IdTable(defense),
        );

  IdProvider._inner({
    required super.child,
    required this.balance,
    required this.driveTrain,
    required this.drivemotor,
    required this.matchType,
    required this.robotMatchStatus,
    required this.faultStatus,
    required this.startingPositionIds,
    required this.defense,
  });
  final IdTable robotMatchStatus;
  final IdTable matchType;
  final IdTable balance;
  final IdTable driveTrain;
  final IdTable drivemotor;
  final IdTable faultStatus;
  final IdTable startingPositionIds;
  final IdTable defense;
  @override
  bool updateShouldNotify(final IdProvider oldWidget) =>
      balance != oldWidget.balance ||
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
    required super.child,
    required this.numberToTeam,
  });
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
