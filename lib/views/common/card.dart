import "package:flutter/material.dart";

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    required this.title,
    required this.body,
    this.titleWidgets = const <Widget>[],
  });
  static const double padding = 20.0;
  final String title;
  final Widget body;
  final List<Widget> titleWidgets;

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3E),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  // style: TextStyle(fontSize: 10),
                ),
                ...titleWidgets
              ],
            ),
            SizedBox(
              height: padding,
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
