class ParkingSlot {
  final String id;
  final String floorName;
  SlotStatus status;
  DateTime? startTime;
  DateTime? endTime;

  ParkingSlot({
    required this.id,
    required this.floorName,
    this.status = SlotStatus.available,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floorName': floorName,
      'status': status.name,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    return ParkingSlot(
      id: json['id'],
      floorName: json['floorName'],
      status: SlotStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SlotStatus.available,
      ),
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
}

enum SlotStatus { available, occupied, reserved }
