import 'package:edu_meneger_user_05_08_2024/screen/home/group_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:edu_meneger_user_05_08_2024/model/group.dart';
class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final storage = GetStorage();
  bool _isLoading = false;
  List<Group> groups = [];

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }


  Future<void> _fetchGroups() async {
    setState(() {
      _isLoading = true;
    });

    final token = storage.read('token');

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('https://edumeneger.uz/api/user/groups'),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );


        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status']) {
            final List<Group> fetchedGroups = (data['data'] as List)
                .map((groupJson) => Group.fromJson(groupJson))
                .toList();
            setState(() {
              groups = fetchedGroups;
            });
          } else {
            Get.snackbar('Xato', data['message'],
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        } else {
          Get.snackbar('Xato', 'Guruhlarni yuklab olishda xato',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        print('Error fetching groups: $e');
        Get.snackbar('Aloqa', 'Server bilan bog\'lanib bo\'lmadi guruHHHH',
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      _fetchGroups(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return GroupCard(group: groups[index]);
        },
      ),
    );
  }
}
