import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:graphql/client.dart";
import "package:image_picker/image_picker.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/image_picker_widget.dart";
import "package:scouting_frontend/views/mobile/firebase_submit_button.dart";
import "package:scouting_frontend/views/mobile/pit_vars.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/mobile/selector.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
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
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController wheelTypeController = TextEditingController();

  final TextEditingController teamSelectionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final FocusNode node = FocusNode();
  final ValueNotifier<bool> advancedSwitchController =
      ValueNotifier<bool>(false);
  final TextEditingController weightController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();

  FormFieldValidator<String> _numericValidator(final String error) =>
      (final String? text) => int.tryParse(text ?? "").onNull(error);

  void resetFrame() {
    setState(() {
      vars.reset();
      widthController.clear();
      lengthController.clear();
      weightController.clear();
      notesController.clear();
      wheelTypeController.clear();
      teamSelectionController.clear();
      result = null;
      advancedSwitchController.value = false;
    });
  }

  @override
  Widget build(final BuildContext context) => GestureDetector(
        onTap: node.unfocus,
        child: Scaffold(
          drawer: SideNavBar(),
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<Scaffold>(
                      builder: (final BuildContext context) =>
                          const TeamsWithoutPit(),
                    ),
                  );
                },
                icon: const Icon(Icons.build),
              )
            ],
            centerTitle: true,
            title: const Text("Pit"),
          ),
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: <Widget>[
                    TeamSelectionFuture(
                      teams: TeamProvider.of(context).teams,
                      controller: teamSelectionController,
                      onChange: (final LightTeam lightTeam) {
                        vars.teamId = lightTeam.id;
                      },
                    ),
                    SectionDivider(label: "Drive Train"),
                    Selector<int>(
                      validate: (final int? result) =>
                          result.onNull("Please pick a drivetrain"),
                      makeItem: (final int drivetrainId) =>
                          IdProvider.of(context)
                              .driveTrain
                              .idToName[drivetrainId]!,
                      placeholder: "Choose a drivetrain",
                      value: vars.driveTrainType,
                      options: IdProvider.of(context)
                          .driveTrain
                          .idToName
                          .keys
                          .toList(),
                      onChange: (final int newValue) {
                        setState(() {
                          vars.driveTrainType = newValue;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Selector<int>(
                      validate: (final int? result) =>
                          result.onNull("Please pick a drivemotor"),
                      placeholder: "Choose a drivemotor",
                      makeItem: (final int drivemotorId) =>
                          IdProvider.of(context)
                              .drivemotor
                              .idToName[drivemotorId]!,
                      value: vars.driveMotorType,
                      options: IdProvider.of(context)
                          .drivemotor
                          .idToName
                          .keys
                          .toList(),
                      onChange: (final int newValue) {
                        setState(() {
                          vars.driveMotorType = newValue;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Counter(
                      count: vars.driveMotorAmount,
                      label: "Drive Motors",
                      icon: Icons.speed,
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
                    const SizedBox(
                      height: 20,
                    ),
                    Switcher(
                      selected: vars.hasShifter.mapNullable(
                            (final bool hasShifter) => hasShifter ? 0 : 1,
                          ) ??
                          -1,
                      labels: const <String>[
                        "Shifter",
                        "No shifter",
                      ],
                      colors: const <Color>[
                        Colors.white,
                        Colors.white,
                      ],
                      onChange: (final int selection) {
                        setState(() {
                          vars.hasShifter =
                              <int, bool>{1: false, 0: true}[selection];
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Switcher(
                      selected: vars.gearboxPurchased.mapNullable(
                            (final bool gearboxPurchased) =>
                                gearboxPurchased ? 0 : 1,
                          ) ??
                          -1,
                      labels: const <String>[
                        "Purchased GearBox",
                        "Custom GearBox",
                      ],
                      colors: const <Color>[
                        Colors.white,
                        Colors.white,
                      ],
                      onChange: (final int selection) {
                        setState(() {
                          vars.gearboxPurchased =
                              <int, bool>{1: false, 0: true}[selection];
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: widthController,
                            onChanged: (final String width) {
                              vars.width = width;
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              labelText: "Width",
                              prefixIcon: Icon(Icons.compare_arrows),
                            ),
                            validator: _numericValidator(
                              "please enter the robot's width",
                            ),
                          ),
                        ),
                        const Text(" x "),
                        Expanded(
                          child: TextFormField(
                            controller: lengthController,
                            onChanged: (final String length) {
                              vars.length = length;
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              labelText: "Length",
                              prefixIcon: Icon(Icons.compare_arrows),
                            ),
                            validator: _numericValidator(
                              "please enter the robot's length",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: weightController,
                      onChanged: (final String weight) {
                        vars.weight = weight;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(
                        labelText: "Weight",
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                      validator: _numericValidator(
                        "please enter the robot's weight",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: wheelTypeController,
                      onChanged: (final String wheelType) {
                        vars.driveWheelType = wheelType;
                      },
                      decoration: const InputDecoration(
                        labelText: "Drive Wheel type",
                      ),
                      validator: (final String? wheelType) =>
                          wheelType == null || wheelType.isEmpty
                              ? "please enter the robot's wheel type"
                              : null,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ToggleButtons(
                      fillColor: const Color.fromARGB(10, 244, 67, 54),
                      selectedColor: Colors.blue,
                      selectedBorderColor: Colors.blue,
                      children: const <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Ground Intake"),
                        )
                      ],
                      isSelected: <bool>[vars.hasGroundIntake],
                      onPressed: (final int i) {
                        setState(() {
                          vars.hasGroundIntake = !vars.hasGroundIntake;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ToggleButtons(
                      fillColor: const Color.fromARGB(10, 244, 67, 54),
                      selectedColor: Colors.blue,
                      selectedBorderColor: Colors.blue,
                      children: const <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Top Scoring"),
                        )
                      ],
                      isSelected: <bool>[vars.canScoreTop],
                      onPressed: (final int i) {
                        setState(() {
                          vars.canScoreTop = !vars.canScoreTop;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SectionDivider(label: "Robot Image"),
                    ImagePickerWidget(
                      validate: (final XFile? image) =>
                          image.onNull("Please pick an Image"),
                      controller: advancedSwitchController,
                      onImagePicked: (final XFile newResult) =>
                          result = newResult,
                    ),
                    SectionDivider(label: "Notes"),
                    TextField(
                      focusNode: node,
                      textDirection: TextDirection.rtl,
                      controller: notesController,
                      onChanged: (final String notes) {
                        vars.notes = notes;
                      },
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 4.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 4.0),
                        ),
                        fillColor: secondaryColor,
                        filled: true,
                      ),
                      maxLines: 18,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FireBaseSubmitButton(
                      validate: () => formKey.currentState!.validate(),
                      getResult: () => result,
                      mutation: """
          mutation InsertPit(
              \$url: String,
              \$drive_motor_amount: Int,
              \$drivemotor_id: Int,
              \$drivetrain_id: Int,
              \$drive_wheel_type: String,
              \$gearbox_purchased: Boolean,
              \$notes:String, 
              \$has_shifter:Boolean,
              \$team_id:Int,
              \$weight:Int,
              \$width:Int,
              \$length:Int,
              \$can_score_top:Boolean,
              \$has_ground_intake:Boolean,
              ) {
          insert__2023_pit(objects: {
          url: \$url,
          drive_motor_amount: \$drive_motor_amount,
          drivemotor_id: \$drivemotor_id,
          drivetrain_id: \$drivetrain_id,
          drive_wheel_type: \$drive_wheel_type,
          gearbox_purchased: \$gearbox_purchased,
          notes: \$notes,
          has_shifter: \$has_shifter,
          team_id: \$team_id,
          weight:  \$weight,
          width:  \$width,
          length:  \$length,
          has_ground_intake: \$has_ground_intake,
          can_score_top: \$can_score_top,
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
        ),
      );
}

class TeamsWithoutPit extends StatelessWidget {
  const TeamsWithoutPit();

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Teams without pit"),
          centerTitle: true,
        ),
        body: StreamBuilder<List<LightTeam>>(
          stream: fetchTeamsWithoutPit(),
          builder: (
            final BuildContext context,
            final AsyncSnapshot<List<LightTeam>> snapshot,
          ) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView(
              children: snapshot.data.mapNullable(
                    (final List<LightTeam> teams) => teams
                        .map(
                          (final LightTeam team) => ListTile(
                            title: Text("${team.number} ${team.name}"),
                          ),
                        )
                        .toList(),
                  ) ??
                  (throw Exception("No data")),
            );
          },
        ),
      );
}

Stream<List<LightTeam>> fetchTeamsWithoutPit() => getClient()
    .subscribe(
      SubscriptionOptions<List<LightTeam>>(
        parserFn: (final Map<String, dynamic> data) =>
            (data["team"] as List<dynamic>).map(LightTeam.fromJson).toList(),
        document: gql(
          r"""
query NoPit {
  team(where:  {_not: { pit: {} } }) {
    number
    name
    id
    colors_index
  }
}
""",
        ),
      ),
    )
    .map(
      queryResultToParsed,
    );
