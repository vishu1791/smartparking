class ParkingSession {
  final String slotId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationInSeconds;
  final double totalCost;

  ParkingSession({
    required this.slotId,
    required this.startTime,
    required this.endTime,
    required this.durationInSeconds,
    required this.totalCost,
  });

  Map<String, dynamic> toJson() {
    return {
      'slotId': slotId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationInSeconds': durationInSeconds,
      'totalCost': totalCost,
    };
  }

  factory ParkingSession.fromJson(Map<String, dynamic> json) {
    return ParkingSession(
      slotId: json['slotId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      durationInSeconds: json['durationInSeconds'],
      totalCost: (json['totalCost'] as num).toDouble(),
    );
  }
}
