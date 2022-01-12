import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';

const String teamInfoQuery = """
query MyQuery(\$id: Int!) {
  team_by_pk(id: \$id) {
    pit {
      drive_motor_amount
      drive_train_reliability
      drive_wheel_type
      electronics_reliability
      gearbox
      notes
      robot_reliability
      shifter
      url
      drivetrain {
        title
      }
      drivemotor {
        title
      }
    }
    specifics {
      message
    }
    matches_aggregate {
      aggregate {
        avg {
          auto_lower
          auto_upper
          auto_upper_missed
          tele_lower
          tele_upper
          tele_upper_missed
        }
      }
    }
    matches(order_by: {match_number: asc}) {
      climb {
        name
      }
      auto_lower
      auto_upper
      auto_upper_missed
      match_number
      tele_lower
      tele_upper
      tele_upper_missed
    }
  }
}

""";

class QuickData {
  QuickData({
    required this.avgAutoLowScored,
    required this.avgAutoUpperMissed,
    required this.avgAutoUpperScored,
    required this.avgBallPoints,
    required this.avgClimbPoints,
    required this.avgTeleLowScored,
    required this.avgTeleUpperMissed,
    required this.avgTeleUpperScored,
    required this.scorePercentAutoUpper,
    required this.scorePercentTeleUpper,
  });
  final double avgBallPoints;
  final double avgClimbPoints;
  final double avgAutoUpperScored;
  final double avgAutoUpperMissed;
  final double avgAutoLowScored;
  final double scorePercentAutoUpper;
  final double avgTeleUpperScored;
  final double avgTeleUpperMissed;
  final double avgTeleLowScored;
  final double scorePercentTeleUpper;
}

class SpecificData {
  SpecificData(this.msg);
  final List<String> msg;
}

class LineChartData {
  LineChartData({required this.points, required this.title});
  List<List<double>> points;
  String title = "";
}

class PitData {
  PitData({
    required this.driveTrainType,
    required this.driveMotorAmount,
    required this.driveMotorType,
    required this.driveTrainReliability,
    required this.driveWheelType,
    required this.electronicsReliability,
    required this.gearbox,
    required this.notes,
    required this.robotReliability,
    required this.shifter,
    required this.url,
  });
  final String driveTrainType;
  final int driveMotorAmount;
  final String driveWheelType;
  final String shifter;
  final String gearbox;
  final String driveMotorType;
  final int driveTrainReliability;
  final int electronicsReliability;
  final int robotReliability;
  final String notes;
  final String url;
}

class Team {
  Team({
    required this.team,
    required this.specificData,
    required this.pitViewData,
    required this.quickData,
    required this.climbData,
    required this.upperScoredMissedData,
    required this.upperPercentData,
    required this.lowerScoredData,
  });
  final LightTeam team;
  final SpecificData specificData;
  final PitData? pitViewData;
  final QuickData quickData;
  final LineChartData climbData;
  final LineChartData upperScoredMissedData;
  final LineChartData upperPercentData;
  final LineChartData lowerScoredData;
}

class TeamInfoDataNew extends StatefulWidget {
  TeamInfoDataNew(this.team);
  LightTeam team;

  @override
  _TeamInfoDataState createState() => _TeamInfoDataState();
}

double getClimbAverage(final List<String> climbVals) {
  final List<int> climbPoints = climbVals.map<int>((final String e) {
    switch (e) {
      case "no attempt":
      case "failed":
        return 0;
      case "level 1":
        return 4;
      case "level 2":
        return 6;
      case "level 3":
        return 10;
      case "level 4":
        return 15;
    }
    throw Exception("Not a climb value");
  }).toList();

  return climbPoints.reduce((final int a, final int b) => a + b).toDouble() /
      climbPoints.length;
}

class _TeamInfoDataState extends State<TeamInfoDataNew> {
  Future<Team?> fetchTeamInfo() async {
    final GraphQLClient client = getClient();

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(teamInfoQuery),
        variables: <String, dynamic>{
          "id": widget.team.id,
        },
      ),
    );

    result.mapQueryResult(
      (final Map<String, dynamic>? data) =>
          data.mapNullable((final Map<String, dynamic> team) {
        //couldn't use map nullable because team["team_by_pk"] is dynamic
        final Map<String, dynamic> teamByPk = team["team_by_pk"] != null
            ? team["team_by_pk"] as Map<String, dynamic>
            : throw Exception("that team doesnt exist");
        final Map<String, dynamic> pit =
            teamByPk["pit"] as Map<String, dynamic>;

        SpecificData specificData = SpecificData(
          (teamByPk["specifics"] as List<dynamic>)
              .map((final dynamic e) => e["message"] as String)
              .toList(),
        );
        final PitData? pitData =
            pit.mapNullable<PitData>((final Map<String, dynamic> p0) => PitData(
                  driveMotorAmount: pit["drive_motor_amount"] as int,
                  driveTrainReliability: pit["drive_train_reliability"] as int,
                  driveWheelType: pit["drive_wheel_type"] as String,
                  electronicsReliability: pit["electronics_reliability"] as int,
                  gearbox: pit["gearbox"] as String,
                  notes: pit["notes"] as String,
                  robotReliability: pit["robot_reliability"] as int,
                  shifter: pit["shifter"] as String,
                  url: pit["url"] as String,
                  driveTrainType: pit["drivetrain"]["title"] as String,
                  driveMotorType: pit["drivemotor"]["title"] as String,
                ));
        final double avgAutoLow = teamByPk["matches_aggregate"]["aggregate"]
                ["avg"]["auto_lower"] as double? ??
            0;
        final double avgAutoUpperMissed = teamByPk["matches_aggregate"]
                ["aggregate"]["avg"]["auto_upper_missed"] as double? ??
            0;
        final double avgAutoUpperScored = teamByPk["matches_aggregate"]
                ["aggregate"]["avg"]["auto_upper"] as double? ??
            0;
        final double avgTeleLow = teamByPk["matches_aggregate"]["aggregate"]
                ["avg"]["tele_lower"] as double? ??
            0;
        final double avgTeleUpperMissed = teamByPk["matches_aggregate"]
                ["aggregate"]["avg"]["tele_upper_missed"] as double? ??
            0;
        final double avgTeleUpperScored = teamByPk["matches_aggregate"]
                ["aggregate"]["avg"]["tele_upper"] as double? ??
            0;

        final List<String> climbVals = (teamByPk["matches"] as List<dynamic>)
            .map((final dynamic e) => e["climb"]["name"] as String)
            .toList();

        final QuickData quickData = QuickData(
            avgAutoLowScored: avgAutoLow,
            avgAutoUpperMissed: avgAutoUpperMissed,
            avgAutoUpperScored: avgAutoUpperScored,
            avgBallPoints: avgTeleUpperScored * 2 +
                avgTeleLow +
                avgAutoUpperScored * 4 +
                avgAutoLow * 2,
            avgClimbPoints: getClimbAverage(climbVals),
            avgTeleLowScored: avgTeleLow,
            avgTeleUpperMissed: avgTeleUpperMissed,
            avgTeleUpperScored: avgTeleUpperScored,
            scorePercentAutoUpper: (avgAutoUpperScored /
                    (avgAutoUpperScored + avgAutoUpperMissed)) *
                100,
            scorePercentTeleUpper: (avgTeleUpperScored /
                    (avgTeleUpperScored + avgTeleUpperMissed)) *
                100);
      }),
    );
  }

  @override
  Widget build(final BuildContext context) {
    fetchTeamInfo();
    return Container();
  }
}
