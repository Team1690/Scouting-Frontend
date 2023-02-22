class MatchEvent {
  MatchEvent({
    required this.eventTypeId,
    required this.timestamp,
    this.matchId,
  });
  final int timestamp;
  final int eventTypeId;
  int? matchId;

  Map<String, dynamic> toHasuraVars() => <String, dynamic>{
        "timestamp": timestamp,
        "event_type_id": eventTypeId,
        "specific_match_id": matchId,
      };
}
