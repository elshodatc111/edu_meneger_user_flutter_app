import 'package:edu_meneger_user_05_08_2024/screen/group/groups_page.dart';
import 'package:edu_meneger_user_05_08_2024/screen/paymart/paymart_page.dart';
import 'package:edu_meneger_user_05_08_2024/screen/profil/profile_page.dart';
import 'package:edu_meneger_user_05_08_2024/screen/test/TestPage.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = GetStorage();
  String balans = '0';
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    GroupsPage(),
    PaymartPage(),
    TestPage(),
    ProfilePage(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edu Meneger"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      body:  _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.home_outlined),
            label: 'Guruhlar',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.payment),
            label: 'To\'lovlar',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.assignment),
            label: 'Testlar',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
