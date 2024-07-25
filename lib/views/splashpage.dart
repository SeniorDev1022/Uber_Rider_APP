import 'package:flutter/material.dart';
import 'package:uber_josh/views/homepage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Background color
      body: Center(
        child: Image.asset(
          'assets/images/logo.png', // Your splash screen image
          width: 200, // Adjust width and height as needed
          height: 200,
        ),
      ),
    );
  }
}
