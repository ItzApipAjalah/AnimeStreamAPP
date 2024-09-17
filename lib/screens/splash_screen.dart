import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the home screen after a delay
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity, // Full screen width
          height: double.infinity, // Full screen height
          child: FittedBox(
            fit: BoxFit.cover, // Ensures the animation covers the entire screen
            child: Lottie.asset(
              'assets/animation.json',
              repeat: true, // Ensures the animation plays only once
            ),
          ),
        ),
      ),
    );
  }
}
