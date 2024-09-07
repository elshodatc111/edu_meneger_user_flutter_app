import 'package:edu_meneger_user_05_08_2024/screen/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // State variable for loading indicator

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final response = await http.post(
          Uri.parse('https://edumeneger.uz/public/api/user/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['token'] != null) {
            print(responseData);
            final storage = GetStorage();
            storage.write('token', responseData['token']);
            storage.write('markaz_id', responseData['markaz_id']);
            storage.write('name', responseData['name']);
            storage.write('balans', responseData['balans']);
            Get.offAll(() => const HomePage());
          } else {
            Get.snackbar('Xato', 'Kirishda xato yuz berdi',
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        } else {
          Get.snackbar('Xato', 'Login yoki parol xato',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        Get.snackbar('Aloqa', 'Server bilan bog\'lanib bo\'lmadi',
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: Get.width,
            height: Get.height,
            color: Colors.blue.shade400,
            padding: EdgeInsets.only(top: Get.height * 0.3, left: 32, right: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Kirish",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 40.0,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: "Login",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Loginni kiriting';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Parol",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Parolni kiriting';
                        } else if (value.length < 6) {
                          return 'Parol kamida 6 ta belgi bo\'lishi kerak';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _login,
                      child: const Center(
                        child: Text(
                          "Kirish",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) // Show loading indicator based on state
            const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
        ],
      ),
    );
  }
}
