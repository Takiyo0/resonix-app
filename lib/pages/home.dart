import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:resonix/main.dart';
import 'package:resonix/modals/album_modal.dart';
import 'package:resonix/modals/track_modal.dart';
import 'package:resonix/pages/album.dart';
import 'package:resonix/pages/playlist.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/widgets/custom_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  dynamic _trackData;
  dynamic _albumData;
  dynamic _playlistData;
  bool error = false;
  dynamic nowPlaying;
  dynamic user;

  Future<void> getUser() async {
    final response = await ApiService.getUser();
    if (response != null) {
      setState(() {
        user = response?["user"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    getUser();
  }

  Future<void> _fetchData() async {
    var data = await ApiService.getRecommendations();
    if (!mounted) return;
    if (data != null && data.containsKey("error")) {
      setState(() {
        error = true;
      });
    } else if (data != null) {
      setState(() {
        _trackData = data["tracks"];
        _albumData = data["albums"];
        _playlistData = data["playlists"];
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

    Future onTap(dynamic data, String type) async {
      if (type == "album") {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (ctx) => AlbumPage(id: data["id"])),
        );
      } else if (type == "playlist") {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (ctx) => PlaylistPage(id: data["id"])),
        );
      }
      if (type != "track") return;
      await audioState.play(audioState.buildTrack(data, "home"), true);
    }

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
              'Hello, ${user?["nickname"] ?? user?["username"] ?? "User"}',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          leading:
              const Icon(Icons.account_circle, color: Colors.white, size: 32),
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
        body: Container(
          child: error
              ? Center(
                  child: const Text('Error fetching data',
                      style: TextStyle(color: Colors.red)))
              : (_trackData == null ||
                      _albumData == null ||
                      _playlistData == null)
                  ? Center(child: const CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.only(
                          top: 16.0, left: 16.0, right: 16.0, bottom: 80.0),
                      children: [
                        const Text("Tracks",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        _buildTrackList(
                            _trackData,
                            nowPlaying,
                            (item) => onTap(item, "track"),
                            audioState,
                            context),
                        const SizedBox(height: 20),
                        const Text("Albums",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        _buildList(_albumData, "album", nowPlaying,
                            (item) => onTap(item, "album"), audioState),
                        const SizedBox(height: 20),
                        const Text("Playlists",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        _buildList(_playlistData, "playlist", nowPlaying,
                            (item) => onTap(item, "playlist"), audioState),
                      ],
                    ),
        ));
  }
}

Widget _buildTrackList(List<dynamic> data, dynamic nowPlaying,
    ValueChanged<dynamic> onTap, AudioState audioState, BuildContext context) {
  if (data.isEmpty) {
    return SizedBox(
      height: 210,
      child: Center(
        child: Text("No track found", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  return SizedBox(
    height: 325,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (int i = 0; i < data.length; i += 4)
          Container(
            width: 220,
            margin: const EdgeInsets.only(right: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: data
                  .sublist(i, i + 4 > data.length ? data.length : i + 4)
                  .map((item) => _buildTrackItem(
                      item, nowPlaying, onTap, audioState, context))
                  .toList(),
            ),
          ),
      ],
    ),
  );
}

Widget _buildTrackItem(dynamic item, dynamic nowPlaying,
    ValueChanged<dynamic> onTap, AudioState audioState, BuildContext context) {
  if (item == null) return const SizedBox();

  bool isPlaying = nowPlaying != null &&
      (nowPlaying?.extras?["albumId"] == item["id"] ||
          nowPlaying?.id == item["id"]);

  return GestureDetector(
    onTap: nowPlaying != null && nowPlaying?.id == item["id"]
        ? null
        : () => onTap(item),
    onLongPress: () {
      TrackModal.show(
          context,
          [
            TrackModalAction.favorite,
            TrackModalAction.queue,
            TrackModalAction.playlistAdd,
            TrackModalAction.album,
            TrackModalAction.artist
          ],
          item,
          audioState,
          null,
          null);
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: Color(0xFF28123E),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Row(
          children: [
            _buildCoverImage("track", item, 55, null),
            const SizedBox(width: 10),
            Expanded(
              child: _buildItemText(item),
            ),
            if (isPlaying)
              Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: SpinKitWave(
                  color: Colors.white,
                  size: 15.0,
                  type: SpinKitWaveType.center,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildList(
  List<dynamic> data,
  String type,
  dynamic nowPlaying,
  ValueChanged<dynamic> onTap,
  AudioState audioState,
) {
  if (data.isEmpty) {
    return SizedBox(
      height: 210,
      child: Center(
        child: Text(
          "No $type found",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  return SizedBox(
    height: 210,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: data.length,
      itemBuilder: (context, index) {
        var item = data[index];
        bool isNowPlaying = nowPlaying != null &&
            (nowPlaying?.extras?["albumId"] == item["id"] ||
                nowPlaying?.id == item["id"]);

        return Container(
          width: 150,
          margin: const EdgeInsets.all(8.0),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFF28123E),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: InkWell(
              onTap: isNowPlaying ? null : () => onTap(item),
              onLongPress: type == "album"
                  ? () {
                      AlbumModal.show(
                        context,
                        [AlbumModalAction.favorite, AlbumModalAction.artist],
                        item,
                        audioState,
                        null,
                        null,
                      );
                    }
                  : null,
              borderRadius: BorderRadius.circular(12.0),
              splashColor: Colors.white.withAlpha((255 * 0.2).toInt()),
              highlightColor: Colors.white.withAlpha((255 * 0.1).toInt()),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCoverImage(type, item, 130, isNowPlaying),
                    const SizedBox(height: 8),
                    _buildItemText(item),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildCoverImage(
    String type, dynamic item, double size, bool? isNowPlaying) {
  return Stack(
    children: [
      CustomImage(
            imageUrl: '${ApiService.baseUrl}/storage/cover/$type/${item["id"]}',
            height: size.toInt(),
            width: size.toInt(),
          ),
      if (isNowPlaying == true)
        Positioned(
          bottom: 7,
          right: 7,
          child: Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: SpinKitWave(
              color: Colors.white,
              size: 15.0,
              type: SpinKitWaveType.center,
            ),
          ),
        ),
    ],
  );
}

Widget _buildItemText(dynamic item) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        item["name"],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        item["artists"]?.map((artist) => artist.toString()).join(", ") ??
            item["ownername"] ??
            "Unknown",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 12,
        ),
      ),
    ],
  );
}
