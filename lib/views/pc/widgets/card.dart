import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/constants.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    Key key,
    @required this.title,
    @required this.body,
  }) : super(key: key);

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Text(
              title,
              // style: TextStyle(fontSize: 10),
            ),
            SizedBox(
              height: defaultPadding,
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
