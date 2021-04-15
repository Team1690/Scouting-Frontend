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

  List<double> shotsInTargetPrecentage = List<double>.generate(
      RankingTable.numItems, (index) => Random().nextDouble());
  List<double> successfulClimbsPrecentage = List<double>.generate(
      RankingTable.numItems, (index) => Random().nextDouble());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        sortColumnIndex: 0,
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
              DataCell(Text(widget.teams[index].shotsInTarget.toString())),
              DataCell(Text(widget.teams[index].successfulClimbs.toString())),
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
                  teamNumber: widget.teams[index].teamNumber,
                  shostInTarget: widget.teams[index].shotsInTarget,
                  successfulClimbs: widget.teams[index].successfulClimbs,
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