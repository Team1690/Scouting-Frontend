import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";
import "package:scouting_frontend/views/pc/team_info/widgets/pit/edit_pit.dart";
import "package:orbit_standard_library/orbit_standard_library.dart";

class PitScoutingCard extends StatelessWidget {
  PitScoutingCard(
    this.data,
  );
  final PitData data;
  @override
  Widget build(final BuildContext context) => DashboardCard(
        title: "Pit Scouting",
        body: SingleChildScrollView(
          primary: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (data.faultMessages == null ||
                  data.faultMessages!.isEmpty) ...<Widget>[
                const Row(
                  children: <Widget>[
                    Spacer(
                      flex: 5,
                    ),
                    Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                    Spacer(),
                    Text(
                      "No Faults",
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(
                      flex: 5,
                    )
                  ],
                ),
              ] else ...<Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Faults  ",
                      style: TextStyle(fontSize: 18),
                    ),
                    Icon(
                      Icons.warning,
                      color: Colors.yellow[700],
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: data.faultMessages!
                        .map(
                          (final String a) => Text(
                            a,
                            textDirection: TextDirection.rtl,
                          ),
                        )
                        .expand(
                          (final Text element) => <Widget>[
                            element,
                            const SizedBox(
                              height: 20,
                            )
                          ],
                        )
                        .toList(),
                  ),
                )
              ],
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      textAlign: TextAlign.center,
                      "Drivetrain",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                        textAlign: TextAlign.center,
                        "Drivetrain: ${data.driveTrainType}"),
                    Text(
                        textAlign: TextAlign.center,
                        "Drive motor: ${data.driveMotorType}"),
                    Text(
                        textAlign: TextAlign.center,
                        "Drive motor amount: ${data.driveMotorAmount}"),
                    Text(
                        textAlign: TextAlign.center,
                        "Drive wheel: ${data.driveWheelType}"),
                    HasSomething(
                      title: "Has shifter:",
                      value: data.hasShifer,
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      "Gearbox: ${data.gearboxPurchased.mapNullable((final bool p0) => p0 ? "purchased" : "custom") ?? "Not answered"}",
                    ),
                    Text(
                        textAlign: TextAlign.center,
                        "Weight: ${data.weight}Kg"),
                    Text(textAlign: TextAlign.center, "Width: ${data.width}cm"),
                    Text(
                        textAlign: TextAlign.center,
                        "Length: ${data.length}cm"),
                    Text(
                        textAlign: TextAlign.center,
                        "Space Between Wheels: ${data.spaceBetweenWheels}cm"),
                    Text(
                      textAlign: TextAlign.center,
                      "${data.tippedConesIntake ? "CAN" : "CAN'T"} intake tipped cones",
                    ),
                    Text(
                        textAlign: TextAlign.center,
                        "${data.canScoreTop ? "CAN" : "CAN'T"} score top"),
                    Text(
                        textAlign: TextAlign.center,
                        "Typically Intakes From: ${data.groundIntake ? "Ground, " : ""}${data.singleSubIntake ? "Single Substation, " : ""}${data.doubleSubIntake ? "Double Substation, " : ""} "),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    const Text(
                      "Notes",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      data.notes,
                      softWrap: true,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              if (!isPC(context)) ...<Widget>[
                const SizedBox(
                  height: 30,
                ),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push<Scaffold>(
                      PageRouteBuilder<Scaffold>(
                        reverseTransitionDuration:
                            const Duration(milliseconds: 700),
                        transitionDuration: const Duration(milliseconds: 700),
                        pageBuilder: (
                          final BuildContext context,
                          final Animation<double> a,
                          final Animation<double> b,
                        ) =>
                            GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Scaffold(
                            body: Center(
                              child: Hero(
                                tag: "Robot Image",
                                child: CachedNetworkImage(
                                  width: double.infinity,
                                  imageUrl: data.url,
                                  placeholder: (
                                    final BuildContext context,
                                    final String url,
                                  ) =>
                                      const CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: Hero(
                      tag: "Robot Image",
                      child: CachedNetworkImage(
                        imageUrl: data.url,
                        placeholder:
                            (final BuildContext context, final String url) =>
                                const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                )
              ],
              if (!isPC(context)) ...<Widget>[
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: SizedBox(
                    width: 90,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () async {
                        (await showDialog<PitData>(
                          context: context,
                          builder: ((final BuildContext dialogContext) =>
                              EditPit(
                                data,
                              )),
                        ));
                      },
                      child: const Text("Edit"),
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      );
}

class HasSomething extends StatelessWidget {
  const HasSomething({required this.title, required this.value});
  final bool? value;
  final String title;
  @override
  Widget build(final BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(textAlign: TextAlign.center, title),
          value.mapNullable(
                (final bool hasShifter) => hasShifter
                    ? const Icon(
                        Icons.done,
                        color: Colors.lightGreen,
                      )
                    : const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
              ) ??
              const Text(textAlign: TextAlign.center, " Not answered"),
        ],
      );
}
