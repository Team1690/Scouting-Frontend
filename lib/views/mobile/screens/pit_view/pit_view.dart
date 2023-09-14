import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:graphql/client.dart";
import "package:image_picker/image_picker.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:orbit_standard_library/orbit_standard_library.dart";
import "package:scouting_frontend/models/team_model.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/image_picker_widget.dart";
import "package:scouting_frontend/views/mobile/firebase_submit_button.dart";
import "package:scouting_frontend/views/mobile/pit_vars.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/common/team_selection_future.dart";
import "package:scouting_frontend/views/mobile/counter.dart";
import "package:scouting_frontend/views/mobile/section_divider.dart";
import "package:scouting_frontend/views/mobile/submit_button.dart";

class PitView extends StatefulWidget {
  const PitView([this.initialVars]);
  final PitVars? initialVars;

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
  final TextEditingController betweenWheelsController = TextEditingController();
  final List<String> driveWheelTypes = <String>[
    "Tread",
    "Colson",
    "Hi-grip",
    "Mecanum",
    "Omni",
    "Other"
  ];
  bool otherWheelSelected = false;
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
      betweenWheelsController.clear();
      result = null;
      advancedSwitchController.value = false;
      otherWheelSelected = false;
    });
  }

  @override
  void initState() {
    super.initState();
    vars = widget.initialVars ?? PitVars();
    widthController.text = vars.width;
    lengthController.text = vars.length;
    weightController.text = vars.weight;
    notesController.text = vars.notes;
    if (!driveWheelTypes.contains(vars.driveWheelType) &&
        widget.initialVars != null) {
      otherWheelSelected = true;
    }
    wheelTypeController.text = vars.driveWheelType ?? "";
    betweenWheelsController.text = vars.spaceBetweenWheels;
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
                    Visibility(
                      visible: widget.initialVars == null,
                      child: TeamSelectionFuture(
                        teams: TeamProvider.of(context).teams,
                        controller: teamSelectionController,
                        onChange: (final LightTeam lightTeam) {
                          vars.teamId = lightTeam.id;
                        },
                      ),
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
                      borderRadiusGeometry: defaultBorderRadius,
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
                      borderRadiusGeometry: defaultBorderRadius,
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
                      controller: betweenWheelsController,
                      onChanged: (final String length) {
                        vars.spaceBetweenWheels = length;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(
                        labelText: "Space Between Wheels",
                        prefixIcon: Icon(Icons.compare_arrows),
                      ),
                      validator: _numericValidator(
                        "please enter the robot's space between wheels",
                      ),
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
                    Selector<String>(
                      options: driveWheelTypes,
                      placeholder: "Choose a drive wheel",
                      value: otherWheelSelected ? "Other" : vars.driveWheelType,
                      makeItem: (final String wheelType) => wheelType,
                      onChange: (final String newValue) {
                        setState(() {
                          if (newValue == "Other") {
                            otherWheelSelected = true;
                          } else {
                            otherWheelSelected = false;
                            vars.driveWheelType = newValue;
                          }
                        });
                      },
                      validate: (final String? wheelType) =>
                          wheelType == null || wheelType.isEmpty
                              ? "please enter the robot's wheel type"
                              : null,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Visibility(
                      visible: otherWheelSelected,
                      child: TextFormField(
                        controller: wheelTypeController,
                        onChanged: (final String specifiedWheel) {
                          setState(() {
                            vars.driveWheelType = specifiedWheel;
                          });
                        },
                        validator: (final String? otherWheelOption) =>
                            otherWheelSelected &&
                                    (otherWheelOption == null ||
                                        otherWheelOption.isEmpty)
                                ? "Please specify \"Other\" wheel type"
                                : null,
                        decoration: const InputDecoration(
                          labelText: "\"Other\" drive wheel type",
                        ),
                      ),
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
                          child: Text("Tipped Cones Intake"),
                        )
                      ],
                      isSelected: <bool>[vars.tippedConesIntake],
                      onPressed: (final int i) {
                        setState(() {
                          vars.tippedConesIntake = !vars.tippedConesIntake;
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
                          child: Text("High Cones Scoring"),
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
                    SectionDivider(label: "Typical Feeder Intake"),
                    CheckBoxFormField(
                      validate: (final void p0) => vars.doubleSubIntake ||
                              vars.groundIntake ||
                              vars.singleSubIntake
                          ? null
                          : "Please Select a Typical Feeder",
                      widget: Column(
                        children: <Widget>[
                          CheckboxListTile(
                            title: const Text("Ground"),
                            value: vars.groundIntake,
                            onChanged: (final bool? value) => setState(() {
                              vars.groundIntake = value ?? false;
                            }),
                          ),
                          CheckboxListTile(
                            title: const Text("Single Substation"),
                            value: vars.singleSubIntake,
                            onChanged: (final bool? value) => setState(() {
                              vars.singleSubIntake = value ?? false;
                            }),
                          ),
                          CheckboxListTile(
                            title: const Text("Double Substation"),
                            value: vars.doubleSubIntake,
                            onChanged: (final bool? value) => setState(() {
                              vars.doubleSubIntake = value ?? false;
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: widget.initialVars == null,
                      child: Column(
                        children: <Widget>[
                          SectionDivider(label: "Robot Image"),
                          ImagePickerWidget(
                            validate: (final XFile? image) =>
                                result.onNull("Please pick an Image"),
                            controller: advancedSwitchController,
                            onImagePicked: (final XFile newResult) =>
                                result = newResult,
                          ),
                        ],
                      ),
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
                    ...<Widget>[
                      widget.initialVars == null
                          ? FireBaseSubmitButton(
                              validate: () => formKey.currentState!.validate(),
                              getResult: () => result,
                              mutation: insertMutation,
                              vars: vars,
                              resetForm: resetFrame,
                            )
                          : SubmitButton(
                              getJson: vars.toHasuraVars,
                              mutation: updateMutation,
                              resetForm: resetFrame,
                              validate: () => formKey.currentState!.validate(),
                            )
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

const String insertMutation = """
          mutation InsertPit(
              \$space_between_wheels:Int,
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
              \$tipped_cones_intake:Boolean,
              \$typical_ground_intake:Boolean,
              \$typical_single_intake:Boolean,
              \$typical_double_intake:Boolean,
              ) {
          insert__2023_pit(objects: {
          space_between_wheels: \$space_between_wheels,
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
          tipped_cones_intake: \$tipped_cones_intake,
          can_score_top: \$can_score_top,
          typical_ground_intake: \$typical_ground_intake,
          typical_single_intake: \$typical_single_intake,
          typical_double_intake: \$typical_double_intake,
          }) {
              returning {
                url
              }
          }
          }
          """;

const String updateMutation = """
          mutation UpdatePit(
              \$space_between_wheels:Int,
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
              \$tipped_cones_intake:Boolean,
              \$typical_ground_intake:Boolean,
              \$typical_single_intake:Boolean,
              \$typical_double_intake:Boolean,
              ) {
          update__2023_pit(where: {team_id: {_eq: \$team_id}}, _set: {
            space_between_wheels: \$space_between_wheels,
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
          tipped_cones_intake: \$tipped_cones_intake,
          can_score_top: \$can_score_top,
          typical_ground_intake: \$typical_ground_intake,
          typical_single_intake: \$typical_single_intake,
          typical_double_intake: \$typical_double_intake,
          }) {
    affected_rows
  }
          }
          """;

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
  team(where:  {_not: { _2023_pit: {} } }) {
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

class CheckBoxFormField extends FormField<void> {
  CheckBoxFormField({
    required final Widget widget,
    required final String? Function(void) validate,
  }) : super(
          enabled: true,
          validator: validate,
          builder: (final FormFieldState<void> state) => Column(
            children: <Widget>[
              widget,
              if (state.hasError)
                Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red),
                )
            ],
          ),
        );
}
