import "package:flutter/material.dart";

import "package:scouting_frontend/views/pc/widgets/navigation_tab.dart";

class DashboardScaffold extends StatelessWidget {
  DashboardScaffold({
    required this.body,
  });

  final Widget body;

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Orbit Scouting')),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: NavigationTab(),
            ),
            Expanded(flex: 5, child: body)
          ],
        ),
      ),
    );
  }
}
