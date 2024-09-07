import 'package:edu_meneger_user_05_08_2024/screen/test/test_show_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _storage = GetStorage();
  Map<String, dynamic>? _testData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTests();
  }

  Future<void> _fetchTests() async {
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
        Uri.parse('https://edumeneger.uz/public/api/user/test'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status']) {
          setState(() {
            _testData = responseData['data'];
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

  void _onCardTap(int coursId, int grupId) {
    Get.to(() => TestShowPage(coursId: coursId, grupId: grupId));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _testData == null || _testData!.isEmpty
          ? const Center(child: Text('Testlar mavjud emas'))
          : ListView.builder(
        itemCount: _testData!.length,
        itemBuilder: (context, index) {
          final key = _testData!.keys.elementAt(index);
          final test = _testData![key];

          return GestureDetector(
            onTap: () => _onCardTap(test['cours_id'], test['guruh_id']),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8.0),
                title: Text(
                  '${test['cours_name'] ?? 'N/A'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 10, color: Colors.blue),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Urinishlar soni', style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.w500, fontSize: 16.0)),
                            Text('${test['urinish'] ?? 0}', style: const TextStyle(fontSize: 12.0)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('To\'g\'ri javoblar', style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.w500, fontSize: 16.0)),
                            Text('${test['tugri'] ?? 0}', style: const TextStyle(fontSize: 12.0)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
