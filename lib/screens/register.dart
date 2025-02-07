import 'package:flutter/material.dart';
import 'package:resonix/screens/login.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/widgets/error.dart';
import 'package:resonix/widgets/inputForm.dart';

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
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(100),
                          borderRadius: BorderRadius.circular(16.0)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 7.0),
                            child: Image.asset('assets/fl_resonix_x512.png',
                                width: 320),
                          ),
                          const Text(
                            "Register",
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Visibility(
                              visible: error.isNotEmpty,
                              child: TakiyoError(
                                  error: error,
                                  margin: EdgeInsets.only(top: 7))),
                          TakiyoInputForm(
                              controller: _usernameController,
                              label: "Username",
                              placeholder: "Enter your username"),
                          TakiyoInputForm(
                              controller: _emailController,
                              label: "Email",
                              placeholder: "Enter your email"),
                          TakiyoInputForm(
                              controller: _passwordController,
                              label: "Password",
                              placeholder: "Enter your password",
                              obscureText: true),
                          TakiyoInputForm(
                              controller: _confirmPasswordController,
                              label: "Confirm Password",
                              placeholder: "Confirm your password",
                              obscureText: true),
                          Container(
                            margin: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Login()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      backgroundColor:
                                          Colors.transparent.withAlpha(0),
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                          color: Colors.white, width: 1),
                                    ),
                                    child: const Text('Login'),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => register(),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: const Text('Register'),
                                )
                              ],
                            ),
                          )
                        ],
                      )),
                )),
          ),
        )));
  }
}
