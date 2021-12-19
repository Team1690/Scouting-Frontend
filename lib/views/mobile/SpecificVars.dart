class SpecificVars {
  int teamId;
  String message = '';
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
