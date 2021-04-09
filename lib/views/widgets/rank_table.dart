import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/views/widgets/team_card.dart';

class RankingTable extends StatefulWidget {
  RankingTable({
    Key key,
    @required this.teams,
    // @required this.teamNumber,
    // @required this.shotsInTarget,
    // @required this.successfulClimbs,
    // @required this.shotsInTargetPrecentage,
    // @required this.successfulClimbsPrecentage,
  }) : super(key: key);

  final List<Team> teams;
  // List<int> teamNumber;
  // List<int> shotsInTarget;
  // List<int> successfulClimbs;
  // List<double> shotsInTargetPrecentage;
  // List<double> successfulClimbsPrecentage;

  static const int numItems = 50;

  @override
  _RankingTableState createState() => _RankingTableState();
}

class _RankingTableState extends State<RankingTable> {
  int selectedIndex = -1;

  List<int> teamNumber = List<int>.generate(
      RankingTable.numItems, (index) => Random().nextInt(5000));
  List<int> shotsInTarget = List<int>.generate(
      RankingTable.numItems, (index) => Random().nextInt(100));
  List<int> successfulClimbs = List<int>.generate(
      RankingTable.numItems, (index) => Random().nextInt(100));
  List<double> shotsInTargetPrecentage = List<double>.generate(
      RankingTable.numItems, (index) => Random().nextDouble());
  List<double> successfulClimbsPrecentage = List<double>.generate(
      RankingTable.numItems, (index) => Random().nextDouble());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          widget.teams.length,
          (index) => DataRow(
            cells: [
              DataCell(Text((index + 1).toString())),
              DataCell(Text(widget.teams[index].teamNumber.toString())),
              DataCell(Text(shotsInTarget[index].toString())),
              DataCell(Text(successfulClimbs[index].toString())),
            ],
            selected: index == selectedIndex,
            onSelectChanged: (value) {
              setState(() {
                selectedIndex = index;
              });
              showDialog(
                context: context,
                builder: (context) => TeamCard(
                  selectedTeam: widget.teams[index],

                  // TODO: remove this
                  teamNumber: teamNumber[index],
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
