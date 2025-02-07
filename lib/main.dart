import 'package:resonix/screens/home.dart';
import 'package:resonix/screens/login.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/state/audio_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
export 'package:flutter/material.dart';
export 'package:just_audio/just_audio.dart';
export 'package:just_audio_background/just_audio_background.dart';
export 'package:provider/provider.dart';
export 'package:resonix/state/audio_state.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.takiyo.resonix.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(ChangeNotifierProvider(
      lazy: false, create: (_) => AudioState(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resonix',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Resonix'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<bool> _isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    if (token == null) return false;
    return await ApiService.isTokenValid(token);
    }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: Center(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            ),
          ),
          child: FutureBuilder<bool>(
            future: _isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData && snapshot.data == true) {
                return const Home();
              } else if (snapshot.hasData && snapshot.data == false) {
                return const Login();
              } else {
                return const Center(
                    child:
                        Text("Error", style: TextStyle(color: Colors.white)));
              }
            },
          ),
        ),
      ),
    );
  }
}
