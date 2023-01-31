import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_enums.dart";
import "package:scouting_frontend/models/team_model.dart";

class IdTable<T extends Enum> {
  IdTable(final Map<T, int> enumToId)
      : this._inner(
          enumToId: Map<T, int>.unmodifiable(enumToId),
          idToEnum: Map<int, T>.unmodifiable(
            <int, T>{
              for (final MapEntry<T, int> e in enumToId.entries) e.value: e.key
            },
          ),
        );

  const IdTable._inner({required this.idToEnum, required this.enumToId});
  final Map<T, int> enumToId;
  final Map<int, T> idToEnum;
}

class IdProvider extends InheritedWidget {
  IdProvider({
    required final Widget child,
    required final Map<Balance, int> balanceIds,
    required final Map<DriveTrain, int> drivetrainIds,
    required final Map<DriveMotor, int> drivemotorIds,
    required final Map<MatchType, int> matchTypeIds,
    required final Map<RobotMatchStatus, int> robotMatchStatusIds,
    required final Map<FaultStatus, int> faultStatus,
  }) : this._inner(
          child: child,
          balance: IdTable<Balance>(balanceIds),
          driveTrain: IdTable<DriveTrain>(drivetrainIds),
          drivemotor: IdTable<DriveMotor>(drivemotorIds),
          matchType: IdTable<MatchType>(matchTypeIds),
          robotMatchStatus: IdTable<RobotMatchStatus>(robotMatchStatusIds),
          faultStatus: IdTable<FaultStatus>(faultStatus),
        );

  IdProvider._inner({
    required super.child,
    required this.balance,
    required this.driveTrain,
    required this.drivemotor,
    required this.matchType,
    required this.robotMatchStatus,
    required this.faultStatus,
  });
  final IdTable<RobotMatchStatus> robotMatchStatus;
  final IdTable<MatchType> matchType;
  final IdTable<Balance> balance;
  final IdTable<DriveTrain> driveTrain;
  final IdTable<DriveMotor> drivemotor;
  final IdTable<FaultStatus> faultStatus;
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
            <int, LightTeam>{
              for (final LightTeam team in teams) team.number: team
            },
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
