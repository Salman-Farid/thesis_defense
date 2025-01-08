import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  final AuthService authService;

  SplashScreen({Key? key, required this.authService}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _checkAuthAndRedirect();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndRedirect() async {
    await Future.delayed(Duration(seconds: 3)); // Ensure splash screen is visible for at least 3 seconds
    final isLoggedIn = await widget.authService.isUserLoggedIn();

    if (mounted) {
      if (isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
       Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F6F8), Color(0xFFE8EDF2)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/homeScreen.png',
                  height: 150,
                ),
              ),
              SizedBox(height: 30),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Plant Disease Detector',
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A6572),
                    ),
                    speed: Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A6572)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

