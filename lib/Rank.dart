import 'package:flutter/material.dart';

class Rank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        // vertical: 20,
      ),
      child: DataTable(
        columnSpacing: 10,
        columns: [
          DataColumn(label: Text('Rank')),
          DataColumn(label: Text('Team Number')),
          DataColumn(label: Text('Shots in target')),
          DataColumn(label: Text('climbs')),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('1')),
            DataCell(Text('1690')),
            DataCell(Text('47')),
            DataCell(Text('5')),
          ]),
          DataRow(cells: [
            DataCell(Text('2')),
            DataCell(Text('3339')),
            DataCell(Text('0')),
            DataCell(Text('3')),
          ]),
          DataRow(cells: [
            DataCell(Text('3')),
            DataCell(Text('1574')),
            DataCell(Text('15')),
            DataCell(Text('10')),
          ]),
        ],
      ),
    );
  }
}
