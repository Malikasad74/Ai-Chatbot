import 'dart:async';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for a bit longer to keep the splash screen visible
    Timer(const Duration(seconds: 3), () {  // Increase delay to 3 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "ChatBot AI",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/icons/TwoCraftStudio_logo.png',
              width: 300,  // Resize image to reduce app size and speed up loading
              height: 300,
            ),
          ],
        ),
      ),
    );
  }
}
