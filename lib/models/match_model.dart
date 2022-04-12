import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/mobile/hasura_vars.dart";

class Match implements HasuraVars {
  Match(
    final BuildContext context, {
    this.team,
    this.matchNumber,
    this.autoUpper = 0,
    this.autoLower = 0,
    this.autoMissed = 0,
    this.teleUpper = 0,
    this.teleMissed = 0,
    this.teleLower = 0,
    this.isRematch = false,
    this.climbStatus,
    this.matchTypeId,
    this.name,
  }) : robotMatchStatusId =
            IdProvider.of(context).robotMatchStatus.nameToId["Worked"]!;

  const Match.copy({
    required this.team,
    required this.matchNumber,
    required this.autoUpper,
    required this.autoLower,
    required this.autoMissed,
    required this.teleUpper,
    required this.teleMissed,
    required this.teleLower,
    required this.robotMatchStatusId,
    required this.isRematch,
    required this.climbStatus,
    required this.matchTypeId,
    required this.name,
  });

  Match copyWith({
    final int? Function()? matchNumber,
    final bool Function()? isRematch,
    final int Function()? autoUpper,
    final int Function()? autoMissed,
    final int Function()? autoLower,
    final int Function()? teleUpper,
    final int Function()? teleMissed,
    final int Function()? teleLower,
    final int? Function()? matchTypeId,
    final String? Function()? name,
    final int? Function()? climbStatus,
    final int Function()? robotMatchStatusId,
    final LightTeam? Function()? team,
  }) =>
      Match.copy(
        matchNumber: checkCopy(matchNumber, this.matchNumber),
        isRematch: checkCopy(isRematch, this.isRematch),
        autoUpper: checkCopy(autoUpper, this.autoUpper),
        autoMissed: checkCopy(autoMissed, this.autoMissed),
        autoLower: checkCopy(autoLower, this.autoLower),
        teleUpper: checkCopy(teleUpper, this.teleUpper),
        teleMissed: checkCopy(teleMissed, this.teleMissed),
        teleLower: checkCopy(teleLower, this.teleLower),
        matchTypeId: checkCopy(matchTypeId, this.matchTypeId),
        name: checkCopy(name, this.name),
        climbStatus: checkCopy(climbStatus, this.climbStatus),
        robotMatchStatusId:
            checkCopy(robotMatchStatusId, this.robotMatchStatusId),
        team: checkCopy(team, this.team),
      );

  Match clear(
    final BuildContext context,
  ) =>
      copyWith(
        team: () => null,
        matchNumber: () => null,
        autoUpper: () => 0,
        autoMissed: () => 0,
        autoLower: () => 0,
        teleUpper: () => 0,
        teleMissed: () => 0,
        teleLower: () => 0,
        climbStatus: () => null,
        isRematch: () => false,
        robotMatchStatusId: () =>
            IdProvider.of(context).robotMatchStatus.nameToId["Worked"]!,
      );

  final int? matchNumber;
  final bool isRematch;
  final int autoUpper;
  final int autoMissed;
  final int autoLower;
  final int? matchTypeId;
  final int teleUpper;
  final int teleMissed;
  final int teleLower;
  final String? name;
  final int? climbStatus;
  final int robotMatchStatusId;

  final LightTeam? team;
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      "auto_lower": autoLower,
      "auto_upper": autoUpper,
      "auto_missed": autoMissed,
      "climb_id": climbStatus,
      "match_number": matchNumber,
      "team_id": team?.id,
      "tele_lower": teleLower,
      "tele_upper": teleUpper,
      "tele_missed": teleMissed,
      "scouter_name": name,
      "match_type_id": matchTypeId,
      "robot_match_status_id": robotMatchStatusId,
      "is_rematch": isRematch,
    };
  }
}
