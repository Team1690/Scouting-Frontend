import "package:flutter/material.dart";
import "package:flutter_advanced_switch/flutter_advanced_switch.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:image_picker/image_picker.dart";

class ImagePickerWidget extends FormField<XFile> {
  ImagePickerWidget({
    required this.controller,
    required this.onImagePicked,
    required final String? Function(XFile?) validate,
  }) : super(
          enabled: true,
          validator: validate,
          builder: (final FormFieldState<XFile> state) => Column(
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
                    state.didChange(image);
                    image.mapNullable((final XFile p0) async {
                      controller.value = true;
                      onImagePicked(p0);
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.camera_alt),
                      Text(
                        " Take picture",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              AdvancedSwitch(
                width: 110,
                controller: controller,
                enabled: false,
                activeColor: Colors.green,
                inactiveColor: Colors.red,
                activeChild: Text("File Selected"),
                inactiveChild: Text("No File Selected"),
              ),
              if (state.hasError)
                Text(
                  state.errorText!,
                  style: TextStyle(color: Colors.red),
                )
            ],
          ),
        );

  final ValueNotifier<bool> controller;
  final void Function(XFile) onImagePicked;
}
