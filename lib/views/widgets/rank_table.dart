import 'package:flutter/material.dart';
import 'package:scouting_frontend/models/team_model.dart';
import 'package:scouting_frontend/views/widgets/team_card.dart';

class RankingTable extends StatefulWidget {
  RankingTable({
    Key key,
    @required this.teams,
  }) : super(key: key);

  final List<Team> teams;

  @override
  _RankingTableState createState() => _RankingTableState();
}

class _RankingTableState extends State<RankingTable> {
  int selectedIndex = -1;

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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
