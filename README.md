# ScoutingFrontend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


login to firebase and hasura with google account


## Firebase storage with flutter setup
- download flutter with the instructions from here https://docs.flutter.dev/get-started/install  run `flutter doctor` to check that everything is ok
 - ###### (if flutter doctor says something about android commandline tools go to sdk manager in android studio and in sdk tools you can install it)
- run `flutter create your_project_name` in terminal  to create a new flutter project
- in the terminal move to the directory of the project and run `flutter pub add firebase_core` this adds a package that is needed for firebase
- run `dart pub global activate flutterfire_cli` in terminal
- add C:\Users\ **your_username** \AppData\Local\Pub\Cache\bin to the Path environment variable https://youtu.be/Kj3FSWoKYfo and reopen the terminal
- install node.js https://nodejs.org/en/ (not needed but alot easier to do next step )
- run npm install -g firebase-tools in terminal
- open https://firebase.google.com/ and create a firebase project (I prefer to disable google analytics you can read about is online)
- run firebase login in terminal and login to the accout that you made a project on
- now in your project directory run `flutterfire configure` and choose which firebase project you are connecting the flutter project with
- choose which platforms you are enabling firebase (if you run the app in a platform that you didnt choose here the app wont run)
- change your main function to look like this
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

- in the terminal move to the directory of your project and run `flutter pub add firebase_storage`
- go to your firebase console https://console.firebase.google.com/u/0/ and  enter your projects console
- click on storage and in there click get started and click next (if you want you can change the location of the server) after that click next again
- in the storage tab click rules and change `if false` to `if true` and click publish
- now you have everything setup and you can start using firebase storage 
- here is the documentation on how to use it https://firebase.flutter.dev/docs/storage/usage

## links
- https://firebase.flutter.dev/docs/overview
- https://firebase.google.com/docs/cli?hl=en

## File Picker
file_picker is a library that opens the native file explorer and lets the user pick a file from thier machine and you can use the fie throught the code https://pub.dev/packages/file_picker
 
 ### setup
run `flutter pub add file_picker` in terminal in the project directory

### example
```dart
void pickFile() async {
  final FilePickerResult result = await FilePicker.platform.pickFiles(allowMultiple: false);
  final Reference ref = FirebaseStorage.instance
    .ref('files/${DateTime.now()}.${result!.files.first.extension}');

  final  task = kIsWeb
    ? ref.putData(result!.files.first.bytes!)
    : ref.putFile(File(result!.files.first.path));

}
```
In the code here I first get the file from the user with `await FilePicker.platform.pickFiles(allowMultiple: false);`

I make a reference to the file in firebase storage.

then I upload the file to firebase storage.
### Important note
when using file_picker on flutter web the result path is null but the bytes variable is not null and you can upload the raw bytes to firebase storage with `ref.putData( )` and when using
file_picker on native the path is not null but the bytes is null and in that case I make an instance of a File object and put the path as the constructor argument and send the File object with `ref.putFile()`

