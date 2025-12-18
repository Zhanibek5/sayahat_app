import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutterapplication/firstPage/pageView.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Fade-in effect
    Timer(const Duration(milliseconds: 10), () {
      setState(() => _opacity = 1.0);
    });

    // Navigate to next screen with fade transition
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        duration: const Duration(seconds: 2),
        opacity: _opacity,
        child: SizedBox.expand(
          child: Image.asset(
            'assets/IMG_5578.JPG',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
