import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper to keep snackbar code uniform inside the View layer
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 14)),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        width: 400,
      ),
    );
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final String? errorResult = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (mounted) setState(() => _isLoading = false);
    if (errorResult != null) {
      _showSnackbar(errorResult);
    }
  }

  void _handleRegister() async {
    setState(() => _isLoading = true);
    final String? errorResult = await _authService.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (mounted) setState(() => _isLoading = false);
    if (errorResult != null) {
      _showSnackbar(errorResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep the root background clean and un-breaking
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[900]!, Colors.orange[800]!, Colors.orange[400]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450, // Clamps layout perfectly on wide web monitors
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top App Branding
                    const Text("Login", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Welcome to GeoMugger", style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 40),

                    // White Core Input Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          // Email Input Field
                          Container(
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                            ),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: "Email address",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Password Input Field
                          Container(
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 30),

                          // Login Submit Button
                          GestureDetector(
                            onTap: _isLoading ? null : _handleLogin,
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.orange[900]!,
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Dynamic Sign Up Tap Switcher
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?", style: TextStyle(color: Colors.grey)),
                              GestureDetector(
                                onTap: _isLoading ? null : _handleRegister,
                                child: Text(" Sign Up", style: TextStyle(color: Colors.orange[900]!, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



         