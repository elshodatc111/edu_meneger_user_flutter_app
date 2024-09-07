import 'dart:ui';

import 'package:edu_meneger_user_05_08_2024/screen/splash/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = GetStorage();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final token = _storage.read('token');

    if (token == null) {
      setState(() {
        _errorMessage = 'Token mavjud emas.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://edumeneger.uz/api/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status']) {
          setState(() {
            _profileData = responseData;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = responseData['message'];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Serverdan xato javob.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Server bilan bog\'lanib bo\'lmadi.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              minRadius: 72,
                              maxRadius: 84,
                              child: Image.asset('assets/images/user.png'),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${_profileData?['name'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('${_profileData?['email'] ?? ''}'),
                            Text(
                              'Balans: ${_profileData?['balans'] ?? 0} so\'m',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Telefon raqam',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20),
                              ),
                              Text('${_profileData?['phone1'] ?? ''}'),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'Telefon raqam',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20),
                              ),
                              Text('${_profileData?['phone2'] ?? ''}'),
                            ],
                          ),
                        ],
                      ),
                      Center(
                        child: Container(
                          width: Get.width*0.5,
                          margin: const EdgeInsets.only(top: 30),
                          height: 40,
                          child: ElevatedButton(
                            onPressed: (){
                              _storage.erase();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const SplashPage()), // HomePage sahifasi
                                    (Route<dynamic> route) => false, // Barcha sahifalarni yopadi
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.red,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout,color: Colors.white,),
                                SizedBox(width: 10,),
                                Text('Chiqish',style: TextStyle(color: Colors.white))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
