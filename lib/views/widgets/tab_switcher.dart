import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/rank_view.dart';

class TabSwitcher extends StatelessWidget implements PreferredSizeWidget {
  final double appBarHeight = 65;

  @override
  // Size get preferredSize => const Size.fromHeight(100);
  Size get preferredSize => Size.fromHeight(appBarHeight);

  @override
  Widget build(final BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Row(
              children: [
                GestureDetector(
                  child: Image.asset(
                    'lib/assets/willi.png',
                    // height: 40,
                    width: 30,
                  ),
                  onDoubleTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text('הטבלה של יהלי מלך הסקאוטינג'),
                          backgroundColor: Colors.amberAccent,
                        ),
                        body: Center(child: Rank()),
                      );
                    }));
                  },
                ),
                Expanded(
                  child: const Text(
                    'Orbit Scouting',
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 30),
              ],
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.black54, blurRadius: 15.0, offset: Offset(0.0, 0.75))
      ], color: ThemeData.light().accentColor),
    );
  }
}
