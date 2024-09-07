import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestShowPage extends StatefulWidget {
  final int coursId;
  final int grupId;

  const TestShowPage({super.key, required this.coursId, required this.grupId});

  @override
  _TestShowPageState createState() => _TestShowPageState();
}

class _TestShowPageState extends State<TestShowPage> {
  final _storage = GetStorage();
  Map<String, dynamic>? _testDetails;
  Map<int, int?> _selectedAnswers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _correctAnswersCount = 0;
  int _score = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTestDetails();
  }

  Future<void> _fetchTestDetails() async {
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
        Uri.parse(
            'https://edumeneger.uz/public/api/user/testshow/${widget.coursId}/${widget.grupId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status']) {
          setState(() {
            _testDetails = responseData;
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
      debugPrint('Exception: $e');
      setState(() {
        _errorMessage = 'Server bilan bog\'lanib bo\'lmadi.';
        _isLoading = false;
      });
    }
  }

  int _countCorrectAnswers() {
    int count = 0;
    final testList = _testDetails?['testlar'] ?? [];
    for (var test in testList) {
      final testId = test['test_id'];
      final correctAnswer = test['javob'];
      final selectedAnswer = _selectedAnswers[testId];
      if (correctAnswer == selectedAnswer) {
        count++;
      }
    }
    return count;
  }

  Future<void> _submitAnswers() async {
    if (_selectedAnswers.length < (_testDetails?['testlar']?.length ?? 0)) {
      Get.snackbar(
        'Xato',
        'Iltimos, barcha savollarga javob bering.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSubmitting = true; // Start loading
    });

    final token = _storage.read('token');

    if (token == null) {
      Get.snackbar(
        'Aloqa',
        'Siz ro\'yhatdan o\'tmagansiz.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        _isSubmitting = false; // Stop loading
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://edumeneger.uz/public/api/user/test/post'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'cours_id': widget.coursId,
          'guruh_id': widget.grupId,
          'count': _countCorrectAnswers(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status']) {
          setState(() {
            _correctAnswersCount = int.parse(responseData['count'].toString());
            _score = int.parse(responseData['ball'].toString());
          });

          // Show results in a dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Natija'),
              content: Text(
                'To\'g\'ri javoblar: $_correctAnswersCount\nHisoblangan ball: $_score',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          Get.snackbar(
            'Xato',
            responseData['message'],
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          debugPrint('Error Message: ${responseData['message']}');
        }
      } else {
        Get.snackbar(
          'Xato',
          'Serverdan xato javob.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        debugPrint('Error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      Get.snackbar(
        'Xato',
        'Server bilan bog\'lanib bo\'lmadi.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('Exception: $e');
    } finally {
      setState(() {
        _isSubmitting = false; // Stop loading
      });
    }
  }

  Widget _buildAnswer(String option, String? answer, int testId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4), // 4px space between items
      decoration: BoxDecoration(
        color: Colors.blue, // Background color changed to blue
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: Text(
          '$option: ${answer ?? 'N/A'}',
          style: const TextStyle(
              color: Colors.white), // Text color changed to white
        ),
        leading: Radio<int>(
          value: int.tryParse(option) ?? 0,
          groupValue: _selectedAnswers[testId],
          onChanged: (value) {
            setState(() {
              _selectedAnswers[testId] = value;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAllAnswered =
        _selectedAnswers.length >= (_testDetails?['testlar']?.length ?? 0);
    final selectedAnswersCount = _selectedAnswers.length;
    final totalQuestions = _testDetails?['testlar']?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Kurs: ${_testDetails?['guruh_name'] ?? 'N/A'}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _testDetails == null
                  ? const Center(child: Text('Test detallar mavjud emas'))
                  : Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 5),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _testDetails?['testlar']?.length ?? 0,
                              itemBuilder: (context, index) {
                                final test = _testDetails?['testlar'][index];
                                final testId = test['test_id'];
                                return Card(
                                  color: Colors.white,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(8.0),
                                    title: Text(
                                      '${index + 1} - savol: ${test['savol'] ?? 'N/A'}',
                                    ),
                                    subtitle: Column(
                                      children: [
                                        const SizedBox(height: 8.0,),
                                        _buildAnswer(
                                            '1', test['javob1'], testId),
                                        _buildAnswer(
                                            '2', test['javob2'], testId),
                                        _buildAnswer(
                                            '3', test['javob3'], testId),
                                        _buildAnswer(
                                            '4', test['javob4'], testId),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            color: Colors.white,
                            width: Get.width,
                            height: 80,
                            padding: EdgeInsets.all(20.0),
                            child: ElevatedButton(
                              onPressed: isAllAnswered ? _submitAnswers : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isAllAnswered ? Colors.blue : Colors.grey,
                              ),
                              child: _isSubmitting
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      isAllAnswered
                                          ? 'Yuborish ($selectedAnswersCount/$totalQuestions)'
                                          : 'Barcha savollarga javob bering ($selectedAnswersCount/$totalQuestions)',
                                        style: const TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestShowPage(coursId: 1, grupId: 1),
    );
  }
}
