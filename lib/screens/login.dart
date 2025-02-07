import 'package:flutter/material.dart';
import 'package:resonix/screens/home.dart';
import 'package:resonix/screens/register.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/widgets/error.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  var error = "";

  @override
  Widget build(BuildContext context) {
    Future<void> login() async {
      var email = _emailController.text.trim();
      var password = _passwordController.text.trim();

      if (email == "" || password == "") {
        setState(() {
          this.error = "Please fill in all fields";
        });
        return;
      }

      var error = await ApiService.login(email, password);
      if (!mounted) return;
      if (error != null) {
        setState(() {
          this.error = error;
        });
      } else {
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Home()));
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
                          color: Colors.grey.withValues(alpha: .3),
                          borderRadius: BorderRadius.circular(16.0)),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 7.0),
                          child: Image.asset('assets/fl_resonix_x512.png',
                              width: 320),
                        ),
                        const Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Visibility(
                            visible: error.isNotEmpty,
                            child: TakiyoError(
                                error: error, margin: EdgeInsets.only(top: 7))),
                        Container(
                          margin: const EdgeInsets.only(top: 9),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Username/Email",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w700),
                                      textAlign: TextAlign.left),
                                ],
                              ),
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'user@resonix.com',
                                  labelStyle: TextStyle(color: Colors.black38),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("Password",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w700),
                                      textAlign: TextAlign.left),
                                ],
                              ),
                              TextField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'password',
                                  labelStyle: TextStyle(color: Colors.black38),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Register()));
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                backgroundColor:
                                    Colors.transparent.withAlpha(0),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Forgot Password'),
                            ),
                          ),
                        ),
                        Row(
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
                                              const Register()));
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  backgroundColor:
                                      Colors.transparent.withAlpha(0),
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Colors.white, width: 1),
                                ),
                                child: const Text('Register'),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => login(),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text('Login'),
                            )
                          ],
                        ),
                      ])),
                )),
          ),
        )));
  }
}
