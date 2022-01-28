import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
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

  XFile? result;

  PitVars vars = PitVars();

  final TextEditingController wheelTypeController = TextEditingController();

  final TextEditingController teamSelectionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final ValueNotifier<bool> advancedSwitchController =
      ValueNotifier<bool>(false);

  void resetFrame() {
    setState(() {
      vars.reset();

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Pit"),
      ),
      body: Form(
        child: SingleChildScrollView(
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
                Selector<int>(
                  validate: (final int? p0) =>
                      p0.onNull("Please pick a drivetrain"),
                  makeItem: (final int p0) =>
                      IdProvider.of(context).driveTrain.idToName[p0]!,
                  placeholder: "Choose a drivetrain",
                  value: vars.driveTrainType,
                  options:
                      IdProvider.of(context).driveTrain.idToName.keys.toList(),
                  onChange: (final int newValue) {
                    setState(() {
                      vars.driveTrainType = newValue;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Selector<int>(
                  validate: (final int? p0) =>
                      p0.onNull("Please pick a drivemotor"),
                  placeholder: "Choose a drivemotor",
                  makeItem: (final int p0) =>
                      IdProvider.of(context).drivemotor.idToName[p0]!,
                  value: vars.driveMotorType,
                  options:
                      IdProvider.of(context).drivemotor.idToName.keys.toList(),
                  onChange: (final int newValue) {
                    setState(() {
                      vars.driveMotorType = newValue;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Counter(
                  count: vars.driveMotorAmount,
                  label: "Drive Motors",
                  icon: Icons.adjust,
                  upperLimit: 10,
                  lowerLimit: 2,
                  stepValue: 2,
                  longPressedValue: 4,
                  onChange: (final int newValue) {
                    setState(() {
                      vars.driveMotorAmount = newValue;
                    });
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
                  onChange: (final int selection) {
                    vars.hasShifter = <int, bool>{1: false, 0: true}[selection];
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
                  onChange: (final int selection) {
                    vars.gearboxPurchased =
                        <int, bool>{1: false, 0: true}[selection];
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
                  value: vars.driveTrainReliability,
                  label: "Drive Train Reliablity:",
                  onChange: (final double newVal) {
                    setState(() {
                      vars.driveTrainReliability = newVal;
                    });
                  },
                  divisions: 4,
                  max: 5,
                  min: 1,
                ),
                SizedBox(
                  height: 8,
                ),
                PitViewSlider(
                  value: vars.electronicsReliability,
                  label: "Electronics Reliability",
                  divisions: 4,
                  min: 1,
                  max: 5,
                  onChange: (final double newValue) {
                    setState(() {
                      vars.electronicsReliability = newValue;
                    });
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                PitViewSlider(
                  value: vars.robotReliability,
                  label: "Robot Reliability",
                  divisions: 9,
                  max: 10,
                  min: 1,
                  onChange: (final double newValue) {
                    setState(() {
                      vars.robotReliability = newValue;
                    });
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                SectionDivider(label: "Robot Image"),
                FilePickerWidget(
                  controller: advancedSwitchController,
                  onImagePicked: (final XFile newResult) => result = newResult,
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
                  getResult: () => result,
                  mutation: """
        mutation MyMutation(
            \$url: String,
            \$drive_motor_amount: Int,
            \$drivemotor_id: Int,
            \$drive_train_reliability: Int,
            \$drivetrain_id: Int,
            \$drive_wheel_type: String,
            \$electronics_reliability: Int,
            \$gearbox_purchased: Boolean,
            \$notes:String, 
            \$robot_reliability:Int,
            \$has_shifter:Boolean,
            \$team_id:Int) {
        insert_pit(objects: {
        url: \$url,
        drive_motor_amount: \$drive_motor_amount,
        drivemotor_id: \$drivemotor_id,
        drive_train_reliability: \$drive_train_reliability,
        drivetrain_id: \$drivetrain_id,
        drive_wheel_type: \$drive_wheel_type,
        electronics_reliability: \$electronics_reliability,
        gearbox_purchased: \$gearbox_purchased,
        notes: \$notes,
        robot_reliability: \$robot_reliability,
        has_shifter: \$has_shifter,
        team_id: \$team_id
        }) {
            returning {
              url
            }
        }
        }
        """,
                  vars: vars,
                  resetForm: resetFrame,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
