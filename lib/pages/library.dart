import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resonix/modals/new_playlist_modal.dart';
import 'package:resonix/screens/login.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/widgets/custom_image.dart';
import 'package:resonix/widgets/skeleton_track.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  LibraryPageState createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  dynamic playlists;

  Future<void> loadPlaylists() async {
    var response = await ApiService.getUserPlaylists(true);
    if (!mounted) return;
    if (response != null) {
      if (response["error"] != null) {
        return ApiService.returnError(context, response["error"]);
      }
      setState(() {
        playlists = response["playlists"];
      });
    } else {
      await ApiService.returnTokenExpired(context);
    }
  }

  @override
  void initState() {
    super.initState();
    loadPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> logout() async {
      var session = await SharedPreferences.getInstance();
      await session.remove("token");
      Navigator.of(context, rootNavigator: true).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Login(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(-1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Your Library'),
        backgroundColor: Colors.transparent,
        leading: const Icon(Icons.library_music, color: Colors.white, size: 32),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              NewPlaylistModal.show(context, (str) => loadPlaylists());
            },
          ),
        ],
        titleSpacing: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withAlpha(0),
            ),
          ),
        ),
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      body: NotificationListener(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Column(
            children: [
              playlists == null
                  ? ListView.builder(
                      shrinkWrap: true,
                      // Allow ListView to fit content
                      physics: NeverScrollableScrollPhysics(),
                      // Disable inner scrolling
                      itemCount: 4,
                      itemBuilder: (context, index) => SkeletonTrack(),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      // Allow ListView to fit content
                      physics: NeverScrollableScrollPhysics(),
                      // Disable inner scrolling
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        var playlist = playlists[index];
                        return Ink(
                          decoration: BoxDecoration(
                            color: Color(0xFF28123E),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(12.0),
                            splashColor: Colors.white.withAlpha(50),
                            highlightColor: Colors.white.withAlpha(30),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  CustomImage(
                                      imageUrl:
                                          '${ApiService.baseUrl}/storage/cover/playlist/${playlist["id"]}',
                                      height: 70,
                                      width: 70),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        playlist["name"] ?? "No name",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        playlist["description"] ??
                                            "No description",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                    ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
