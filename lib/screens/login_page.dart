import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/auth_service.dart';
import 'signup_page.dart';
import '../home_page.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  final AuthService authService;

  LoginPage({Key? key, required this.authService}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _backgroundController;
  late AnimationController _formController;
  late Animation<double> _formSlide;
  late Animation<double> _formScale;
  late Animation<double> _fieldSlide;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();

    _formController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _formSlide = Tween<double>(
      begin: 100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutQuart,
    ));

    _formScale = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutQuart,
    ));

    _fieldSlide = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));

    _formController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin(BuildContext context) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Invalid email or password');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: AnimatedBuilder(
                  animation: _formController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _formSlide.value),
                      child: Transform.scale(
                        scale: _formScale.value,
                        child: _buildLoginCard(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return CustomPaint(
          painter: ModernBackgroundPainter(
            animation: _backgroundController.value,
          ),
          child: Container(),
        );
      },
    );
  }

  Widget _buildLoginCard() {
    return Container(
      margin: EdgeInsets.only(top: 80),
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 40),
          _buildLoginForm(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.lock_outline,
            color: Color(0xFF6C63FF),
            size: 32,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Let\'s get you signed in',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF9B9B9B),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _fieldSlide.value),
          child: Column(
            children: [
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              SizedBox(height: 32),
              _buildLoginButton(),
              _buildDivider(),
              _buildGoogleSignInButton(),
              SizedBox(height: 24),
              _buildSignUpLink(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Color(0xFFEEEEEE))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OR',
              style: TextStyle(
                color: Color(0xFF9B9B9B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Color(0xFFEEEEEE))),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        icon: Image.asset(
          'assets/google_logo.png',
          height: 24,
        ),
        label: Text(
          'Continue with Google',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Color(0xFFEEEEEE)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: () async {
          setState(() => _isLoading = true);
          try {
            final userCredential = await widget.authService.signInWithGoogle();
            if (userCredential != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          } catch (e) {
            _showError('Google Sign-In failed');
          }
          setState(() => _isLoading = false);
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFEEEEEE)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: Color(0xFF2D3142),
          fontSize: 16,
        ),
        keyboardType: keyboardType,
        obscureText: isPassword && !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Color(0xFF9B9B9B),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Color(0xFF6C63FF), size: 20),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Color(0xFF6C63FF),
              size: 20,
            ),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _performLogin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6C63FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          'Sign In',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Color(0xFF9B9B9B),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => SignupPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class ModernBackgroundPainter extends CustomPainter {
  final double animation;

  ModernBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF8F9FF),
        Color(0xFFF0F3FF),
        Color(0xFFEDF0FF),
      ],
      stops: [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    final shapePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color(0xFF6C63FF).withOpacity(0.05);

    for (int i = 0; i < 3; i++) {
      final offset = animation * math.pi * 2 + i * (math.pi / 1.5);
      final x = math.cos(offset) * 30 + size.width * 0.8;
      final y = math.sin(offset) * 30 + size.height * 0.2;

      final path = Path();
      path.moveTo(x, y);
      path.addOval(Rect.fromCircle(center: Offset(x, y), radius: 40 + i * 20));
      canvas.drawPath(path, shapePaint);
    }

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Color(0xFF6C63FF).withOpacity(0.1);

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveOffset = 50.0 * i;

      path.moveTo(0, size.height * 0.65 + waveOffset);

      for (double x = 0; x <= size.width; x += 1) {
        final y = size.height * 0.65 +
            waveOffset +
            math.sin((x / size.width) * 4 * math.pi + animation * math.pi * 2) * 15;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(ModernBackgroundPainter oldDelegate) => true;
}

