import "package:flutter/material.dart";
import "package:scouting_frontend/net/hasura_helper.dart";
import "package:scouting_frontend/views/mobile/manage_local_data.dart";
import "package:shared_preferences/shared_preferences.dart";

class ManagePreferences extends StatefulWidget {
  const ManagePreferences({required this.mutation});
  final String mutation;

  @override
  State<ManagePreferences> createState() => _ManagePreferencesState();
}

class _ManagePreferencesState extends State<ManagePreferences> {
  @override
  Widget build(final BuildContext context) => SizedBox(
        width: 200,
        child: AlertDialog(
          content: FutureBuilder<SharedPreferences>(
            future: getPrefs(),
            builder: (
              final BuildContext context,
              final AsyncSnapshot<SharedPreferences> snapshot,
            ) =>
                snapshot.mapSnapshot(
              onNoData: () => const Text("No data"),
              onError: (final Object error) => Text("$error"),
              onWaiting: CircularProgressIndicator.new,
              onSuccess: (final SharedPreferences prefs) => ManageLocalData(
                mutation: widget.mutation,
                prefs: prefs,
                onChange: () {
                  setState(() {});
                },
              ),
            ),
          ),
        ),
      );

  Future<SharedPreferences> getPrefs() => SharedPreferences.getInstance();
}
