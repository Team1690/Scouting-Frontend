import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/mobile/FilePickerWidget.dart';
import 'package:scouting_frontend/views/mobile/FirebaseSubmitButton.dart';
import 'package:scouting_frontend/views/mobile/PitViewCounter.dart';
import 'package:scouting_frontend/views/mobile/PitViewSlider.dart';
import 'package:scouting_frontend/views/mobile/PitViewSwitcher.dart';
import 'package:scouting_frontend/views/mobile/PitViewSelector.dart';
import 'package:scouting_frontend/views/mobile/TeamSelection.dart';
import 'package:scouting_frontend/views/mobile/counter.dart';
import 'package:scouting_frontend/views/mobile/section_divider.dart';
import 'package:scouting_frontend/views/mobile/submit_button.dart';
import 'package:scouting_frontend/views/mobile/switcher.dart';
import 'package:scouting_frontend/views/mobile/teams_dropdown.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';

class PitView extends StatefulWidget {
  @override
  State<PitView> createState() => _PitViewState();
}

class _PitViewState extends State<PitView> {
  LightTeam team;

  final String driveTrainInitialValue = 'Choose a DriveTrain';

  String driveTrainValue = 'Choose a DriveTrain';

  final List<String> driveTrains = [
    'Choose a DriveTrain',
    'Westcoast',
    'Kit Chassis',
    'Custom Tank',
    'Swerve',
    'Mecanum/H',
    'Other',
  ];

  final String driveMotorInitialValue = 'Choose a Drive Motor';

  String driveMotorValue = 'Choose a Drive Motor';

  final List<String> driveMotors = [
    'Choose a Drive Motor',
    'Falcon',
    'Neo',
    'CIM',
    'Mini CIM',
    'Other',
  ];

  int motorAmount = 2;

  int selectedShifterIndex = -1;

  int selectedGearBoxIndex = -1;

  String wheelType = '';

  double driveTrainReliability = 1;

  double electronicsReliability = 1;

  double robotReliability = 1;

  String notes = '';

  FilePickerResult result;

  final TextEditingController wheelTypeController = TextEditingController();
  final Map<String, dynamic> map = Map();
  final TextEditingController teamSelectionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final AdvancedSwitchController advancedSwitchController =
      AdvancedSwitchController();

  void resetFrame() {
    if (!driveTrains.contains(driveTrainInitialValue)) {
      driveTrains.add(driveTrainInitialValue);
    }
    driveTrainValue = driveTrainInitialValue;
    if (!driveMotors.contains(driveMotorInitialValue)) {
      driveMotors.add(driveMotorInitialValue);
    }
    driveMotorValue = driveMotorInitialValue;
    selectedShifterIndex = -1;
    selectedGearBoxIndex = -1;
    notesController.clear();
    wheelTypeController.clear();
    driveTrainReliability = 1;
    electronicsReliability = 1;
    robotReliability = 1;
    motorAmount = 2;

    result = null;
    advancedSwitchController.value = false;
    (context as Element).reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Pit Scouting')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TeamSelection(
              onChange: (lightTeam) {
                team = lightTeam;
                map['team_id'] = team.id;
              },
            ),
            SectionDivider(label: 'Drive Train'),
            Selector(
              padding: const EdgeInsets.fromLTRB(
                  30, defaultPadding, 30, defaultPadding),
              value: driveTrainValue,
              values: driveTrains,
              initialValue: driveTrainInitialValue,
              onChange: (newValue) {
                map['drive_train_type'] = newValue;
                driveTrainValue = newValue;
              },
            ),
            Selector(
              padding: const EdgeInsets.fromLTRB(
                  30, defaultPadding, 30, defaultPadding),
              value: driveMotorValue,
              values: driveMotors,
              initialValue: driveMotorInitialValue,
              onChange: (newValue) {
                map['drive_motor_type'] = newValue;
                driveMotorValue = newValue;
              },
            ),
            PitViewCounter(
              amount: motorAmount,
              onChange: (newValue) {
                map['drive_motor_amount'] = newValue;
                motorAmount = newValue;
              },
            ),
            PitViewSwitcher(
              padding:
                  EdgeInsets.only(top: defaultPadding, bottom: defaultPadding),
              labels: [
                'Shifter',
                'No shifter',
              ],
              colors: [
                Colors.white,
                Colors.white,
              ],
              onChange: (newValue) {
                map['shifter'] = newValue == -1
                    ? null
                    : newValue == 0
                        ? "Has a Shifter"
                        : "No Shifter";
                selectedShifterIndex = newValue;
              },
            ),
            PitViewSwitcher(
              padding:
                  EdgeInsets.only(top: defaultPadding, bottom: defaultPadding),
              labels: [
                'Purchased GearBox',
                'Custom GearBox',
              ],
              colors: [
                Colors.white,
                Colors.white,
              ],
              onChange: (newValue) {
                map['gearbox'] = newValue == -1
                    ? null
                    : newValue == 0
                        ? "Purchased gearbox"
                        : "Custom gearbox";
                selectedGearBoxIndex = newValue;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: defaultPadding,
                bottom: defaultPadding,
              ),
              child: TextField(
                controller: wheelTypeController,
                onChanged: (value) {
                  map['drive_wheel_type'] = value;
                  wheelType = value;
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(
                      10, defaultPadding, 10, defaultPadding),
                  hintText: 'Drive Wheel type',
                  hintStyle: TextStyle(fontSize: 14),
                ),
              ),
            ),
            SectionDivider(label: 'General Robot Reliability'),
            PitViewSlider(
              label: 'Drive Train Reliablity:',
              value: driveTrainReliability,
              padding:
                  EdgeInsets.only(top: defaultPadding, bottom: defaultPadding),
              onChange: (newVal) {
                map['drive_train_reliability'] = newVal;
                driveTrainReliability = newVal;
              },
              divisions: 4,
              max: 5,
              min: 1,
            ),
            PitViewSlider(
              label: 'Electronics Reliability',
              padding:
                  EdgeInsets.only(top: defaultPadding, bottom: defaultPadding),
              value: electronicsReliability,
              divisions: 4,
              min: 1,
              max: 5,
              onChange: (newValue) {
                map['electronics_reliability'] = newValue;
                electronicsReliability = newValue;
              },
            ),
            PitViewSlider(
              label: 'Robot Reliability',
              padding:
                  EdgeInsets.only(top: defaultPadding, bottom: defaultPadding),
              value: robotReliability,
              divisions: 9,
              max: 10,
              min: 1,
              onChange: (newValue) {
                map['robot_reliability'] = newValue;
                robotReliability = newValue;
              },
            ),
            SectionDivider(label: 'Robot Image'),
            FilePickerWidget(
              controller: advancedSwitchController,
              onImagePicked: (newResult) => result = newResult,
            ),
            SectionDivider(label: 'Notes'),
            Padding(
              padding: const EdgeInsets.only(
                  top: defaultPadding, bottom: defaultPadding),
              child: TextField(
                textDirection: TextDirection.rtl,
                controller: notesController,
                onChanged: (text) {
                  map['notes'] = text;
                  notes = text;
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
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: defaultPadding, bottom: defaultPadding),
              child: FireBaseSubmitButton(
                result: () => result,
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
                vars: map,
                resetForm: resetFrame,
              ),
            )
          ],
        ),
      ),
    );
  }
}
