import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:resonix/main.dart';
import 'package:resonix/pages/home.dart';
import 'package:resonix/pages/library.dart';
import 'package:resonix/pages/album.dart';
import 'package:resonix/pages/nowPlaying.dart';
import 'package:resonix/pages/search.dart';
import 'package:resonix/services/api_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  bool isPlaying = false;
  bool isLoading = false;
  dynamic nowPlaying;
  int _index = 0;
  int _prevIndex = 0;
  double progress = 0.0;
  ProcessingState currentProcessingState = ProcessingState.idle;
  dynamic _albumData;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  void navigateToPage(int newIndex, String type, {dynamic data}) {
    setState(() {
      _prevIndex = _index;
      _index = newIndex;
      if (type == "album") _albumData = data;
    });
  }

  void goBack() {
    setState(() {
      _index = _prevIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioState = context.watch<AudioState>();

    audioState.player.positionStream.listen((event) {
      final duration = audioState.player.duration;
      if (duration != null) {
        final progress = duration.inMilliseconds > 0
            ? event.inMilliseconds / duration.inMilliseconds
            : 0.0;
        if (progress != this.progress) {
          setState(() {
            this.progress = progress;
          });
        }
      } else if (progress != 0) {
        setState(() {
          progress = 0;
        });
      }
    });

    audioState.player.playerStateStream.distinct().listen((state) {
      final currentTrack = audioState.player.sequenceState?.currentSource?.tag;

      if (isPlaying != state.playing) {
        setState(() {
          isPlaying = state.playing;
        });
      }

      if (currentProcessingState == state.processingState) return;
      setState(() {
        currentProcessingState = state.processingState;
      });

      switch (state.processingState) {
        case ProcessingState.loading:
          break;
        case ProcessingState.buffering:
          if (currentTrack?.title != nowPlaying?.title) {
            setState(() {
              nowPlaying = currentTrack;
            });
          }
          break;
        case ProcessingState.ready:
          if (currentTrack?.title != nowPlaying?.title) {
            setState(() {
              nowPlaying = currentTrack;
            });
          }
          break;
        case ProcessingState.completed:
          if (!audioState.player.hasNext) {
            setState(() {
              nowPlaying = null;
              isPlaying = false;
            });

            audioState.player.stop();
          }
          break;
        case ProcessingState.idle:
          setState(() {
            if (!audioState.player.hasNext) {
              nowPlaying = null;
              isPlaying = false;
            }
          });
          break;
      }
    });

    return Scaffold(
      backgroundColor: Color(0xFF150825),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        IndexedStack(index: _index, children: [
                          HomePage(onNavigate: navigateToPage),
                          SearchPage(onNavigate: navigateToPage),
                          LibraryPage(),
                          AlbumPage(data: _albumData, onBack: goBack),
                        ]),
                        Positioned(
                          bottom: 15,
                          left: 14,
                          right: 14,
                          child: Visibility(
                              visible: _index != 4,
                              child: InkWell(
                                onTap: () {
                                  _sheetController.animateTo(1.0,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeOut);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 20, sigmaY: 20),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: progress,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.white.withAlpha(30),
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 70,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withAlpha(30),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            border: Border.all(
                                                color:
                                                    Colors.white.withAlpha(20)),
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: nowPlaying == null
                                                      ? const Center(
                                                          child: Icon(
                                                              Icons.music_note,
                                                              color:
                                                                  Colors.white),
                                                        )
                                                      : Image.network(
                                                          nowPlaying?.artUri
                                                                  ?.toString() ??
                                                              "",
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return const Center(
                                                              child: Icon(
                                                                  Icons
                                                                      .music_note,
                                                                  color: Colors
                                                                      .white),
                                                            );
                                                          },
                                                        ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      nowPlaying?.title ??
                                                          "No track playing",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      nowPlaying?.artist ??
                                                          "No artist",
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFFB3B3B3),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: nowPlaying == null
                                                    ? null
                                                    : () {
                                                        if (isPlaying) {
                                                          audioState.player
                                                              .pause();
                                                        } else {
                                                          audioState.player
                                                              .play();
                                                        }
                                                      },
                                                icon: AnimatedSwitcher(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  transitionBuilder:
                                                      (child, animation) {
                                                    return ScaleTransition(
                                                        scale: animation,
                                                        child: child);
                                                  },
                                                  child: Icon(
                                                    isPlaying
                                                        ? CupertinoIcons
                                                            .pause_fill
                                                        : CupertinoIcons
                                                            .play_fill,
                                                    key: ValueKey(isPlaying),
                                                    size: 30,
                                                    color: nowPlaying == null
                                                        ? Colors.grey.shade500
                                                        : Colors.white,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              )),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  Container(
                    height: 80,
                    decoration: const BoxDecoration(color: Colors.black),
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: GNav(
                      haptic: true,
                      rippleColor: Colors.grey[800]!,
                      hoverColor: Colors.grey[700]!,
                      color: Colors.white,
                      tabBackgroundColor: Colors.grey[900]!,
                      activeColor: Colors.purpleAccent,
                      iconSize: 28.0,
                      onTabChange: (index) {
                        navigateToPage(index, "normal");
                      },
                      selectedIndex: _index,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      tabs: const [
                        GButton(icon: Icons.home, text: 'Home'),
                        GButton(icon: Icons.search, text: 'Search'),
                        GButton(icon: Icons.library_music, text: 'Library'),
                      ],
                    ),
                  ),
                  Container(
                    height: 23,
                    color: Colors.black,
                  )
                ],
              )),
          Positioned.fill(
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.01,
              minChildSize: 0.01,
              maxChildSize: 1.0,
              snap: true,
              snapAnimationDuration: const Duration(milliseconds: 200),
              snapSizes: [0.01, 1.0],
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: NowPlayingPage(scrollController: scrollController),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
