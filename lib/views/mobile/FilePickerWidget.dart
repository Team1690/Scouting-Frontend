import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:scouting_frontend/views/constants.dart';

class FilePickerWidget extends StatefulWidget {
  FilePickerWidget({Key key}) : super(key: key);
  static FilePickerResult result;
  static AdvancedSwitchController controller = AdvancedSwitchController();
  @override
  _FilePickerWidgetState createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: defaultPadding),
          child: ElevatedButton(
            onPressed: () async {
              FilePickerWidget.result = await FilePicker.platform
                  .pickFiles(type: FileType.image, allowMultiple: false);
              if (FilePickerWidget.result == null) return;
              FilePickerWidget.controller.value = true;
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload),
                Text(
                  ' Pick File',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        AdvancedSwitch(
          width: 105,
          controller: FilePickerWidget.controller,
          enabled: false,
          activeColor: Colors.green,
          inactiveColor: Colors.red,
          activeChild: Text('File Selected'),
          inactiveChild: Text('No File Selected'),
        )
      ],
    );
  }
}
