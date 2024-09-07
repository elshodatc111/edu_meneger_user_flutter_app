import 'package:edu_meneger_user_05_08_2024/screen/group/group_show.dart';
import 'package:flutter/material.dart';
import 'package:edu_meneger_user_05_08_2024/model/group.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  final bool isActive;

  const GroupCard({
    super.key,
    required this.group,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath;
    Color statusColor;
    String statusText;

    switch (group.status) {
      case 'New':
        imagePath = 'assets/images/01.jpg';
        statusColor = Colors.blue;
        statusText = 'Yangi';
        break;
      case 'End':
        imagePath = 'assets/images/02.jpg';
        statusColor = Colors.red;
        statusText = 'Yakunlangan';
        break;
      case 'Activ':
        imagePath = 'assets/images/03.jpg';
        statusColor = Colors.green;
        statusText = 'Aktiv';
        break;
      default:
        imagePath = 'assets/images/.jpg';
        statusColor = Colors.grey;
        statusText = 'Noaniq';
    }

    return Container(
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupShow(groupId: group.id.toString()), // Ensure id is a string
            ),
          );
        },
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      imagePath,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: statusColor.withOpacity(0.6),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.grey),
                            const SizedBox(width: 4.0),
                            Text(
                              'Dars vaqti: ${group.startTime.toLocal().toIso8601String().split('T')[1].substring(0, 5)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24.0),
                        Row(
                          children: [
                            const Icon(Icons.room, color: Colors.grey),
                            const SizedBox(width: 4.0),
                            Text(
                              'Dars xonasi: ${group.room}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('Darslar boshlanishi', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(group.startTime.toLocal().toIso8601String().split('T')[0],
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Darslar yakunlanishi', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          group.endTime.toLocal().toIso8601String().split('T')[0],
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
