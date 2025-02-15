import 'dart:ui';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:resonix/main.dart';
import 'package:resonix/modals/track_modal.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/services/helper.dart';
import 'package:resonix/widgets/custom_image.dart';
import 'package:resonix/widgets/growing_image.dart';
import 'package:resonix/widgets/skeleton_text.dart';
import 'package:resonix/widgets/skeleton_track.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AlbumPage extends StatefulWidget {
  final dynamic id;

  const AlbumPage({super.key, required this.id});

  @override
  State<AlbumPage> createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  Color? lightColor;
  double _modalProgress = 0.0;
  dynamic nowPlaying;
  dynamic data;
  dynamic tracks;

  final ValueNotifier<double> _scaleNotifier = ValueNotifier(1.0);
  final ValueNotifier<double> _barProgressNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    loadAlbum();
    loadTracks();
  }

  Future<void> loadAlbum() async {
    var album = await ApiService.getAlbum(widget.id);
    if (!mounted) return;
    if (album != null) {
      if (album["error"] != null) {
        return ApiService.returnError(context, album["error"]);
      }
      setState(() {
        data = album["album"];
      });
      _extractPalette();
    } else {
      await ApiService.returnTokenExpired(context);
    }
  }

  Future<void> loadTracks() async {
    var tracks = await ApiService.getAlbumTracks(widget.id);
    if (!mounted) return;
    if (tracks != null) {
      if (tracks["error"] != null) {
        return ApiService.returnError(context, tracks["error"]);
      }
      setState(() {
        this.tracks = tracks["tracks"];
      });
    } else {
      await ApiService.returnTokenExpired(context);
    }
  }

  Future<void> like() async {
    var response = await ApiService.likeAlbum(widget.id);
    if (!mounted) return;
    if (response != null) {
      if (response["error"] != null) {
        return ApiService.returnError(context, response["error"]);
      }
      setState(() {
        data["liked"] = response["liked"];
        data["likedCount"] = response["likedCount"];
      });
    } else {
      await ApiService.returnTokenExpired(context);
    }
  }

  Future<void> likeTrack(Map<String, dynamic> track) async {
    var response = await ApiService.likeTrack(track["id"]);
    if (!mounted) return;
    if (response != null) {
      if (response["error"] != null) {
        return ApiService.returnError(context, response["error"]);
      }
      setState(() {
        track["liked"] = response["liked"];
      });
    } else {
      await ApiService.returnTokenExpired(context);
    }
  }

  Color _darkenColor(Color color, [double amount = 2]) {
    return Color.lerp(color, Colors.black, amount) ?? color;
  }

  Future<void> _extractPalette() async {
    try {
      final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        NetworkImage('${ApiService.baseUrl}/storage/cover/album/${data["id"]}'),
      );
      if (!mounted) return;
      setState(() {
        lightColor = _darkenColor(
            palette.lightMutedColor?.color ?? const Color(0xFF1A0E2E), 0.35);
      });
    } catch (e) {
      debugPrint("Error extracting color: $e");
    }
  }

  void _onScroll(ScrollNotification notification) {
    if (notification.metrics.pixels > 0 && notification.metrics.pixels < 350) {
      if (mounted) {
        _scaleNotifier.value = 1.0 + (notification.metrics.pixels / 900);
      }
    }
    _barProgressNotifier.value =
        (notification.metrics.pixels.clamp(230, 310) - 230) / 50;
  }

  @override
  Widget build(BuildContext context) {
    final audioState = context.watch<AudioState>();

    // double progress = clampDouble(
    //   _sheetController.pixels / (MediaQuery.of(context).size.height * 0.8),
    //   0.0,
    //   1.0,
    // );

    audioState.player.playerStateStream.distinct().listen((state) {
      final currentTrack = audioState.player.sequenceState?.currentSource?.tag;

      if (nowPlaying?.title != currentTrack?.title) {
        setState(() {
          nowPlaying = currentTrack;
        });
      }
    });

    Future<void> onTap(dynamic data, String type) async {
      FocusScope.of(context).unfocus();
      if (type != "track" && type != "album") return;
      List<UriAudioSource> tags = [];
      UriAudioSource? tag;

      for (var track in (tracks as List? ?? [])) {
        var t = audioState.buildTrack(track, this.data["name"] ?? "Album");
        tags.add(t);
        if (data != null && track["id"] == data["id"]) tag = t;
      }

      if (tag == null && data != null) return;

      await audioState.playAll(
          tags, true, tag == null ? null : tags.indexOf(tag));
    }

    return VisibilityDetector(
      key: Key("AlbumPage"),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0) {
          _extractPalette();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 10),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, _modalProgress * 20, 0)
                ..scale(1 - (_modalProgress * 0.1)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      lightColor ?? Colors.grey.shade900,
                      Color(0xFF150825)
                    ],
                    stops: [
                      0.0,
                      0.8
                    ]),
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  _onScroll(notification);
                  return true;
                },
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: SafeArea(
                        bottom: false,
                        child: Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.only(
                                  top: 16, left: 16, right: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFF150825),
                                    Color(0xFF150825)
                                  ],
                                  stops: [0.0, 0.9, 0.1],
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 16),
                                  child: Column(
                                    children: [
                                      Center(
                                        child: AnimatedBuilder(
                                          animation: Listenable.merge(
                                              [_scaleNotifier]),
                                          builder: (context, child) {
                                            return GrowingImageOnScroll(
                                              imageUrl:
                                                  '${ApiService.baseUrl}/storage/cover/album/${data?["id"]}',
                                              scale: _scaleNotifier.value,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: data == null
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: const [
                                                      SkeletonText(
                                                          width: 150,
                                                          height: 20),
                                                      SizedBox(height: 8),
                                                      SkeletonText(
                                                          width: 100,
                                                          height: 16),
                                                      SkeletonText(
                                                          width: 50,
                                                          height: 16),
                                                    ],
                                                  )
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        (data["name"] ??
                                                            "Album"),
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                        softWrap: true,
                                                      ),
                                                      Text(
                                                        data['artists']
                                                                ?.map((artist) =>
                                                                    artist
                                                                        .toString())
                                                                .join(", ") ??
                                                            "Unknown Artist",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors
                                                                .grey[400]),
                                                        softWrap: true,
                                                      ),
                                                      Row(children: [
                                                        Icon(Icons.favorite,
                                                            color: Color(
                                                                0xFFFF77A8),
                                                            size: 16),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          "${data?["likedCount"] ?? 0} users",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey[400]),
                                                          softWrap: true,
                                                        ),
                                                      ])
                                                    ],
                                                  ),
                                          ),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: data == null
                                                      ? null
                                                      : like,
                                                  icon: AnimatedSwitcher(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    transitionBuilder:
                                                        (child, animation) {
                                                      var curve =
                                                          CurvedAnimation(
                                                              parent: animation,
                                                              curve: Curves
                                                                  .easeOutBack);
                                                      return ScaleTransition(
                                                          scale: curve,
                                                          child: child);
                                                    },
                                                    child: Icon(
                                                      data?["liked"] == true
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color: Color(0xFFFF77A8),
                                                      key: ValueKey(
                                                          data?["liked"]),
                                                      size: 32,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  style: ButtonStyle(
                                                    padding:
                                                        const WidgetStatePropertyAll(
                                                            EdgeInsets.zero),
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  onPressed: data == null
                                                      ? null
                                                      : () => onTap(null, "album"),
                                                  icon: const Icon(
                                                    Icons.play_circle_fill,
                                                    color: Color(0xFFBB86FC),
                                                    size: 64,
                                                  ),
                                                ),
                                              ])
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Color(0xFF150825),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: tracks == null
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: 10,
                                          itemBuilder: (context, index) =>
                                              SkeletonTrack(),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: tracks?.length ?? 0,
                                          itemBuilder: (context, index) {
                                            var track = tracks[index];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              child: Material(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0x331A0E2E),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withAlpha(
                                                                (255 * 0.2)
                                                                    .toInt()),
                                                        spreadRadius: 2,
                                                        blurRadius: 5,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: InkWell(
                                                    onTap: () =>
                                                        onTap(track, "track"),
                                                    onLongPress: () {
                                                      TrackModal.show(
                                                          context,
                                                          [
                                                            TrackModalAction
                                                                .favorite,
                                                            TrackModalAction
                                                                .queue,
                                                            TrackModalAction
                                                                .playlistAdd,
                                                            TrackModalAction
                                                                .artist
                                                          ],
                                                          track,
                                                          audioState,
                                                          null,
                                                          null);
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    splashColor: Colors.white
                                                        .withAlpha((255 * 0.2)
                                                            .toInt()),
                                                    highlightColor: Colors.white
                                                        .withAlpha((255 * 0.1)
                                                            .toInt()),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          CustomImage(
                                                              imageUrl:
                                                                  '${ApiService.baseUrl}/storage/cover/track/${track["id"]}',
                                                              height: 60,
                                                              width: 60),
                                                          const SizedBox(
                                                              width: 12),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  track["name"],
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                Text(
                                                                  track["artists"]
                                                                          ?.map((artist) => artist
                                                                              .toString())
                                                                          .join(
                                                                              ", ") ??
                                                                      "Unknown Artist",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          400]),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              IconButton(
                                                                icon:
                                                                    AnimatedSwitcher(
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  transitionBuilder:
                                                                      (child,
                                                                          animation) {
                                                                    var curve = CurvedAnimation(
                                                                        parent:
                                                                            animation,
                                                                        curve: Curves
                                                                            .easeOutBack);
                                                                    return ScaleTransition(
                                                                        scale:
                                                                            curve,
                                                                        child:
                                                                            child);
                                                                  },
                                                                  child: Icon(
                                                                    track["liked"] ==
                                                                            true
                                                                        ? Icons
                                                                            .favorite
                                                                        : Icons
                                                                            .favorite_border,
                                                                    color: Colors
                                                                        .white,
                                                                    key: ValueKey(
                                                                        track[
                                                                            "liked"]),
                                                                  ),
                                                                ),
                                                                onPressed: () =>
                                                                    likeTrack(
                                                                        track),
                                                              ),
                                                              SizedBox(
                                                                width: 40,
                                                                child: nowPlaying
                                                                            ?.id ==
                                                                        track[
                                                                            "id"]
                                                                    ? IconButton(
                                                                        icon: nowPlaying?.id ==
                                                                                track["id"]
                                                                            ? SpinKitWave(
                                                                                color: Colors.greenAccent,
                                                                                size: 15.0,
                                                                                type: SpinKitWaveType.center,
                                                                              )
                                                                            : const Icon(Icons.play_arrow, color: Colors.white),
                                                                        onPressed: () => onTap(
                                                                            track,
                                                                            "track"),
                                                                      )
                                                                    : Text(
                                                                        Helper.msToMmSs(
                                                                            track["durationms"] ??
                                                                                0),
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.grey[400],
                                                                        ),
                                                                      ),
                                                              )
                                                            ],
                                                          )
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
                                const SizedBox(height: 70),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      child: AnimatedBuilder(
                        animation: Listenable.merge(
                            [_barProgressNotifier, _scaleNotifier]),
                        builder: (context, child) {
                          return Stack(
                            children: [
                              AnimatedContainer(
                                width: MediaQuery.of(context).size.width,
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: (lightColor != null
                                          ? _darkenColor(lightColor!, 0.5)
                                          : Colors.black)
                                      .withAlpha(
                                          (255 * _barProgressNotifier.value)
                                              .clamp(0, 255)
                                              .toInt()),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(
                                          (_barProgressNotifier.value *
                                                  255 *
                                                  0.2)
                                              .toInt()),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10, left: 10),
                                  child: SafeArea(
                                    bottom: false,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          icon: Icon(Icons.arrow_back_ios,
                                              color: Colors.white, size: 20),
                                        ),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: AnimatedBuilder(
                                            animation: Listenable.merge([]),
                                            builder: (context, child) {
                                              return Transform.translate(
                                                offset: Offset(
                                                    0,
                                                    20 *
                                                        (1 -
                                                            clampDouble(
                                                                _barProgressNotifier
                                                                    .value,
                                                                0.0,
                                                                1.0))),
                                                child: Opacity(
                                                  opacity: clampDouble(
                                                      _barProgressNotifier
                                                          .value,
                                                      0.0,
                                                      1.0),
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: data == null
                                                ? SkeletonText(
                                                    width: 150, height: 20)
                                                : Text(
                                                    data["name"] ?? "Album",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
