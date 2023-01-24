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

  void resetFrame() {
    setState(() {
      vars.reset();
      widthController.clear();
      lengthController.clear();
      weightController.text = vars.weight.toString();
      notesController.clear();
      wheelTypeController.clear();
      teamSelectionController.clear();
      result = null;
      advancedSwitchController.value = false;
    });
  }

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: node.unfocus,
      child: Scaffold(
        drawer: SideNavBar(),
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<Scaffold>(
                    builder: (final BuildContext context) => TeamsWithoutPit(),
                  ),
                );
              },
              icon: Icon(Icons.build),
            )
          ],
          centerTitle: true,
          title: Text("Pit"),
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
                    validate: (final int? p0) =>
                        p0.onNull("Please pick a drivetrain"),
                    makeItem: (final int p0) =>
                        IdProvider.of(context).driveTrain.idToName[p0]!,
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
                  SizedBox(
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
                  SizedBox(
                    height: 20,
                  ),
                  Switcher(
                    selected: vars.hasShifter
                            .mapNullable((final bool p0) => p0 ? 0 : 1) ??
                        -1,
                    labels: <String>[
                      "Shifter",
                      "No shifter",
                    ],
                    colors: <Color>[
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
                  SizedBox(
                    height: 20,
                  ),
                  Switcher(
                    selected: vars.gearboxPurchased
                            .mapNullable((final bool p0) => p0 ? 0 : 1) ??
                        -1,
                    labels: <String>[
                      "Purchased GearBox",
                      "Custom GearBox",
                    ],
                    colors: <Color>[
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
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: widthController,
                          onChanged: (final String value) {
                            vars.width = value;
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: "Width",
                            prefixIcon: Icon(Icons.compare_arrows),
                          ),
                        ),
                      ),
                      Text(" x "),
                      Expanded(
                        child: TextFormField(
                          controller: lengthController,
                          onChanged: (final String value) {
                            vars.length = value;
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: "Length",
                            prefixIcon: Icon(Icons.compare_arrows),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: weightController,
                    onChanged: (final String value) {
                      vars.weight = value.isEmpty ? 0 : int.parse(value);
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      labelText: "Weight",
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
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
                      labelText: "Drive Wheel type",
                    ),
                  ),
                  SectionDivider(label: "Robot Image"),
                  ImagePickerWidget(
                    validate: (final XFile? p0) =>
                        p0.onNull("Please pick an Image"),
                    controller: advancedSwitchController,
                    onImagePicked: (final XFile newResult) =>
                        result = newResult,
                  ),
                  SectionDivider(label: "Notes"),
                  TextField(
                    focusNode: node,
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
              \$weight:Int!,
              \$width:Int,
              \$length:Int,
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
}

class TeamsWithoutPit extends StatelessWidget {
  const TeamsWithoutPit();

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Teams without pit"),
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
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView(
              children: snapshot.data.mapNullable(
                    (final List<LightTeam> p0) => p0
                        .map(
                          (final LightTeam e) => ListTile(
                            title: Text("${e.number} ${e.name}"),
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
        parserFn: (final Map<String, dynamic> p0) =>
            (p0["team"] as List<dynamic>).map(LightTeam.fromJson).toList(),
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
