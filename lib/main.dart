import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

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
        // width: 150,
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        // padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(children: [
          Counter(),
          Counter(),
        ]),
      ),
      //   children: <Widget>[
      //     Text('data'),
      //     SpinBox(
      //       min: 1,
      //       max: 100,
      //       value: 0,
      //       onChanged: (value) => print(value),
      //     ),
      //     TextFormField(
      //       decoration: InputDecoration(labelText: 'Enter final score'),
      //     ),
      //   ],
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: null,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}

class Counter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 50,
          child: Icon(
            Icons.animation,
            color: Colors.blue,
            size: 24.0,
            semanticLabel: 'Text to announce in accessibility modes',
          ),
        ),
        // Text('data'),
        Expanded(child: Text('Balls shot')),
        Expanded(
          child: SpinBox(
            min: 1,
            max: 100,
            value: 0,
            onChanged: (value) => print(value),
          ),
        ),
      ],
    );
  }
}
