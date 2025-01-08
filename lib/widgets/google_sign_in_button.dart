import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class GoogleSignInButton extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.all(8),
      ),
      onPressed: () async {
        final user = await _authService.signInWithGoogle();
        if (user != null) {
          // Navigate to home screen or update UI
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/google_logo.png', height: 24),
          SizedBox(width: 12),
          Text(
            'Sign in with Google',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
