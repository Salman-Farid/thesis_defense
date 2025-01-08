import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plant_treatmonty/screens/signup_page.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'screens/login_page.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Disease Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: SplashScreen(authService: _authService),
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/login': (context) => LoginPage(authService: _authService),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Welcome Page'),
      ),
    );
  }
}
