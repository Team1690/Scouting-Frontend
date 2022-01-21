import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_signin_button/button_list.dart";
import "package:flutter_signin_button/button_view.dart";
import "package:scouting_frontend/views/constants.dart";
import "package:scouting_frontend/views/mobile/main_app_bar.dart";
import "package:scouting_frontend/views/mobile/screens/input_view.dart";
import "package:scouting_frontend/views/mobile/side_nav_bar.dart";
import "package:scouting_frontend/views/pc/team_info_screen.dart";

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      body: Center(
        child: Container(
          height: 36.0,
          child: SignInButton(
            Buttons.GoogleDark,
            onPressed: () async {
              final UserCredential? user = await signInWithGoogle(context);
              if (user != null) {
                Navigator.of(context).push(
                  MaterialPageRoute<Widget>(
                    builder: (final BuildContext context) => isPC(context)
                        ? TeamInfoScreen()
                        : Scaffold(
                            appBar: MainAppBar(),
                            body: UserInput(),
                            drawer: SideNavBar(),
                          ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

Future<UserCredential> signInWithGoogle(final BuildContext context) async {
  final GoogleAuthProvider googleProvider = GoogleAuthProvider();

  googleProvider.addScope("https://www.googleapis.com/auth/contacts.readonly");
  googleProvider.setCustomParameters(<dynamic, dynamic>{});

  // Once signed in, return the UserCredential
  return FirebaseAuth.instance.signInWithPopup(googleProvider);
}
