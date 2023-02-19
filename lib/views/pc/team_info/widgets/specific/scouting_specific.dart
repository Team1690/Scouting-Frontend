import "package:flutter/material.dart";
import "package:scouting_frontend/models/id_providers.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/pc/team_info/models/team_info_classes.dart";

class ScoutingSpecific extends StatefulWidget {
  const ScoutingSpecific({required this.selectorValue, required this.msg});
  final String selectorValue;
  final SpecificData msg;

  @override
  State<ScoutingSpecific> createState() => _ScoutingSpecificState();
}

class _ScoutingSpecificState extends State<ScoutingSpecific> {
  @override
  Widget build(final BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SingleChildScrollView(
            primary: false,
            child: Column(
              children: widget.msg.msg
                  .map<Widget>(
                    (final SpecificMatch e) => e.isNull(widget.selectorValue)
                        ? Container()
                        : Card(
                            // shape: ,
                            elevation: 10,
                            color: bgColor,
                            margin: const EdgeInsets.fromLTRB(
                              5,
                              0,
                              5,
                              defaultPadding,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(defaultPadding),
                              child: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "${e.isRematch ? "Re " : ""}${IdProvider.of(context).matchType.idToName[e.matchTypeId].toString()} ${e.matchNumber}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${e.scouterNames}\n",
                                          style: const TextStyle(height: 0.7),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        (e.drivetrainAndDriving != null &&
                                                (widget.selectorValue ==
                                                        "All" ||
                                                    widget.selectorValue ==
                                                        "Drivetrain And Driving"))
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  const Text(
                                                    "הנעה ונהיגה:",
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style: TextStyle(
                                                      color: primaryWhite,
                                                      fontSize: 15,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                  Text(
                                                    e.drivetrainAndDriving!,
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style: const TextStyle(
                                                      color: primaryWhite,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                        (e.intake != null &&
                                                (widget.selectorValue ==
                                                        "All" ||
                                                    widget.selectorValue ==
                                                        "Intake"))
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  const Text(
                                                    "איסוף:",
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style: TextStyle(
                                                      color: primaryWhite,
                                                      fontSize: 15,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                  Text(
                                                    e.intake!,
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style: const TextStyle(
                                                      color: primaryWhite,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                        (e.placement != null &&
                                                (widget.selectorValue ==
                                                        "All" ||
                                                    widget.selectorValue ==
                                                        "Placement"))
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  const Text(
                                                    "הנחה:",
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style: TextStyle(
                                                      color: primaryWhite,
                                                      fontSize: 15,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                  Text(
                                                    e.placement!,
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style: const TextStyle(
                                                      color: primaryWhite,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                        (e.defense != null &&
                                                (widget.selectorValue ==
                                                        "All" ||
                                                    widget.selectorValue ==
                                                        "Defense"))
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  const Text(
                                                    "הגנה:",
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style: TextStyle(
                                                      color: primaryWhite,
                                                      fontSize: 15,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                  Text(
                                                    e.defense!,
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style: const TextStyle(
                                                      color: primaryWhite,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                        (e.generalNotes != null &&
                                                (widget.selectorValue ==
                                                        "All" ||
                                                    widget.selectorValue ==
                                                        "General Notes"))
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  const Text(
                                                    "הערות כלליות:",
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style: TextStyle(
                                                      color: primaryWhite,
                                                      fontSize: 15,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                  Text(
                                                    e.generalNotes!,
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style: const TextStyle(
                                                      color: primaryWhite,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  )
                  .toList(),
            ),
          ),
        ],
      );
}
