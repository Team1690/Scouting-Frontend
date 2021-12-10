import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:scouting_frontend/views/constants.dart';
import 'package:scouting_frontend/views/mobile/Selector.dart';
import 'package:scouting_frontend/views/mobile/section_divider.dart';
import 'package:scouting_frontend/views/mobile/switcher.dart';

class PitView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Pit Scouting')),
        ),
        body: ListView(
          children: [
            SectionDivider(label: 'Drive Train Type'),
            Container(
              padding: const EdgeInsets.fromLTRB(
                570,
                defaultPadding / 4,
                570,
                defaultPadding / 4,
              ),
              child: Selector([
                'Westcoast',
                'Kit Chassis',
                'Custom Tank',
                'Swerve',
                'Mecanum/H',
              ]),
              // child: AdvancedSwitch(
              //   controller: AdvancedSwitchController(),
              //   activeColor: primaryColor,
              //   inactiveColor: primaryColor,
              //   activeChild: Text('Tank'),
              //   inactiveChild: Text('Swerve'),
              //   height: 25,
              //   width: 100,
              //   enabled: true,
              // ),
            ),
            SectionDivider(label: 'Drive Motor'),
            Container(
              padding: const EdgeInsets.fromLTRB(
                  570, defaultPadding / 4, 570, defaultPadding / 4),
              child: Selector([
                'Falcon',
                'Neo',
                'Cim',
                'MiniCim',
                'other',
              ]),
            ),
            SectionDivider(label: "Drive Motors On Each Side"),
            Container(
              padding: const EdgeInsets.fromLTRB(
                  940, defaultPadding / 4, 940, defaultPadding / 4),
              child: TextField(
            decoration: new InputDecoration(),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly
              ]),
            ),
            SectionDivider(label: "Shifter"),
            Container(
              padding: const EdgeInsets.fromLTRB(
                  570, defaultPadding / 4, 570, defaultPadding / 4),
              child: Selector([
                'None',
                'Purchased',
                'Regular',
              ]),
            ),
          ],
        ));
  }
}
