import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/file_picker_widget.dart";
import "package:scouting_frontend/views/mobile/firebase_submit_button.dart";
import "package:scouting_frontend/views/mobile/pit_vars.dart";
import "package:scouting_frontend/views/mobile/slider.dart";
import "package:scouting_frontend/views/mobile/selector.dart";
import "package:scouting_frontend/views/mobile/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/counter.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/switcher.dart";

class PitView extends StatefulWidget {
  PitView();

  @override
  State<PitView> createState() => _PitViewState();
}

class _PitViewState extends State<PitView> {
  LightTeam? team;

  final List<String> driveTrains = <String>[
    "Choose a DriveTrain",
    "Westcoast",
    "Kit Chassis",
    "Custom Tank",
    "Swerve",
    "Mecanum/H",
    "Other",
  ];

  final List<String> driveMotors = <String>[
    "Choose a Drive Motor",
    "Falcon",
    "Neo",
    "CIM",
    "Mini CIM",
    "Other",
  ];

  FilePickerResult? result;

  PitVars vars = PitVars();

  final TextEditingController wheelTypeController = TextEditingController();

  final TextEditingController teamSelectionController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  final ValueNotifier<bool> advancedSwitchController =
      ValueNotifier<bool>(false);

  void resetFrame(final BuildContext context) {
    setState(() {
      vars.reset();

      if (!driveTrains.contains(PitVars.driveTrainInitialValue)) {
        driveTrains.add(PitVars.driveTrainInitialValue);
      }

      if (!driveMotors.contains(PitVars.driveMotorInitialValue)) {
        driveMotors.add(PitVars.driveMotorInitialValue);
      }

      notesController.clear();
      wheelTypeController.clear();
      teamSelectionController.clear();
      result = null;
      advancedSwitchController.value = false;
    });
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Pit"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: <Widget>[
              TeamSelectionFuture(
                controller: teamSelectionController,
                onChange: (final LightTeam lightTeam) {
                  vars.teamId = lightTeam.id;
                },
              ),
              SectionDivider(label: "Drive Train"),
              Selector(
                value: vars.driveTrainType,
                values: driveTrains,
                initialValue: PitVars.driveTrainInitialValue,
                onChange: (final String newValue) {
                  vars.driveTrainType = newValue;
                },
              ),
              SizedBox(
                height: 20,
              ),
              Selector(
                value: vars.driveMotorType,
                values: driveMotors,
                initialValue: PitVars.driveMotorInitialValue,
                onChange: (final String newValue) {
                  vars.driveMotorType = newValue;
                },
              ),
              SizedBox(
                height: 20,
              ),
              Counter(
                label: "Drive Motors",
                icon: Icons.adjust,
                count: vars.driveMotorAmount,
                upperLimit: 10,
                lowerLimit: 2,
                stepValue: 2,
                longPressedValue: 4,
                onChange: (final int newValue) {
                  vars.driveMotorAmount = newValue;
                },
              ),
              SizedBox(
                height: 20,
              ),
              Switcher(
                labels: <String>[
                  "Shifter",
                  "No shifter",
                ],
                colors: <Color>[
                  Colors.white,
                  Colors.white,
                ],
                onChange: (final int newValue) {
                  vars.shifter = newValue == -1
                      ? null
                      : newValue == 0
                          ? "Has a Shifter"
                          : "No Shifter";
                },
              ),
              SizedBox(
                height: 20,
              ),
              Switcher(
                labels: <String>[
                  "Purchased GearBox",
                  "Custom GearBox",
                ],
                colors: <Color>[
                  Colors.white,
                  Colors.white,
                ],
                onChange: (final int newValue) {
                  vars.gearbox = newValue == -1
                      ? null
                      : newValue == 0
                          ? "Purchased gearbox"
                          : "Custom gearbox";
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: wheelTypeController,
                onChanged: (final String value) {
                  vars.driveWheelType = value;
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(
                    10,
                    defaultPadding,
                    10,
                    defaultPadding,
                  ),
                  hintText: "Drive Wheel type",
                  hintStyle: TextStyle(fontSize: 14),
                ),
              ),
              SectionDivider(label: "General Robot Reliability"),
              PitViewSlider(
                label: "Drive Train Reliablity:",
                value: vars.driveTrainReliability,
                onChange: (final double newVal) {
                  vars.driveTrainReliability = newVal;
                },
                divisions: 4,
                max: 5,
                min: 1,
              ),
              SizedBox(
                height: 8,
              ),
              PitViewSlider(
                label: "Electronics Reliability",
                value: vars.electronicsReliability,
                divisions: 4,
                min: 1,
                max: 5,
                onChange: (final double newValue) {
                  vars.electronicsReliability = newValue;
                },
              ),
              SizedBox(
                height: 8,
              ),
              PitViewSlider(
                label: "Robot Reliability",
                value: vars.robotReliability,
                divisions: 9,
                max: 10,
                min: 1,
                onChange: (final double newValue) {
                  vars.robotReliability = newValue;
                },
              ),
              SizedBox(
                height: 8,
              ),
              SectionDivider(label: "Robot Image"),
              FilePickerWidget(
                controller: advancedSwitchController,
                onImagePicked: (final FilePickerResult? newResult) =>
                    result = newResult,
              ),
              SectionDivider(label: "Notes"),
              TextField(
                textDirection: TextDirection.rtl,
                controller: notesController,
                onChanged: (final String text) {
                  vars.notes = text;
                },
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 4.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 4.0),
                  ),
                  fillColor: secondaryColor,
                  filled: true,
                ),
                maxLines: 18,
              ),
              SizedBox(
                height: 20,
              ),
              FireBaseSubmitButton(
                result: () => result!,
                mutation: """
      mutation MyMutation(
          \$url: String,
          \$drive_motor_amount: Int,
          \$drive_motor_type: String,
          \$drive_train_reliability: Int,
          \$drive_train_type: String,
          \$drive_wheel_type: String,
          \$electronics_reliability: Int,
          \$gearbox: String,
          \$notes:String, 
          \$robot_reliability:Int,
          \$shifter:String,
          \$team_id:Int) {
      insert_pit(objects: {
      url: \$url,
      drive_motor_amount: \$drive_motor_amount,
      drive_motor_type: \$drive_motor_type,
      drive_train_reliability: \$drive_train_reliability,
      drive_train_type: \$drive_train_type,
      drive_wheel_type: \$drive_wheel_type,
      electronics_reliability: \$electronics_reliability,
      gearbox: \$gearbox,
      notes: \$notes,
      robot_reliability: \$robot_reliability,
      shifter: \$shifter,
      team_id: \$team_id
      }) {
          returning {
              drive_motor_amount
      drive_motor_type
      drive_train_reliability
      drive_train_type
      drive_wheel_type
      electronics_reliability
      gearbox
      id
      notes
      robot_reliability
      shifter
      team_id
      url
          }
      }
      }
      """,
                vars: vars,
                resetForm: () => resetFrame(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}
