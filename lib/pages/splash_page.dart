import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:savvy_track/pages/expense_page.dart';

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
    // Future.delayed(const Duration(seconds: 4), () {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(
    //         builder: (_) => ExpensePage()),
    //   );
    // });
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
              // App Logo or Icon
              Image.asset(
                'assets/images/money.png',
                height: 150,
              ),
              const SizedBox(height: 20),

              // App Name
              const Text(
                "SavvyTrack",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),

              // Tagline
              const Text(
                "Track your expenses,\nmaster your budget!",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 40),

              // Loading Indicator
              const SpinKitWave(
                color: Colors.white,
                size: 50.0,
              ),
              const SizedBox(height: 20),

              // Loading Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LinearProgressIndicator(
                  color: Colors.greenAccent,
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
