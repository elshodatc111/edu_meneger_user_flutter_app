class GroupDetails {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String room;
  final String teacher;
  final String payment;
  final List<String> dates;

  GroupDetails({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.teacher,
    required this.payment,
    required this.dates,
  });

  factory GroupDetails.fromJson(Map<String, dynamic> json) {
    return GroupDetails(
      id: json['guruh_id'].toString(),
      name: json['guruh_name'],
      startTime: DateTime.parse('${json['guruh_start']}T${json['dars_time']}'),
      endTime: DateTime.parse('${json['guruh_end']}T${json['dars_time']}'),
      room: json['room'],
      teacher: json['techer'],
      payment: json['tulov_summa'],
      dates: List<String>.from(json['data'].map((item) => item['data'])),
    );
  }
}
