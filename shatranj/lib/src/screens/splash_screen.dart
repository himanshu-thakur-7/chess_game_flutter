import 'dart:async';

import 'package:chess_ui/src/screens/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  var userOnDeviceID;
  SplashScreen({Key? key, this.userOnDeviceID}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

// Displaying the splash screen for 3 seconds
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(userOnDeviceID: widget.userOnDeviceID),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
              image: AssetImage('graphics/splash2.jpg'), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
