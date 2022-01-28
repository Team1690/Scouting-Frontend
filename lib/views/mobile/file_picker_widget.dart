import "package:flutter/material.dart";
import "package:flutter_advanced_switch/flutter_advanced_switch.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:image_picker/image_picker.dart";

class FilePickerWidget extends StatefulWidget {
  FilePickerWidget({
    required this.controller,
    required this.onImagePicked,
  });

  final ValueNotifier<bool> controller;
  final void Function(XFile) onImagePicked;

  @override
  _FilePickerWidgetState createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  @override
  Widget build(final BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: defaultPadding),
          child: ElevatedButton(
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 30,
              );
              // result = await FilePicker.platform
              //     .pickFiles(type: FileType.image, allowMultiple: false);
              image.mapNullable((final XFile p0) async {
                widget.controller.value = true;
                widget.onImagePicked(p0);
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.upload),
                Text(
                  " Pick File",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        AdvancedSwitch(
          width: 110,
          controller: widget.controller,
          enabled: false,
          activeColor: Colors.green,
          inactiveColor: Colors.red,
          activeChild: Text("File Selected"),
          inactiveChild: Text("No File Selected"),
        )
      ],
    );
  }
}
