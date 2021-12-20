import 'package:scouting_frontend/views/mobile/HasuraVars.dart';

class SpecificVars implements HasuraVars {
  int teamId;
  String message = '';
  @override
  Map<String, dynamic> toHasuraVars() {
    return {
      'team_id': teamId,
      'message': message,
    };
  }

  void reset() {
    teamId = null;
    message = '';
  }
}
