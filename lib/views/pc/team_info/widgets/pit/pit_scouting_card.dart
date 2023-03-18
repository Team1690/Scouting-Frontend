import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/views/common/card.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class PitScoutingCard extends StatelessWidget {
  PitScoutingCard(this.data);
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
                Row(
                  children: const <Widget>[
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                )
              ],
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    const Text(
                      "Drivetrain",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text("Drivetrain: ${data.driveTrainType}"),
                    Text("Drive motor: ${data.driveMotorType}"),
                    Text("Drive motor amount: ${data.driveMotorAmount}"),
                    Text("Drive wheel: ${data.driveWheelType}"),
                    HasSomething(
                      title: "Has shifter:",
                      value: data.hasShifer,
                    ),
                    Text(
                      "Gearbox: ${data.gearboxPurchased.mapNullable((final bool p0) => p0 ? "purchased" : "custom") ?? "Not answered"}",
                    ),
                    Text("Weight: ${data.weight}Kg"),
                    Text("Width: ${data.width}cm"),
                    Text("Length: ${data.length}cm"),
                    Text(
                      "${data.hasGroundIntake ? "CAN" : "CAN'T"} intake ground",
                    ),
                    Text("${data.canScoreTop ? "CAN" : "CAN'T"} score top"),
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
          Text(title),
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
              const Text(" Not answered"),
        ],
      );
}
