import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";

class TeamStation {
  TeamStation({
    required this.allianceColor,
    required this.alliancePos,
    required this.team,
  });
  final LightTeam team;
  final int alliancePos;
  final String allianceColor;
  MaterialColor getColor() =>
      allianceColor == "blue" ? Colors.blue : Colors.red;
  String getText() =>
      "${team.number} ${team.name} - $allianceColor ${alliancePos + 1}";
}

class ScheduleMatch {
  ScheduleMatch({
    required this.matchNumber,
    required this.matchTypeId,
    required this.id,
    required this.happened,
  });
  List<LightTeam> getTeams(final BuildContext context) =>
      throw (Exception("tried to reach parent function returnTeams"));
  final bool happened;
  final int id;
  final int matchNumber;
  final int matchTypeId;
  String getTeamStationText(final LightTeam team) =>
      throw (Exception("tried to reach parent function getTeamStation"));
  List<TeamStation> getStations() => <TeamStation>[];
  LightTeam? getTeamByStation(final String color, final int index) => null;
  TeamStation getTeamStation(final LightTeam team) =>
      throw (Exception("tried to reach parent function getTeamStation"));
  bool isOfficial() => false;
}

class OfficialMatch extends ScheduleMatch {
  OfficialMatch({
    required final bool happened,
    required final int matchNumber,
    required final int matchTypeId,
    required final int id,
    required this.teams,
  }) : super(
          happened: happened,
          matchNumber: matchNumber,
          matchTypeId: matchTypeId,
          id: id,
        );
  final List<TeamStation> teams;
  @override
  bool isOfficial() => true;
  @override
  LightTeam? getTeamByStation(final String color, final int index) {
    final TeamStation? teamStation = teams.firstWhereOrNull(
      (final TeamStation station) =>
          station.allianceColor == color && station.alliancePos == index,
    );
    return teamStation
        .mapNullable((final TeamStation teamStation) => teamStation.team);
  }

  @override
  TeamStation getTeamStation(final LightTeam team) => teams.firstWhere(
        (final TeamStation teamStation) => teamStation.team == team,
        orElse: () => throw (Exception(
          "${team.number} ${team.name} not found in any alliance",
        )),
      );
  @override
  List<TeamStation> getStations() => teams;
  @override
  List<LightTeam> getTeams(final BuildContext context) =>
      teams.map((final TeamStation teamStation) => teamStation.team).toList();
  @override
  String getTeamStationText(final LightTeam team) =>
      getTeamStation(team).getText();
}

class UnofficialMatch extends ScheduleMatch {
  UnofficialMatch({
    required final bool happened,
    required final int matchNumber,
    required final int matchTypeId,
    required final int id,
  }) : super(
          happened: happened,
          matchNumber: matchNumber,
          matchTypeId: matchTypeId,
          id: id,
        );
  @override
  @override
  List<LightTeam> getTeams(final BuildContext context) =>
      TeamProvider.of(context).teams;
  @override
  String getTeamStationText(final LightTeam team) =>
      "${team.number} ${team.name}";
}
