import 'package:flutter/material.dart';
import 'package:portal_news/service/auth_service.dart'; // Make sure this path is correct
import 'package:portal_news/presentation/main_pages/main_pages.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLogin = true; // To toggle between Login and Sign Up UI
  bool _isLoading = false;

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String? result;
      if (_isLogin) {
        result = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        result = await _authService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
      }

      setState(() => _isLoading = false);

      // if (result == "Success") {
      //   // If successful, the StreamBuilder in main.dart will automatically
      //   // switch to the Main Page, but you can also navigate manually:
      //   if (!mounted) return;
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => MainPage()),
      //   );
      // } else {
      //   // Show error from Firebase (e.g., "Wrong password")
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(result ?? "An error occurred"),
      //       backgroundColor: Colors.redAccent,
      //     ),
      //   );
      // }
      if (result == "Success") {
        if (_isLogin) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        } else {
          setState(() => _isLogin = true);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Account created! Please login."),
              backgroundColor: Colors.teal,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ?? "An error occurred"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon and App Name
                const Icon(Icons.newspaper, color: Colors.teal, size: 80),
                const SizedBox(height: 10),
                const Text(
                  "Portal News",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Email", Icons.email),
                  validator:
                      (value) => value!.isEmpty ? "Enter an email" : null,
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Password", Icons.lock),
                  validator:
                      (value) =>
                          value!.length < 6
                              ? "Password must be 6+ characters"
                              : null,
                ),
                const SizedBox(height: 20),
                if (_isLogin == false)
                  TextFormField(
                    controller: _nameController,

                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration(
                      "Display Name",
                      Icons.person,
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? "Enter a display name" : null,
                  ),

                const SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            _isLogin ? "Login" : "Create Account",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),

                // Toggle between Login and Sign Up
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Login",
                    style: TextStyle(color: Colors.teal[300]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // UI Helper for consistent Dark Theme Inputs
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.teal),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.teal),
      ),
    );
  }
}
