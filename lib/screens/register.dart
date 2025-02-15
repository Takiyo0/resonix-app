import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resonix/screens/login.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/widgets/takiyo_input_form.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  var error = "";

  @override
  Widget build(BuildContext context) {
    Future<void> register() async {
      var username = _usernameController.text.trim();
      var email = _emailController.text.trim();
      var password = _passwordController.text.trim();
      var confirmPassword = _confirmPasswordController.text.trim();

      if (username == "" ||
          email == "" ||
          password == "" ||
          confirmPassword == "") {
        setState(() {
          this.error = "Please fill in all fields";
        });
        return;
      } else if (password != confirmPassword) {
        setState(() {
          this.error = "Passwords do not match";
        });
        return;
      }

      var error = await ApiService.register(username, email, password);
      if (!mounted) return;
      if (error != null) {
        setState(() {
          this.error = error;
        });
      } else {
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Login()));
        }
      }
    }

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Center(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4B1D79),
                    Color(0xFF2B0F4D),
                    Color(0xFF150825),
                    Color(0xFF0B0512),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16.0),
                          border:
                          Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/fl_resonix_x512.png',
                              width: 180,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Create new account",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (error.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  error,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            TakiyoInputForm(
                              controller: _usernameController,
                              label: "Username",
                              placeholder: "Enter your username",
                            ),
                            TakiyoInputForm(
                              controller: _emailController,
                              label: "Email",
                              placeholder: "Enter your email",
                            ),
                            TakiyoInputForm(
                              controller: _passwordController,
                              label: "Password",
                              placeholder: "Enter your password",
                              obscureText: true,
                            ),
                            TakiyoInputForm(
                              controller: _confirmPasswordController,
                              label: "Confirm Password",
                              placeholder: "Confirm your password",
                              obscureText: true,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Register()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                ),
                                child: const Text("Forgot Password?"),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Login()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: Colors.white, width: 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: const Text("Login"),
                                ),
                                ElevatedButton(
                                  onPressed: () => register(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Text("Register"),
                                  ),
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
          ),
        ),
    );
  }
}
