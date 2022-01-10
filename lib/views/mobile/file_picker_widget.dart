import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_advanced_switch/flutter_advanced_switch.dart";
import "package:scouting_frontend/views/constants.dart";

class FilePickerWidget extends StatefulWidget {
  FilePickerWidget({
    required this.controller,
    this.onImagePicked = ignore,
  }) {}
  FilePickerResult? result;
  final ValueNotifier<bool> controller;
  final void Function(FilePickerResult) onImagePicked;

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
              widget.result = await FilePicker.platform
                  .pickFiles(type: FileType.image, allowMultiple: false);
              if (widget.result == null) return;
              widget.controller.value = true;
              if (widget.result != null) widget.onImagePicked(widget.result!);
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
