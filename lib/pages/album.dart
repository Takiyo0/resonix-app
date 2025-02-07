import 'dart:ui';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:resonix/main.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/state/growing_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AlbumPage extends StatefulWidget {
  final dynamic data;
  final VoidCallback onBack;

  AlbumPage({required this.data, required this.onBack});

  @override
  State<AlbumPage> createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  Color? dominantColor;
  Color? lightColor;
  dynamic nowPlaying;

  @override
  void initState() {
    super.initState();
    _extractPalette();
  }

  Color _darkenColor(Color color, [double amount = 2]) {
    return Color.lerp(color, Colors.black, amount) ?? color;
  }

  Future<void> _extractPalette() async {
    try {
      final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(
            '${ApiService.baseUrl}/storage/cover/album/${widget.data["album"]["id"]}'),
      );

      setState(() {
        dominantColor = _darkenColor(
            palette.dominantColor?.color ?? const Color(0xFF1A0E2E), 0.5);
        lightColor = _darkenColor(
            palette.lightMutedColor?.color ?? const Color(0xFF1A0E2E), 0.5);
      });
    } catch (e) {
      debugPrint("Error extracting color: $e");
    }
  }

  double _scale = 1.0;

  void _onScroll(ScrollNotification notification) {
    if (notification.metrics.pixels > 0) {
      setState(() {
        _scale = 1.0 + (notification.metrics.pixels / 200);
      });
    }
  }

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

    Future<void> onTap(dynamic data, String type) async {
      FocusScope.of(context).unfocus();
      if (type != "track") return;
      try {
        try {
          AudioSource? tag;
          List<AudioSource> tags =
              (widget.data?["tracks"]?["tracks"] as List? ?? []).map((track) {
            var t = AudioSource.uri(
              Uri.parse('${ApiService.baseUrl}/storage/track/${track["id"]}'),
              tag: MediaItem(
                id: track["id"].toString(),
                album: track['albumname'] ?? 'Unknown Album',
                artist: (track['artists'] as List?)
                        ?.map((artist) => artist.toString())
                        .join(", ") ??
                    'Unknown Artist',
                title: track['name'] ?? 'Unknown Title',
                extras: {
                  "albumId": track["albumid"],
                },
                artUri: Uri.parse(
                    '${ApiService.baseUrl}/storage/cover/track/${track["id"]}'),
              ),
            );
            if (track["id"] == data["id"]) {
              tag = t;
            }
            return t;
          }).toList();

          if (tag == null) return;

          int index = tags.indexOf(tag!);

          await audioState.player.setAudioSource(
            ConcatenatingAudioSource(
              children: tags,
            ),
            initialIndex: index,
          );
          audioState.player.play();
        } catch (e, stack) {}
      } catch (e) {}
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
            appBar: AppBar(
              title: Text(widget.data?["album"]?["name"] ?? "Album"),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white.withAlpha(25),
                  ),
                ),
              ),
              foregroundColor: Colors.white,
              centerTitle: false,
              titleTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                _onScroll(notification);
                return true;
              },
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: dominantColor != null && lightColor != null
                            ? [dominantColor!, lightColor!]
                            : [Colors.black, Colors.grey.shade900],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GrowingImageOnScroll(
                              imageUrl:
                                  '${ApiService.baseUrl}/storage/cover/album/${widget.data?["album"]["id"]}',
                              scale: _scale,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.data?["album"]?["name"] ?? "Playlist",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            widget.data?["album"]?['artists']
                                    ?.map((artist) => artist.toString())
                                    .join(", ") ??
                                "Unknown Artist",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[400]),
                          ),
                          SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                widget.data?["tracks"]?["tracks"]?.length ?? 0,
                            itemBuilder: (context, index) {
                              var track =
                                  widget.data?["tracks"]?["tracks"][index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: const Color(0x331A0E2E),
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () => onTap(track, "track"),
                                      borderRadius: BorderRadius.circular(12.0),
                                      splashColor:
                                          Colors.white.withOpacity(0.2),
                                      highlightColor:
                                          Colors.white.withOpacity(0.1),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.network(
                                                  '${ApiService.baseUrl}/storage/cover/track/${track["id"]}',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Center(
                                                      child: Icon(
                                                        Icons.music_note,
                                                        color: Colors.white,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    track["name"],
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    track["artists"]
                                                            ?.map((artist) =>
                                                                artist
                                                                    .toString())
                                                            .join(", ") ??
                                                        "Unknown Artist",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[400]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: nowPlaying?.id ==
                                                      track["id"]
                                                  ? SpinKitWave(
                                                      color: Colors.greenAccent,
                                                      size: 15.0,
                                                      type: SpinKitWaveType
                                                          .center,
                                                    )
                                                  : const Icon(Icons.play_arrow,
                                                      color: Colors.white),
                                              onPressed: () =>
                                                  onTap(track, "track"),
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
                          const SizedBox(height: 70),
                        ],
                      ),
                    )),
              ),
            )));
  }
}

extension on AudioSource {
  get tag => null;
}
