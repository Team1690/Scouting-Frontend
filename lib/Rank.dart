import 'package:flutter/material.dart';

class Rank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 20,
      ),
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(.2),
          1: FractionColumnWidth(.3),
          2: FractionColumnWidth(.3),
          4: FractionColumnWidth(.3),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            Text('Rank'),
            Text('Team Number'),
            Text('Shot in target'),
            Text('climbs'),
          ]),
          TableRow(children: [
            TableCell(child: Text('1')),
            TableCell(child: Text('1690')),
            TableCell(child: Text('47')),
            TableCell(child: Text('5')),
            // Text('1690'),
            // Text('47'),
            // Text('5'),
          ]),
        ],
      ),
    );
  }
}
