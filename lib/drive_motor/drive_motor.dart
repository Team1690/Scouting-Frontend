import "package:flutter/cupertino.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/views/mobile/pit_vars.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/views/mobile/selector.dart";

enum DriveMotor {
  falcon("Falcon"),
  neo("NEO"),
  cim("CIM"),
  miniCim("Mini CIM"),
  other("Other");

  const DriveMotor(this.title);
  final String title;
}

class DriveMotorInput extends StatefulWidget {
  DriveMotorInput({
    required this.vars,
  });
  @override
  State<DriveMotorInput> createState() => _DriveMotorInputState();
  final PitVars vars;
}

class _DriveMotorInputState extends State<DriveMotorInput> {
  @override
  Widget build(final BuildContext context) {
    return Selector<int>(
      validate: (final int? result) =>
          result.onNull("Please pick a drivemotor"),
      placeholder: "Choose a drivemotor",
      makeItem: (final int driveMotorId) =>
          IdProvider.of(context).drivemotor.idToEnum[driveMotorId]!.title,
      value: widget.vars.driveMotorType,
      options: IdProvider.of(context).drivemotor.idToEnum.keys.toList(),
      onChange: (final int newValue) {
        setState(() {
          widget.vars.driveMotorType = newValue;
        });
      },
    );
  }
}
