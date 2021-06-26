import 'package:flutter/material.dart';

class ResponseCodeScreens extends StatelessWidget {
  final int statusCode;
  const ResponseCodeScreens({
    @required this.statusCode,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String message;
    switch (statusCode) {
      case 204:
        message = 'No data available';
        break;
      case 503:
        message = 'Server unavailable';
    }
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          'Opps',
          style: TextStyle(fontSize: 100),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          // 'status code - ${snapshot.data.statusCode}',
          'status code - ${statusCode}',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          message,
          style: TextStyle(fontSize: 20),
        ),
        Expanded(
          child: Icon(
            Icons.error,
            size: 50,
          ),
          // child: Image.network(
          //   'https://lh3.googleusercontent.com/pw/ACtC-3cSLdYL7W8v0ZQGWY3veprH4al6C3vbj51oqX7wsfDmyIn1ySwEbg16WbKPRF-Uje06p-uBWOSynTwNnqtuFQx0OfmaoAhaKPwmlsaQOKRxB50g0lIRD5gCBPB0tV7ByY-ScjVgjQ_swedZsCDyBvKb8Q=w516-h915-no',
          //   height: 450,
          // ),
        ),
      ],
    );
  }
}
