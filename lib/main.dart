import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserInput(
          // title: 'Flutter Demo Home Page'
          ),
    );
  }
}

// class UserInput extends StatefulWidget {
//   UserInput({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _ createState() => _MyHomePageState();
// }

class UserInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    return Scaffold(
      appBar: AppBar(
        title: Text('Scouting System'),
      ),
      body: Container(
        width: 150,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Enter final score'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
