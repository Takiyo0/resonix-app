import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:resonix/main.dart';
import 'package:resonix/services/api_service.dart';

class NowPlayingPage extends StatefulWidget {
  final ScrollController scrollController;

  const NowPlayingPage({super.key, required this.scrollController});

  @override
  NowPlayingPageState createState() => NowPlayingPageState();
}

class NowPlayingPageState extends State<NowPlayingPage> {
  dynamic nowPlaying;
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    final audioState = context.watch<AudioState>();

    audioState.player.playerStateStream.distinct().listen((state) {
      final currentTrack = audioState.player.sequenceState?.currentSource?.tag;
      if (nowPlaying?.title != currentTrack?.title) {
        setState(() {
          nowPlaying = currentTrack;
        });
      }
    });

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent,
      child: CustomScrollView(controller: widget.scrollController, slivers: [
        SliverFillRemaining(
          child: Stack(
            children: [
              Stack(
                children: [
                  if (nowPlaying != null)
                    Positioned.fill(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageFiltered(
                            imageFilter:
                                ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Image.network(
                              '${ApiService.baseUrl}/storage/cover/track/${nowPlaying?.id}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: Colors.transparent),
                            ),
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 50, bottom: 120),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container( width: 60, height: 5, decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),),
                          const SizedBox(height: 30),
                          Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  '${ApiService.baseUrl}/storage/cover/track/${nowPlaying?.id}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.music_note,
                                        color: Colors.white,
                                        size: 80,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nowPlaying?.title ?? 'No track playing',
                                      style: const TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      nowPlaying?.artist ?? 'No artist',
                                      style: const TextStyle(
                                        color: CupertinoColors.systemGrey,
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
                                        setState(() => isLiked = !isLiked);
                                      },
                                child: Icon(
                                  isLiked
                                      ? CupertinoIcons.heart_fill
                                      : CupertinoIcons.heart,
                                  size: 30,
                                  color: isLiked ? Colors.red : Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          StreamBuilder<Duration>(
                            stream: audioState.player.positionStream,
                            builder: (context, snapshot) {
                              final position = snapshot.data ?? Duration.zero;
                              final duration =
                                  audioState.player.duration ?? Duration.zero;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 3.5,
                                        thumbShape: const RoundSliderThumbShape(
                                            enabledThumbRadius: 4),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                                overlayRadius: 8),
                                        activeTrackColor: Colors.white,
                                        inactiveTrackColor:
                                            Colors.grey.shade700,
                                        thumbColor: Colors.white,
                                      ),
                                      child: Slider(
                                        value: position.inSeconds
                                            .toDouble()
                                            .clamp(0,
                                                duration.inSeconds.toDouble()),
                                        min: 0,
                                        max: duration.inSeconds.toDouble(),
                                        onChanged: nowPlaying == null
                                            ? null
                                            : (value) {
                                                audioState.player.seek(Duration(
                                                    seconds: value.toInt()));
                                              },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_formatDuration(position),
                                            style: _timeTextStyle),
                                        Text(_formatDuration(duration),
                                            style: _timeTextStyle),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: nowPlaying == null
                                    ? null
                                    : () {
                                        audioState.player.setShuffleModeEnabled(
                                            !audioState
                                                .player.shuffleModeEnabled);
                                      },
                                child: Icon(
                                  CupertinoIcons.shuffle,
                                  size: 28,
                                  color: audioState.player.shuffleModeEnabled
                                      ? Colors.blue
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: nowPlaying == null
                                    ? null
                                    : () {
                                        audioState.player.seekToPrevious();
                                      },
                                child: const Icon(
                                    CupertinoIcons.backward_end_fill,
                                    size: 38,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: nowPlaying == null
                                    ? null
                                    : () {
                                        if (audioState.player.playing) {
                                          audioState.player.pause();
                                        } else {
                                          audioState.player.play();
                                        }
                                      },
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(
                                        scale: animation, child: child);
                                  },
                                  child: Icon(
                                    audioState.player.playing
                                        ? CupertinoIcons.pause_fill
                                        : CupertinoIcons.play_fill,
                                    size: 55,
                                    key: ValueKey(audioState.player.playing),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: nowPlaying == null
                                    ? null
                                    : () {
                                        audioState.player.seekToNext();
                                      },
                                child: const Icon(
                                    CupertinoIcons.forward_end_fill,
                                    size: 38,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: nowPlaying == null
                                    ? null
                                    : () {
                                        audioState.player.setLoopMode(
                                          audioState.player.loopMode ==
                                                  LoopMode.one
                                              ? LoopMode.off
                                              : LoopMode.one,
                                        );
                                      },
                                child: Icon(
                                  CupertinoIcons.repeat,
                                  size: 28,
                                  color:
                                      audioState.player.loopMode == LoopMode.one
                                          ? Colors.blue
                                          : Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Row(children: [
                            Icon(
                              CupertinoIcons.volume_down,
                              size: 24,
                              color: Colors.white38,
                            ),
                            Expanded(
                                child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3.5,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 4),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 8),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.grey.shade700,
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: audioState.player.volume,
                                onChanged: (value) {
                                  audioState.player.setVolume(value);
                                },
                              ),
                            )),
                            Icon(
                              CupertinoIcons.volume_up,
                              size: 24,
                              color: Colors.white38,
                            )
                          ])
                        ],
                      )),
                ],
              ),
            ],
          ),
        ),
      ]),
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
