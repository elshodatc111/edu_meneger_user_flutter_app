import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymartPage extends StatefulWidget {
  const PaymartPage({super.key});

  @override
  _PaymartPageState createState() => _PaymartPageState();
}

class _PaymartPageState extends State<PaymartPage> {
  final _storage = GetStorage();
  List<dynamic> _paymarts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPaymarts();
  }

  Future<void> _fetchPaymarts() async {
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
        Uri.parse('https://edumeneger.uz/public/api/user/paymarts'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status']) {
          setState(() {
            _paymarts = responseData['data'];
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
      color: Colors.white,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _paymarts.length,
                  itemBuilder: (context, index) {
                    final paymart = _paymarts[index];
                    final date = DateTime.parse(paymart['data']);
                    final formattedDate =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 12,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'To\'lov: ${paymart['summa']} so\'m',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            Text(
                              '${paymart['type']}',
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.currency_exchange_sharp,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To\'lov vaqti: $formattedDate',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
