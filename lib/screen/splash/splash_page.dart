import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:edu_meneger_user_05_08_2024/screen/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:edu_meneger_user_05_08_2024/screen/login/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}
class _SplashPageState extends State<SplashPage> {
  Future<Widget> _checkLoginStatus() async {
    final storage = GetStorage();
    final token = storage.read('token');
    if (token != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        return AnimatedSplashScreen(
          splash: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 250,
                height: 250,
              ),
              const Text(
                "Edu Meneger",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          nextScreen: snapshot.connectionState == ConnectionState.done
              ? snapshot.data!
              : const SizedBox.shrink(),
          splashIconSize: 320,
          backgroundColor: Colors.blue.shade400,
          splashTransition: SplashTransition.fadeTransition,
        );
      },
    );
  }
}
