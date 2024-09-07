import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:edu_meneger_user_05_08_2024/model/group_details.dart'; // Yangi model importi

class GroupShow extends StatefulWidget {
  final String groupId;

  const GroupShow({super.key, required this.groupId});

  @override
  _GroupShowState createState() => _GroupShowState();
}

class _GroupShowState extends State<GroupShow> {
  late Future<GroupDetails> groupDetails;

  @override
  void initState() {
    super.initState();
    groupDetails = fetchGroupDetails(widget.groupId);
  }

  Future<GroupDetails> fetchGroupDetails(String id) async {
    final storage = GetStorage();
    final token = storage.read('token');
    final response = await http.get(
      Uri.parse('https://edumeneger.uz/api/user/groups/show/$id'),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return GroupDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load group details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guruh haqida',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue, // Ko'k rang
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<GroupDetails>(
        future: groupDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Group Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                    child: Image.asset(
                      'assets/images/04.jpg', // Guruh uchun rasm
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.school, 'Guruh nomi:', data.name),
                        _buildInfoRow(Icons.access_time, 'Boshlanish vaqti:', _formatDate(data.startTime)),
                        _buildInfoRow(Icons.timer, 'Tugash vaqti:', _formatDate(data.endTime)),
                        _buildInfoRow(Icons.room, 'Dars xonasi:', data.room),
                        _buildInfoRow(Icons.person, 'O\'qituvchi:', data.teacher),
                        _buildInfoRow(Icons.money, 'Guruh uchun t\'lov:', data.payment.toString(),),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Dars kunlari',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(data.dates.length, (index) {
                            final date = DateTime.parse(data.dates[index]);
                            final today = DateTime.now();
                            final isToday = _isSameDay(date, today);
                            final isPast = date.isBefore(today);
                            final isFuture = date.isAfter(today);
                            final hasEnded = date.isBefore(today) && _isSameDay(date, data.endTime);

                            Color color;
                            String status;
                            if (isToday) {
                              color = Colors.blue;
                              status = 'Dars kuni';
                            } else if (hasEnded) {
                              color = Colors.green;
                              status = 'Yakunlangan';
                            } else if (isPast) {
                              color = Colors.blueGrey;
                              status = 'Darslar o\'tilgan';
                            } else {
                              color = Colors.orange;
                              status = 'Kutilmoqda';
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      '${date.toLocal().toIso8601String().split('T')[0]} - $status',
                                      style: TextStyle(color: color, fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return dateTime.toLocal().toIso8601String().split('T')[0];
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8.0),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$title ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
