class EventSession {
  final int eventSessionId;
  final DateTime eventSessionDate; // using EventSessionDate for day mapping
  final DateTime? endDateTime;
  final bool isAvailable;
  final bool isNotAttended;
  final bool isBooked;
  final bool isCanceled;
  final bool isClassSessionFull;

  EventSession({
    required this.eventSessionId,
    required this.eventSessionDate,
    required this.endDateTime,
    required this.isAvailable,
    required this.isNotAttended,
    required this.isBooked,
    required this.isCanceled,
    required this.isClassSessionFull,
  });
}
