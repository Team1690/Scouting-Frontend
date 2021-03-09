import 'dart:math';

import 'package:ScoutingFrontend/TeamData.dart';
import 'package:flutter/material.dart';

class Rank extends StatefulWidget {
  @override
  _RankState createState() => _RankState();
}

class _RankState extends State<Rank> {
  static const int numItems = 10;
  int selectedIndex = -1;

  //Demo data for card
  List<int> teamNumber =
      List<int>.generate(numItems, (index) => Random().nextInt(5000));
  List<int> shotsInTarget =
      List<int>.generate(numItems, (index) => Random().nextInt(100));
  List<int> successfulClimbs =
      List<int>.generate(numItems, (index) => Random().nextInt(100));
  List<double> shotsInTargetPrecentage =
      List<double>.generate(numItems, (index) => Random().nextDouble());
  List<double> successfulClimbsPrecentage =
      List<double>.generate(numItems, (index) => Random().nextDouble());

  @override
  Widget build(final BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        // vertical: 20,
      ),
      child: DataTable(
        sortColumnIndex: 1,
        sortAscending: true,
        columnSpacing: 10,
        showCheckboxColumn: false,
        columns: [
          DataColumn(label: Text('Rank')),
          DataColumn(label: Text('Team Number'), numeric: false),
          DataColumn(label: Text('Shots in target')),
          DataColumn(label: Text('climbs')),
        ],
        rows: List<DataRow>.generate(
          numItems,
          (index) => DataRow(
            cells: [
              DataCell(Text((index + 1).toString())),
              DataCell(Text(teamNumber[index].toString())),
              DataCell(Text(shotsInTarget[index].toString())),
              DataCell(Text(successfulClimbs[index].toString())),
            ],
            selected: index == selectedIndex,
            onSelectChanged: (value) {
              setState(() => selectedIndex = index);
              showDialog(
                context: context,
                builder: (context) => TeamData(
                  teamNumber: teamNumber[index],
                  teamName: 'ORBIT',
                  shostInTarget: shotsInTarget[index],
                  successfulClimbs: successfulClimbs[index],
                  shotsInTargetPrecent: shotsInTargetPrecentage[index],
                  successfulClimbsPrecent: successfulClimbsPrecentage[index],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
