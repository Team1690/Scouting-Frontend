import 'package:flutter/material.dart';
import 'package:scouting_frontend/views/mobile/screens/rank_view.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(final BuildContext context) {
    return AppBar(
      elevation: 5,
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
                  body: Center(
                    child: Rank(),
                  ),
                );
              }));
            },
          ),
          Expanded(
            child: const Text(
              'Orbit Scouting',
              textAlign: TextAlign.center,
              // textScaleFactor: 1.1,
              style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SizedBox(width: 30),
        ],
      ),
    );
  }
}
