class Group {
  final int id; // id must be an int
  final String status;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String darsTime;
  final String room;

  Group({
    required this.id,
    required this.status,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.darsTime,
    required this.room,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['guruh_id'] as int, // Ensure this is parsed as int
      status: json['status'] as String,
      name: json['guruh_name'] as String,
      startTime: DateTime.parse(json['guruh_start'] as String),
      endTime: DateTime.parse(json['guruh_end'] as String),
      darsTime: json['dars_time'] as String,
      room: json['room'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'guruh_id': id,
    'status': status,
    'guruh_name': name,
    'guruh_start': startTime.toIso8601String(),
    'guruh_end': endTime.toIso8601String(),
    'dars_time': darsTime,
    'room': room,
  };
}
