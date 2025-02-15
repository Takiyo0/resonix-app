import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:resonix/main.dart';
import 'package:resonix/pages/home.dart';
import 'package:resonix/pages/library.dart';
import 'package:resonix/pages/now_playing.dart';
import 'package:resonix/pages/search.dart';
import 'package:resonix/pages/user.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/widgets/custom_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  bool isLoading = false;
  int _index = 0;
  int _prevIndex = 0;
  ProcessingState currentProcessingState = ProcessingState.idle;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void navigateToPage(int newIndex, String type, {dynamic data}) {
    setState(() {
      _prevIndex = _index;
      _index = newIndex;
      _navigatorKey.currentState?.pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              _getPageByName(newIndex),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    });
  }

  Widget _getPageByName(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const SearchPage();
      case 2:
        return LibraryPage();
      case 3:
        return UserPage(id: null);
      default:
        return const HomePage();
    }
  }

  void goBack() {
    setState(() {
      _index = _prevIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioState = context.watch<AudioState>();

    audioState.player.playerStateStream.distinct().listen((state) async {
      if (currentProcessingState != state.processingState) {
        setState(() {
          currentProcessingState = state.processingState;
        });

        if (!audioState.player.hasNext &&
            state.processingState == ProcessingState.completed) {
          audioState.player.pause();
          var next = await ApiService.getNextRecommendations();
          if (next?["tracks"] != null) {
            List<UriAudioSource> tracks = [];
            for (var track in next!["tracks"]) {
              tracks.add(audioState.buildTrack(track, "recommendation"));
            }
            audioState.addTracks(tracks, true);
          } else {
            audioState.player.seek(Duration.zero);
          }
        }
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
                      Navigator(
                        key: _navigatorKey,
                        onGenerateRoute: (settings) {
                          late Widget page;
                          switch (settings.name) {
                            case '/':
                              page = HomePage();
                              break;
                            case '/search':
                              page = SearchPage();
                              break;
                            case '/library':
                              page = LibraryPage();
                              break;
                            default:
                              page = HomePage();
                          }
                          return MaterialPageRoute(builder: (_) => page);
                        },
                      ),
                      Positioned(
                        bottom: 15,
                        left: 14,
                        right: 14,
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            var heightPercentage = details.globalPosition.dy /
                                MediaQuery.of(context).size.height;
                            _sheetController
                                .jumpTo(1.0 - heightPercentage.clamp(0.1, 1.0));
                          },
                          onVerticalDragEnd: (details) {
                            if (details.velocity.pixelsPerSecond.dy.abs() >
                                1000) {
                              _sheetController.animateTo(1.0,
                                  duration: Duration(milliseconds: 250),
                                  curve: Curves.easeOutSine);
                            } else {
                              if (_sheetController.pixels >
                                  (0.5 * MediaQuery.of(context).size.height)) {
                                _sheetController.animateTo(1.0,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeOutSine);
                              } else {
                                _sheetController.animateTo(0.0,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeOutSine);
                              }
                            }
                          },
                          child: StreamBuilder(
                            stream: audioState.player.sequenceStateStream,
                            builder: (context, sequence) {
                              var track = sequence.data?.currentSource?.tag
                                  as MediaItem?;
                              if (track != null) {
                                ApiService.sendPlaying(track.id);
                              }
                              return Visibility(
                                visible: _index != 4,
                                child: InkWell(
                                  onTap: () {
                                    _sheetController.animateTo(1.0,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeOut);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 20, sigmaY: 20),
                                      child: Container(
                                        height: 70,
                                        color: Colors.white.withAlpha(30),
                                        child: Stack(
                                          children: [
                                            StreamBuilder(
                                              stream: audioState
                                                  .player.positionStream,
                                              builder: (context, snapshot) {
                                                final duration =
                                                    audioState.player.duration;
                                                final position =
                                                    snapshot.data ??
                                                        Duration.zero;
                                                double progress = 0;
                                                if (duration != null) {
                                                  progress = duration
                                                              .inMilliseconds >
                                                          0
                                                      ? position
                                                              .inMilliseconds /
                                                          duration
                                                              .inMilliseconds
                                                      : 0.0;
                                                }
                                                return Positioned.fill(
                                                  child: FractionallySizedBox(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    widthFactor: progress,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withAlpha(30),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Container(
                                              height: 70,
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.white.withAlpha(30),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                border: Border.all(
                                                    color: Colors.white
                                                        .withAlpha(20)),
                                              ),
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  CustomImage(
                                                      imageUrl: track?.artUri
                                                              ?.toString() ??
                                                          "",
                                                      height: 60,
                                                      width: 60),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          track?.title ??
                                                              "No track playing",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          track?.artist ??
                                                              "No artist",
                                                          style:
                                                              const TextStyle(
                                                            color: Color(
                                                                0xFFB3B3B3),
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  StreamBuilder(
                                                    stream: audioState
                                                        .player.playingStream,
                                                    builder:
                                                        (context, snapshot) {
                                                      var isPlaying =
                                                          snapshot.data ??
                                                              false;
                                                      return IconButton(
                                                        onPressed: track ==
                                                                    null ||
                                                                currentProcessingState !=
                                                                    ProcessingState
                                                                        .ready
                                                            ? null
                                                            : () {
                                                                if (isPlaying) {
                                                                  audioState
                                                                      .player
                                                                      .pause();
                                                                } else {
                                                                  audioState
                                                                      .player
                                                                      .play();
                                                                }
                                                              },
                                                        icon: AnimatedSwitcher(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          transitionBuilder:
                                                              (child,
                                                                  animation) {
                                                            return ScaleTransition(
                                                                scale:
                                                                    animation,
                                                                child: child);
                                                          },
                                                          child: Icon(
                                                            currentProcessingState ==
                                                                    ProcessingState
                                                                        .buffering
                                                                ? Icons
                                                                    .hourglass_empty
                                                                : isPlaying
                                                                    ? Icons
                                                                        .pause
                                                                    : Icons
                                                                        .play_arrow,
                                                            key: ValueKey(
                                                                isPlaying),
                                                            size: 30,
                                                            color: track == null
                                                                ? Colors.grey
                                                                    .shade500
                                                                : Colors.white,
                                                          ),
                                                        ),
                                                      );
                                                    },
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
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                        GButton(icon: Icons.person, text: 'User'),
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
              initialChildSize: 0.0,
              minChildSize: 0.0,
              maxChildSize: 1.0,
              snap: true,
              snapAnimationDuration: const Duration(milliseconds: 200),
              snapSizes: [0.0, 1.0],
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
