import 'package:edu_meneger_user_05_08_2024/screen/home/group_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:edu_meneger_user_05_08_2024/model/group.dart';// Import GroupCard

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Group> groups = [];
  String balans = '0';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchGroupsAndBalans();
  }

  Future<void> _fetchGroupsAndBalans() async {
    setState(() {
      _isLoading = true;
    });

    final token = GetStorage().read('token');

    if (token != null) {
      try {
        final groupResponse = await http.get(
          Uri.parse('https://edumeneger.uz/api/user/groups'),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (groupResponse.statusCode == 200) {
          final data = jsonDecode(groupResponse.body);
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

        final profileResponse = await http.get(
          Uri.parse('https://edumeneger.uz/api/user/profile'),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (profileResponse.statusCode == 200) {
          final request = jsonDecode(profileResponse.body);
          setState(() {
            balans = request['balans'].toString();
          });
          GetStorage().write('balans', balans);
        } else {
          Get.snackbar('Xato', 'Balansni yuklab olishda xato',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        Get.snackbar('Aloqa', 'Server bilan bog\'lanib bo\'lmadi',
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchGroupsAndBalans();
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
          final group = groups[index];
          bool isActive = DateTime.now().isBefore(group.endTime);
          return GroupCard(group: group, isActive: isActive);
        },
      ),
    );
  }
}
