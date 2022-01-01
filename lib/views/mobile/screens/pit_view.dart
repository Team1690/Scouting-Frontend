import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:graphql/client.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/net/hasura_helper.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/mobile/file_picker_widget.dart';
import 'package:scouting_frontend/views/mobile/firebase_submit_button.dart';
import 'package:scouting_frontend/views/mobile/pit_vars.dart';
import 'package:scouting_frontend/views/mobile/slider.dart';
import 'package:scouting_frontend/views/mobile/selector.dart';
import 'package:scouting_frontend/views/mobile/team_selection_future.dart';
import 'package:scouting_frontend/views/mobile/counter.dart';
import 'package:scouting_frontend/views/mobile/section_divider.dart';
import 'package:scouting_frontend/views/mobile/submit_button.dart';
import 'package:scouting_frontend/views/mobile/switcher.dart';
import 'package:scouting_frontend/views/mobile/teams_dropdown.dart';
import 'package:scouting_frontend/views/pc/widgets/teams_search_box.dart';

class PitView extends StatelessWidget {
  PitView({Key key}) : super(key: key);
  LightTeam team;

  final List<String> driveTrains = [
    'Choose a DriveTrain',
    'Westcoast',
    'Kit Chassis',
    'Custom Tank',
    'Swerve',
    'Mecanum/H',
    'Other',
  ];

  final List<String> driveMotors = [
    'Choose a Drive Motor',
    'Falcon',
    'Neo',
    'CIM',
    'Mini CIM',
    'Other',
  ];

  FilePickerResult result;

  PitVars vars = PitVars();

  final TextEditingController wheelTypeController = TextEditingController();
  final TextEditingController teamSelectionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final AdvancedSwitchController advancedSwitchController =
      AdvancedSwitchController();

  void resetFrame(BuildContext context) {
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

    (context as Element).reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Pit Scouting')),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [
              TeamSelectionFuture(
                controller: teamSelectionController,
                onChange: (lightTeam) {
                  team = lightTeam;
                  vars.teamId = team.id;
                },
              ),
              SectionDivider(label: 'Drive Train'),
              Selector(
                value: vars.driveTrainType,
                values: driveTrains,
                initialValue: PitVars.driveTrainInitialValue,
                onChange: (newValue) {
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
                onChange: (newValue) {
                  vars.driveMotorType = newValue;
                },
              ),
              SizedBox(
                height: 20,
              ),
              Counter(
                label: 'Drive Motors',
                icon: Icons.adjust,
                count: vars.driveMotorAmount,
                upperLimit: 10,
                lowerLimit: 2,
                stepValue: 2,
                longPressedValue: 4,
                onChange: (newValue) {
                  vars.driveMotorAmount = newValue;
                },
              ),
              SizedBox(
                height: 20,
              ),
              Switcher(
                labels: [
                  'Shifter',
                  'No shifter',
                ],
                colors: [
                  Colors.white,
                  Colors.white,
                ],
                onChange: (newValue) {
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
                labels: [
                  'Purchased GearBox',
                  'Custom GearBox',
                ],
                colors: [
                  Colors.white,
                  Colors.white,
                ],
                onChange: (newValue) {
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
                onChanged: (value) {
                  vars.driveWheelType = value;
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(
                      10, defaultPadding, 10, defaultPadding),
                  hintText: 'Drive Wheel type',
                  hintStyle: TextStyle(fontSize: 14),
                ),
              ),
              SectionDivider(label: 'General Robot Reliability'),
              PitViewSlider(
                label: 'Drive Train Reliablity:',
                value: vars.driveTrainReliability,
                onChange: (newVal) {
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
                label: 'Electronics Reliability',
                value: vars.electronicsReliability,
                divisions: 4,
                min: 1,
                max: 5,
                onChange: (newValue) {
                  vars.electronicsReliability = newValue;
                },
              ),
              SizedBox(
                height: 8,
              ),
              PitViewSlider(
                label: 'Robot Reliability',
                value: vars.robotReliability,
                divisions: 9,
                max: 10,
                min: 1,
                onChange: (newValue) {
                  vars.robotReliability = newValue;
                },
              ),
              SizedBox(
                height: 8,
              ),
              SectionDivider(label: 'Robot Image'),
              FilePickerWidget(
                controller: advancedSwitchController,
                onImagePicked: (newResult) => result = newResult,
              ),
              SectionDivider(label: 'Notes'),
              TextField(
                textDirection: TextDirection.rtl,
                controller: notesController,
                onChanged: (text) {
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
