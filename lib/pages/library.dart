import 'package:flutter/material.dart';
import 'package:resonix/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<void> logout() async {
      var session = await SharedPreferences.getInstance();
      await session.remove("token");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Login()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Library', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'Not Implemented Yet',
              style: TextStyle(color: Colors.white),
            ),
            ElevatedButton(
              onPressed: logout,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
