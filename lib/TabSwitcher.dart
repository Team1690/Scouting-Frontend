import 'package:flutter/material.dart';

class TabSwitcher extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(final BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppBar(
        title: Text('Orbit Scouting'),
        bottom: TabBar(
          tabs: [
            Tab(
              // icon: Icon(Icons.flash_on),
              text: 'Input',
            ),
            Tab(
              // icon: Icon(Icons.sync),
              text: 'Data',
            ),
          ],
        ),
      ),
    );
  }
}
