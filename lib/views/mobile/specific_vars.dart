import 'package:scouting_frontend/views/mobile/hasura_vars.dart';

class SpecificVars implements HasuraVars {
  int? teamId;
  String message = '';
  @override
  Map<String, dynamic> toHasuraVars() {
    return <String, dynamic>{
      'team_id': teamId,
      'message': message,
    };
  }

  void reset() {
    teamId = null;
    message = '';
  }
}
