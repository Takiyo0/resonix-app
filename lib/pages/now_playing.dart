import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:interactive_slider/interactive_slider.dart';
import 'package:resonix/main.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/widgets/animated_next_button_widget.dart';
import 'package:resonix/widgets/animated_prev_button_widget.dart';
import 'package:resonix/widgets/conditional_marquee.dart';
import 'package:shimmer/shimmer.dart';

class NowPlayingPage extends StatefulWidget {
  final ScrollController scrollController;

  const NowPlayingPage({super.key, required this.scrollController});

  @override
  NowPlayingPageState createState() => NowPlayingPageState();
}

class NowPlayingPageState extends State<NowPlayingPage> {
  bool isLiked = false;
  bool isHovered = false;
  late InteractiveSliderController _sliderController;

  @override
  void initState() {
    super.initState();
    _sliderController = InteractiveSliderController(0);
  }

  @override
  Widget build(BuildContext context) {
    final audioState = context.watch<AudioState>();

    audioState.player.positionStream.listen((position) {
      final duration = audioState.player.duration;
      if (isHovered) return;
      if (duration != null && duration.inSeconds > 0) {
        _sliderController.value =
            (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0);
      } else {
        _sliderController.value = 0.0;
      }
    });

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent,
      child: CustomScrollView(
        controller: widget.scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Stack(
              children: [
                StreamBuilder(
                  stream: audioState.player.sequenceStateStream,
                  builder: (ctx, snapshot) {
                    final sequenceState = snapshot.data;
                    final nowPlaying =
                        snapshot.data?.currentSource?.tag as MediaItem?;
                    return Stack(
                      children: [
                        if (nowPlaying != null)
                          Positioned.fill(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ImageFiltered(
                                  imageFilter:
                                      ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        '${ApiService.baseUrl}/storage/cover/track/${nowPlaying?.id}',
                                    fit: BoxFit.cover,
                                    errorWidget: (context, error, stackTrace) =>
                                        Container(color: Colors.transparent),
                                  ),
                                ),
                                Container(
                                  color: Colors.black
                                      .withAlpha((255 * 0.8).toInt()),
                                ),
                              ],
                            ),
                          )
                        else
                          Positioned.fill(
                              child: Container(
                                  color: Colors.white
                                      .withAlpha((255 * 0.2).toInt()))),
                        Container(
                          constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height),
                          child: SafeArea(
                            maintainBottomViewPadding: true,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 4),
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withAlpha((255 * .5).toInt()),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      // if (nowPlaying?.extras?["source"] is String)
                                      //   Padding(
                                      //     padding: const EdgeInsets.symmetric(
                                      //         vertical: 3),
                                      //     child: Text(
                                      //       nowPlaying?.extras?["source"],
                                      //       style: const TextStyle(
                                      //         color: CupertinoColors.white,
                                      //         fontSize: 16,
                                      //       ),
                                      //     ),
                                      //   ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: FractionallySizedBox(
                                        widthFactor: .96,
                                        child: Stack(
                                          children: [
                                            StreamBuilder(
                                                stream: audioState
                                                    .player.playingStream,
                                                builder: (ctx, snapshot) {
                                                  var isPlaying =
                                                      snapshot?.data ?? false;
                                                  return SizedBox(
                                                    child: Center(
                                                      child: AnimatedScale(
                                                        scale: isPlaying
                                                            ? 1.0
                                                            : 0.7,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                        curve: Cubic(0.68,
                                                            -0.55, 0.265, 1.55),
                                                        child: AspectRatio(
                                                          aspectRatio: 1.0,
                                                          child:
                                                              AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                            curve: Curves
                                                                .easeInOut,
                                                            height: 380,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.black,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withAlpha((255 *
                                                                              0.5)
                                                                          .toInt()),
                                                                  blurRadius:
                                                                      20,
                                                                  spreadRadius:
                                                                      5,
                                                                ),
                                                              ],
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child:
                                                                  CachedNetworkImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                imageUrl:
                                                                    '${ApiService.baseUrl}/storage/cover/track/${nowPlaying?.id}',
                                                                progressIndicatorBuilder:
                                                                    (context,
                                                                        url,
                                                                        downloadProgress) {
                                                                  if (downloadProgress
                                                                          .progress ==
                                                                      null) {
                                                                    return Shimmer
                                                                        .fromColors(
                                                                      baseColor:
                                                                          Colors
                                                                              .grey[800]!,
                                                                      highlightColor:
                                                                          Colors
                                                                              .grey[600]!,
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            double.infinity,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    );
                                                                  }
                                                                  return Container();
                                                                },
                                                                errorWidget:
                                                                    (context,
                                                                        url,
                                                                        error) {
                                                                  return Container(
                                                                    color: Colors
                                                                        .black
                                                                        .withAlpha((255 *
                                                                                0.5)
                                                                            .toInt()),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .music_note,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            86,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                })
                                            // Positioned.fill(
                                            //   child: AspectRatio(
                                            //     aspectRatio: 1,
                                            //     child: Container(
                                            //         color: Colors.white.withAlpha(
                                            //             (255 * .3).toInt())),
                                            //   ),
                                            // )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ConditionalMarqueeText(
                                                    text: nowPlaying?.title ??
                                                        'No track playing',
                                                    containerWidth: 300,
                                                  ),
                                                  ConditionalMarqueeText(
                                                    text: nowPlaying?.artist ??
                                                        'No artist',
                                                    containerWidth: 300,
                                                    style: const TextStyle(
                                                      color: CupertinoColors
                                                          .systemGrey,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: nowPlaying == null
                                                  ? null
                                                  : () {
                                                      setState(() =>
                                                          isLiked = !isLiked);
                                                    },
                                              child: Icon(
                                                isLiked
                                                    ? CupertinoIcons.heart_fill
                                                    : CupertinoIcons.heart,
                                                size: 30,
                                                color: isLiked
                                                    ? Colors.red
                                                    : Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        StreamBuilder<Duration>(
                                          stream:
                                              audioState.player.positionStream,
                                          builder: (context, snapshot) {
                                            final duration =
                                                audioState.player.duration ??
                                                    Duration.zero;

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                InteractiveSlider(
                                                    iconPosition:
                                                        IconPosition.below,
                                                    controller:
                                                        _sliderController,
                                                    padding: EdgeInsets.zero,
                                                    unfocusedMargin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8),
                                                    brightness:
                                                        Brightness.light,
                                                    startIconBuilder: (context,
                                                        value, widget) {
                                                      return Text(
                                                          _formatDuration(Duration(
                                                              seconds: (duration
                                                                          .inSeconds *
                                                                      value)
                                                                  .toInt())),
                                                          style:
                                                              _timeTextStyle);
                                                    },
                                                    endIcon: Text(
                                                        _formatDuration(
                                                            duration),
                                                        style: _timeTextStyle),
                                                    min: 0,
                                                    max: duration.inSeconds
                                                        .toDouble(),
                                                    initialProgress: 0,
                                                    onFocused: (value) {
                                                      setState(() {
                                                        isHovered = true;
                                                      });
                                                    },
                                                    onProgressUpdated: (value) {
                                                      setState(() {
                                                        isHovered = false;
                                                      });
                                                      if (nowPlaying == null) {
                                                        return;
                                                      }
                                                      audioState.player.seek(
                                                          Duration(
                                                              seconds: value
                                                                  .toInt()));
                                                    }),
                                              ],
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 40),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: nowPlaying == null
                                                  ? null
                                                  : () {
                                                      audioState.player
                                                          .setShuffleModeEnabled(
                                                              !audioState.player
                                                                  .shuffleModeEnabled);
                                                    },
                                              child: Icon(
                                                CupertinoIcons.shuffle,
                                                size: 28,
                                                color: audioState.player
                                                        .shuffleModeEnabled
                                                    ? Colors.blue
                                                    : Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 13),
                                            AnimatedPrevButton(
                                              onPressed: nowPlaying == null
                                                  ? null
                                                  : () {
                                                      audioState.player
                                                          .seekToPrevious();
                                                    },
                                            ),
                                            const SizedBox(width: 5),
                                            StreamBuilder(
                                                stream: audioState
                                                    .player.playingStream,
                                                builder: (ctx, snapshot) {
                                                  var isPlaying =
                                                      snapshot.data ?? false;
                                                  return CupertinoButton(
                                                    padding: EdgeInsets.zero,
                                                    onPressed: nowPlaying ==
                                                            null
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
                                                    child: AnimatedSwitcher(
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
                                                        size: 60,
                                                        key: ValueKey(audioState
                                                            .player.playing),
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  );
                                                }),
                                            const SizedBox(width: 5),
                                            AnimatedNextButton(
                                              onPressed: nowPlaying == null
                                                  ? null
                                                  : () {
                                                      audioState.player
                                                          .seekToNext();
                                                    },
                                            ),
                                            const SizedBox(width: 13),
                                            CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: nowPlaying == null
                                                  ? null
                                                  : () {
                                                      audioState.player
                                                          .setLoopMode(
                                                        audioState.player
                                                                    .loopMode ==
                                                                LoopMode.one
                                                            ? LoopMode.off
                                                            : LoopMode.one,
                                                      );
                                                    },
                                              child: Icon(
                                                CupertinoIcons.repeat,
                                                size: 28,
                                                color: audioState
                                                            .player.loopMode ==
                                                        LoopMode.one
                                                    ? Colors.blue
                                                    : Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 60),
                                        InteractiveSlider(
                                          padding: EdgeInsets.zero,
                                          unfocusedMargin: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          brightness: Brightness.light,
                                          startIcon: const Icon(
                                              CupertinoIcons.volume_down),
                                          endIcon: const Icon(
                                              CupertinoIcons.volume_up),
                                          min: 1.0,
                                          max: 100.0,
                                          initialProgress:
                                              audioState.player.volume * 100,
                                          onChanged: (value) {
                                            double volume = value / 100;
                                            audioState.player.setVolume(volume);
                                          },
                                        ),
                                        const SizedBox(height: 60)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  final TextStyle _timeTextStyle = const TextStyle(
    color: CupertinoColors.systemGrey,
    fontSize: 14,
  );
}
