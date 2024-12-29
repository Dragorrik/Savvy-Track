import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:savvy_track/pages/expense_page.dart';
import 'package:savvy_track/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Simulate loading time before navigating to the main page
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/pouch.png',
            fit: BoxFit.cover,
          ),
          // Overlay with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:
                      Colors.black.withOpacity(0.6), // Semi-transparent color
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    // App Logo or Icon
                    Image.asset(
                      'assets/images/money.png',
                      height: 150,
                    ),
                    //const SizedBox(height: 10),

                    // App Name
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0XFFFFDC44),
                        letterSpacing: 1.5,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText('SavvyTrack',
                              speed: const Duration(milliseconds: 150)),
                        ],
                        totalRepeatCount: 1, // Show animation once
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tagline
                    const Text(
                      "Track your expenses,\nmaster your budget!",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0XFFE1E3FA),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Loading Indicator
              const SpinKitWave(
                color: Color(0XFFE1E3FA),
                size: 50.0,
              ),
              const SizedBox(height: 20),

              // Loading Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LinearProgressIndicator(
                  color: const Color(0XFF32D735),
                  backgroundColor: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
