import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_app/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // ✅ Fixed typo
    super.initState(); // ✅ Call super first
    _goHome();
  }

  _goHome() async {
    await Future.delayed(const Duration(milliseconds: 4000));
    if (mounted) {
      // ✅ Prevents navigation if widget is disposed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        body: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Image.asset(
                'assets/images/weather.png',
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
              Text(
                "Weather App",
                style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto'),
              ),
              Spacer(),
              Text(
                "App Created by".toUpperCase(),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
              ),
              Text(
                "Shantnu Gabhale".toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              SizedBox(
                height: 25,
              )
            ],
          ),
        ));
  }
}
